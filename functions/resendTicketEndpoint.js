/**
 * resendTicketEndpoint.js — Callable Cloud Function to manually resend a ticket email.
 *
 * Exposed as: resendTicketEmail (HTTPS Callable)
 *
 * Features:
 *   - Firebase Auth required (unauthenticated requests rejected)
 *   - Ownership check (customer can only resend their own ticket)
 *   - Rate limiting: 30-second cooldown between resend attempts
 *   - Resets emailSent=false and calls the v2 orchestrator
 *   - Structured logging
 *
 * Flutter call:
 *   final fn  = FirebaseFunctions.instance.httpsCallable('resendTicketEmail');
 *   final res = await fn.call({'ticketId': ticketId});
 */

"use strict";

const functions                    = require("firebase-functions");
const admin                        = require("firebase-admin");
const { sendTicketConfirmationEmail } = require("./emailNotification");

const db         = admin.firestore();
const FieldValue = admin.firestore.FieldValue;

const RATE_LIMIT_MS = 30_000; // 30 seconds

exports.resendTicketEmail = functions.https.onCall(async (data, context) => {

  // ── Auth guard ─────────────────────────────────────────────────────────────
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "You must be logged in to resend a ticket."
    );
  }

  // ── Input validation ───────────────────────────────────────────────────────
  const { ticketId } = data || {};
  if (!ticketId || typeof ticketId !== "string") {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "ticketId is required and must be a string."
    );
  }

  functions.logger.info("[ResendTicket] Request received", {
    ticketId,
    uid: context.auth.uid,
  });

  // ── Fetch ticket ───────────────────────────────────────────────────────────
  const ticketRef  = db.collection("tickets").doc(ticketId);
  const ticketSnap = await ticketRef.get();

  if (!ticketSnap.exists) {
    throw new functions.https.HttpsError("not-found", "Ticket not found.");
  }

  const ticket = ticketSnap.data();

  // ── Ownership check ────────────────────────────────────────────────────────
  if (ticket.customerId !== context.auth.uid) {
    functions.logger.warn("[ResendTicket] Ownership check failed", {
      ticketId,
      requestUid:  context.auth.uid,
      ticketOwner: ticket.customerId,
    });
    throw new functions.https.HttpsError(
      "permission-denied",
      "You do not have permission to resend this ticket."
    );
  }

  // ── Rate limit ─────────────────────────────────────────────────────────────
  const lastAttempt = ticket.lastEmailAttemptAt?.toDate?.() || null;
  if (lastAttempt && (Date.now() - lastAttempt.getTime()) < RATE_LIMIT_MS) {
    const secondsLeft = Math.ceil((RATE_LIMIT_MS - (Date.now() - lastAttempt.getTime())) / 1000);
    functions.logger.warn("[ResendTicket] Rate limited", { ticketId, secondsLeft });
    throw new functions.https.HttpsError(
      "resource-exhausted",
      `Please wait ${secondsLeft} seconds before resending.`
    );
  }

  // ── Block if currently processing ─────────────────────────────────────────
  if (ticket.emailProcessing === true) {
    throw new functions.https.HttpsError(
      "already-exists",
      "Email is already being processed. Please wait a moment and try again."
    );
  }

  // ── Reset flags and re-trigger ────────────────────────────────────────────
  functions.logger.info("[ResendTicket] Resetting flags and triggering email", { ticketId });

  await ticketRef.update({
    emailSent:       false,
    emailProcessing: false,
    emailError:      FieldValue.delete(),
  });

  // Re-fetch updated ticket data for the orchestrator
  const updatedSnap   = await ticketRef.get();
  const updatedTicket = updatedSnap.data();

  // Call orchestrator (awaited so caller gets final success/fail)
  await sendTicketConfirmationEmail(updatedTicket, ticketId, "manual_resend");

  // Check final status
  const finalSnap = await ticketRef.get();
  const finalData = finalSnap.data();

  if (finalData?.notificationStatus === "email_failed") {
    functions.logger.error("[ResendTicket] Email failed after resend attempt", { ticketId });
    throw new functions.https.HttpsError(
      "internal",
      "Failed to resend the ticket email. Please try again later."
    );
  }

  functions.logger.info("[ResendTicket] ✅ Ticket email resent successfully", { ticketId });
  return {
    success:  true,
    message:  "Ticket email resent successfully. Check your inbox.",
    pdfUrl:   finalData?.ticketPdfUrl || null,
  };
});
