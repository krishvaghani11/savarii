/**
 * emailNotification.js — Production-grade orchestrator for ticket emails. (v3)
 *
 * Exports:
 *   sendTicketConfirmationEmail(booking, ticketId, triggeredBy?) → Promise<void>
 *
 * v3 Upgrades over v2:
 *   1. Dead-letter strategy: emailFailureCount + emailPermanentFailure fields
 *   2. Exponential backoff: 2s → 10s → 30s per retry
 *   3. Max 3 cumulative failures → permanent failure → no more retries
 *   4. Push notification fallback on failure or permanent failure
 *   5. Real-time failure rate monitoring after every failure
 *   6. Guard 0: emailPermanentFailure fast exit (no DB read needed)
 *
 * Firestore fields managed (v3 additions):
 *   emailFailureCount     number   — cumulative failure counter
 *   emailPermanentFailure boolean  — if true, no more retries ever
 *   notificationStatus    string   — "email_sent" | "email_failed" | "email_failed_permanent"
 */

"use strict";

const functions     = require("firebase-functions");
const admin         = require("firebase-admin");
const { generateTicketPdf }                    = require("./pdfService");
const { uploadTicketPdf }                      = require("./storageService");
const { sendTicketEmail }                      = require("./emailService");
const { writeEmailLog }                        = require("./emailLogs");
const { sendTicketPushFallback }              = require("./pushFallback");
const { checkEmailFailureRate }               = require("./monitoringService");

const db         = admin.firestore();
const FieldValue = admin.firestore.FieldValue;

// ─── Constants ────────────────────────────────────────────────────────────────
const TEMPLATE_VERSION   = "v1";
const RATE_LIMIT_MS      = 30_000;   // 30 seconds between attempts
const MAX_FAILURES       = 3;        // permanent failure threshold
const EMAIL_REGEX        = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

// Exponential backoff delays (ms) for step-level retries
// Attempt 1 → 2s, Attempt 2 → 10s, Attempt 3 → 30s
const BACKOFF_DELAYS_MS = [2_000, 10_000, 30_000];

// ─── Helpers ──────────────────────────────────────────────────────────────────

function _isValidEmail(email) {
  return typeof email === "string" && EMAIL_REGEX.test(email.trim());
}

/**
 * Wraps a function with exponential backoff.
 * Uses the retryAttempt index to pick the delay from BACKOFF_DELAYS_MS.
 *
 * @param {Function} fn
 * @param {string}   label         — used for logging
 * @param {number}   retryAttempt  — 0-based cumulative retry count (for backoff lookup)
 * @returns {Promise<any>}
 */
async function _withExponentialBackoff(fn, label, retryAttempt = 0) {
  try {
    return await fn();
  } catch (err) {
    const delayMs = BACKOFF_DELAYS_MS[retryAttempt] ?? BACKOFF_DELAYS_MS[BACKOFF_DELAYS_MS.length - 1];
    functions.logger.warn(
      `[EmailNotification] ${label} failed — retrying in ${delayMs / 1000}s (attempt ${retryAttempt + 1})`,
      { error: err.message }
    );
    await new Promise((r) => setTimeout(r, delayMs));
    return fn(); // second attempt — failure propagates to caller
  }
}

// ─── Main Orchestrator ────────────────────────────────────────────────────────

/**
 * Sends a ticket confirmation email after a successful booking.
 * Handles idempotency, locking, rate limiting, exponential backoff,
 * dead-letter failure capping, push fallback, and monitoring.
 *
 * @param {Object} booking    — Firestore ticket document data
 * @param {string} ticketId   — Firestore document ID
 * @param {string} [triggeredBy="trigger"]
 */
async function sendTicketConfirmationEmail(booking, ticketId, triggeredBy = "trigger") {
  const log = (level, msg, extra = {}) =>
    functions.logger[level](`[EmailNotification] ticketId=${ticketId} — ${msg}`, extra);

  // ── Guard 0: Permanent failure — never retry ───────────────────────────────
  if (booking.emailPermanentFailure === true) {
    log("warn", "emailPermanentFailure=true. No further retries.");
    return;
  }

  // ── Guard 1: Already sent — fast exit ─────────────────────────────────────
  if (booking.emailSent === true) {
    log("info", "emailSent=true already. Skipping.");
    return;
  }

  // ── Guard 2: Rate limit (30-second window) ─────────────────────────────────
  const lastAttempt = booking.lastEmailAttemptAt?.toDate?.() || null;
  if (lastAttempt && (Date.now() - lastAttempt.getTime()) < RATE_LIMIT_MS) {
    log("warn", `Rate limited — last attempt was <${RATE_LIMIT_MS / 1000}s ago.`);
    await writeEmailLog({
      bookingId: booking.bookingId || ticketId,
      ticketId,
      email:        booking.email || "unknown",
      status:       "skipped",
      errorMessage: "rate_limited",
      triggeredBy,
    });
    return;
  }

  const ticketRef = db.collection("tickets").doc(ticketId);

  // ── Guard 3: Atomic processing lock ───────────────────────────────────────
  let lockAcquired = false;
  let currentFailureCount = 0;

  try {
    lockAcquired = await db.runTransaction(async (txn) => {
      const snap = await txn.get(ticketRef);
      const data = snap.data() || {};

      // Double-check permanent failure inside transaction
      if (data.emailPermanentFailure || data.emailSent || data.emailProcessing) return false;

      currentFailureCount = data.emailFailureCount || 0;

      txn.update(ticketRef, {
        emailProcessing:    true,
        lastEmailAttemptAt: FieldValue.serverTimestamp(),
      });
      return true;
    });
  } catch (txnErr) {
    log("error", "Transaction failed when acquiring lock.", { error: txnErr.message });
    return;
  }

  if (!lockAcquired) {
    log("info", "Lock not acquired (permanent/sent/processing). Skipping.");
    return;
  }

  log("info", "Lock acquired. Starting email flow.", {
    email:             booking.email,
    bookingId:         booking.bookingId,
    triggeredBy,
    currentFailureCount,
  });

  // ── Email validation ───────────────────────────────────────────────────────
  if (!_isValidEmail(booking.email)) {
    log("error", "Invalid or missing email address.", { email: booking.email });
    await _handleFailure(ticketRef, booking, ticketId, "invalid_email",
      currentFailureCount, triggeredBy, log);
    return;
  }

  const retryAttempt = currentFailureCount; // use cumulative count as backoff index

  try {

    // ── Step 1: Generate PDF ─────────────────────────────────────────────────
    log("info", "Step 1/3 — Generating PDF (with QR code)...");
    const pdfBuffer = await _withExponentialBackoff(
      () => generateTicketPdf(booking),
      "PDF_generation",
      retryAttempt
    );
    log("info", `Step 1/3 — PDF ready. Size: ${pdfBuffer.length} bytes.`);

    // ── Step 2: Upload to Firebase Storage ───────────────────────────────────
    log("info", "Step 2/3 — Uploading PDF to Firebase Storage...");
    const storageId = booking.bookingId || ticketId;
    const pdfUrl    = await _withExponentialBackoff(
      () => uploadTicketPdf(storageId, pdfBuffer),
      "PDF_upload",
      retryAttempt
    );
    log("info", `Step 2/3 — PDF uploaded.`);

    // ── Step 3: Send email via Resend ────────────────────────────────────────
    log("info", `Step 3/3 — Sending email to ${booking.email} (template: ${TEMPLATE_VERSION})...`);
    const result = await _withExponentialBackoff(
      () => sendTicketEmail(booking, ticketId, pdfUrl),
      "email_send",
      retryAttempt
    );
    log("info", `Step 3/3 — Email sent. Resend ID: ${result?.id}`);

    // ── Success: Update Firestore ─────────────────────────────────────────────
    await ticketRef.update({
      emailSent:            true,
      emailProcessing:      false,
      emailPermanentFailure: false,
      ticketPdfUrl:         pdfUrl,
      notificationStatus:   "email_sent",
      templateVersion:      TEMPLATE_VERSION,
      emailRetryCount:      retryAttempt,
      emailFailureCount:    currentFailureCount, // don't reset — keep history
      emailTimestamp:       FieldValue.serverTimestamp(),
    });

    log("info", "✅ All steps complete. emailSent=true written to Firestore.");

    await writeEmailLog({
      bookingId:       booking.bookingId || ticketId,
      ticketId,
      email:           booking.email,
      status:          "success",
      retryCount:      retryAttempt,
      templateVersion: TEMPLATE_VERSION,
      resendId:        result?.id || null,
      triggeredBy,
    });

  } catch (err) {

    log("error", `❌ Email flow failed after backoff retry.`, {
      error:       err.message,
      retryAttempt,
    });

    await _handleFailure(ticketRef, booking, ticketId, err.message,
      currentFailureCount, triggeredBy, log);
  }
}

// ─── Failure handler ──────────────────────────────────────────────────────────

/**
 * Centralised failure handler:
 *   - Increments emailFailureCount
 *   - Sets permanent failure if count >= MAX_FAILURES
 *   - Sends push fallback
 *   - Triggers monitoring check
 *   - Writes analytics log
 */
async function _handleFailure(ticketRef, booking, ticketId, errorMessage,
    currentFailureCount, triggeredBy, log) {

  const newFailureCount = currentFailureCount + 1;
  const isPermanent     = newFailureCount >= MAX_FAILURES;

  const firestoreUpdate = {
    emailProcessing:      false,
    emailSent:            false,
    emailFailureCount:    newFailureCount,
    emailPermanentFailure: isPermanent,
    emailError:           errorMessage || "unknown_error",
    emailRetryCount:      currentFailureCount,
    emailTimestamp:       FieldValue.serverTimestamp(),
    notificationStatus:   isPermanent
      ? "email_failed_permanent"
      : "email_failed",
  };

  if (isPermanent) {
    log("error",
      `🔴 PERMANENT FAILURE — emailFailureCount=${newFailureCount} >= MAX=${MAX_FAILURES}. No more retries.`,
      { errorMessage }
    );
  } else {
    log("warn",
      `⚠️ Failure ${newFailureCount}/${MAX_FAILURES}. Will retry on next trigger.`,
      { errorMessage }
    );
  }

  // Update Firestore
  try {
    await ticketRef.update(firestoreUpdate);
  } catch (updateErr) {
    log("warn", "Could not update Firestore on failure.", { error: updateErr.message });
  }

  // Analytics log
  await writeEmailLog({
    bookingId:    booking.bookingId || ticketId,
    ticketId,
    email:        booking.email,
    status:       isPermanent ? "permanent_failure" : "failure",
    errorMessage,
    retryCount:   currentFailureCount,
    triggeredBy,
  });

  // Push fallback — send on ANY failure (not just permanent)
  // so user always gets notified as quickly as possible
  await sendTicketPushFallback(
    // Merge current pdfUrl if it was already uploaded
    { ...booking, ticketPdfUrl: booking.ticketPdfUrl || "" },
    ticketId
  );

  // Monitoring — check failure rate after every failure
  checkEmailFailureRate().catch((err) =>
    functions.logger.warn("[EmailNotification] Monitoring check failed.", { error: err.message })
  );
}

module.exports = { sendTicketConfirmationEmail };
