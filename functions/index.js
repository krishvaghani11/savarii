/**
 * Savarii Cloud Functions — index.js
 *
 * Exports:
 *   forgotPassword       — HTTP: password reset email via Resend
 *   onBookingCreated     — Firestore: booking_confirmed + new_booking_received
 *   onBookingStatusChanged — Firestore: cancellation, payment, refund events
 *   onDriverAssigned     — Firestore: driver_assigned to all roles
 *   onLiveTrackingUpdate — RTDB: bus_arriving_soon + drop_point_approaching
 *   onDriverStatusChanged — Firestore: driver_offline_alert
 *   onUnexpectedLongStop — Scheduled (5 min): unexpected_long_stop
 */

"use strict";

const functions = require("firebase-functions");
const admin = require("firebase-admin");
const cors = require("cors");
const { Resend } = require("resend");
const { buildResetEmailHtml } = require("./emailTemplate");

// Initialise Firebase Admin (uses the service account automatically in Cloud Functions)
admin.initializeApp();

// ── Notification triggers ─────────────────────────────────────────────────────
const bookingTriggers = require("./bookingTriggers");
const trackingTriggers = require("./trackingTriggers");

// Booking lifecycle
exports.onBookingCreated = bookingTriggers.onBookingCreated;
exports.onBookingStatusChanged = bookingTriggers.onBookingStatusChanged;
exports.onDriverAssigned = bookingTriggers.onDriverAssigned;
exports.onBusStatusChanged = bookingTriggers.onBusStatusChanged;
exports.onTripReminders = bookingTriggers.onTripReminders;

// Live tracking
exports.onLiveTrackingUpdate = trackingTriggers.onLiveTrackingUpdate;
exports.onDriverStatusChanged = trackingTriggers.onDriverStatusChanged;
exports.onFleetHealthCheck = trackingTriggers.onFleetHealthCheck;

// CORS — accept requests from any origin (Flutter mobile clients)
const corsHandler = cors({ origin: true });

// ──────────────────────────────────────────────────────────────────────────────
// In-memory rate limiter
// NOTE: Works per function instance. Good enough for typical traffic.
//       For strict multi-instance rate limiting use Firestore or Redis.
// ──────────────────────────────────────────────────────────────────────────────
const RATE_WINDOW_MS = 15 * 60 * 1000; // 15 minutes
const RATE_MAX_REQUESTS = 5;
const ipLog = new Map(); // ip -> [timestamp, ...]

/**
 * Returns true if this IP has exceeded the rate limit.
 * @param {string} ip
 * @returns {boolean}
 */
function isRateLimited(ip) {
  const now = Date.now();
  const timestamps = (ipLog.get(ip) || []).filter(
    (t) => now - t < RATE_WINDOW_MS
  );
  timestamps.push(now);
  ipLog.set(ip, timestamps);
  return timestamps.length > RATE_MAX_REQUESTS;
}

// ──────────────────────────────────────────────────────────────────────────────
// Email validation
// ──────────────────────────────────────────────────────────────────────────────
const EMAIL_REGEX = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

// ──────────────────────────────────────────────────────────────────────────────
// Allowed roles
// ──────────────────────────────────────────────────────────────────────────────
const VALID_ROLES = ["customer", "vendor", "driver"];

// ──────────────────────────────────────────────────────────────────────────────
// Firebase password-reset ActionCodeSettings
// ──────────────────────────────────────────────────────────────────────────────
const ACTION_CODE_SETTINGS = {
  url: "https://savarii.co.in/login", // Deep-link after password is reset
  handleCodeInApp: false,             // Opens in browser (not inside the app)
};

// Generic response — always sent on success OR when user not found
// This prevents attackers from discovering which emails are registered.
const GENERIC_SUCCESS_RESPONSE = {
  success: true,
  message:
    "If your email is registered with Savarii, a password reset link has been sent. Please check your inbox (and spam folder).",
};

// ──────────────────────────────────────────────────────────────────────────────
// Cloud Function: forgotPassword
// Deployed URL (gen1):
//   https://us-central1-savarii-96869.cloudfunctions.net/forgotPassword
// ──────────────────────────────────────────────────────────────────────────────
exports.forgotPassword = functions.https.onRequest((req, res) => {
  // Wrap everything with CORS so Flutter's http package can call it
  corsHandler(req, res, async () => {
    // ── Method guard ──────────────────────────────────────────────────────────
    if (req.method !== "POST") {
      return res
        .status(405)
        .json({ success: false, message: "Method not allowed." });
    }

    // ── Rate limit ────────────────────────────────────────────────────────────
    const clientIp =
      req.ip ||
      (req.headers["x-forwarded-for"] || "").split(",")[0].trim() ||
      "unknown";

    if (isRateLimited(clientIp)) {
      functions.logger.warn("[ForgotPassword] Rate limit exceeded", { ip: clientIp });
      return res.status(429).json({
        success: false,
        message: "Too many requests. Please wait a few minutes and try again.",
      });
    }

    // ── Parse & sanitize body ─────────────────────────────────────────────────
    const rawEmail = (req.body && req.body.email) || "";
    const rawRole = (req.body && req.body.role) || "";

    const email = rawEmail.trim().toLowerCase();
    const role = rawRole.trim().toLowerCase();

    // ── Validate email ────────────────────────────────────────────────────────
    if (!email || !EMAIL_REGEX.test(email)) {
      return res.status(400).json({
        success: false,
        message: "Please enter a valid email address.",
      });
    }

    // ── Validate role ─────────────────────────────────────────────────────────
    if (!role || !VALID_ROLES.includes(role)) {
      return res.status(400).json({
        success: false,
        message: `Role must be one of: ${VALID_ROLES.join(", ")}.`,
      });
    }

    // ── Core logic ────────────────────────────────────────────────────────────
    try {
      // Step 1: Generate password-reset link via Firebase Admin SDK
      // Uses generatePasswordResetLink (NOT sendPasswordResetEmail) so we
      // control the email delivery entirely.
      const resetLink = await admin
        .auth()
        .generatePasswordResetLink(email, ACTION_CODE_SETTINGS);

      // Step 2: Send branded email via Resend
      const resend = new Resend(process.env.RESEND_API_KEY);

      const sendResult = await resend.emails.send({
        from: "Savarii <support@savarii.co.in>",
        to: email,
        subject: "Reset your Savarii password",
        html: buildResetEmailHtml(resetLink, role),
      });

      if (sendResult.error) {
        // Resend returned an API-level error
        functions.logger.error("[ForgotPassword] Resend error", sendResult.error);
        return res.status(500).json({
          success: false,
          message: "Failed to send reset email. Please try again later.",
        });
      }

      functions.logger.info("[ForgotPassword] Reset email sent", {
        role,
        emailId: sendResult.data?.id,
      });

      return res.status(200).json(GENERIC_SUCCESS_RESPONSE);

    } catch (error) {
      // ── Handle Firebase Auth errors ─────────────────────────────────────────
      const code = error.errorInfo?.code || error.code || "";

      if (
        code === "auth/user-not-found" ||
        code === "auth/invalid-email" ||
        code === "auth/email-not-found"
      ) {
        // Silently succeed — do NOT tell the client the email doesn't exist
        functions.logger.info("[ForgotPassword] No account for email (hidden from client)", {
          role,
        });
        return res.status(200).json(GENERIC_SUCCESS_RESPONSE);
      }

      // Unexpected error
      functions.logger.error("[ForgotPassword] Unexpected error", {
        message: error.message,
        code,
      });

      return res.status(500).json({
        success: false,
        message: "An unexpected error occurred. Please try again later.",
      });
    }
  });
});
