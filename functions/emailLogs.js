/**
 * emailLogs.js — Structured analytics logger for the email system.
 *
 * Writes a document to the `emailLogs` Firestore collection after
 * every email attempt (success, failure, or skip).
 *
 * Collection: emailLogs/{auto-id}
 * Schema:
 *   bookingId      string
 *   ticketId       string
 *   email          string
 *   status         "success" | "failure" | "skipped"
 *   errorMessage   string | null
 *   retryCount     number
 *   templateVersion string
 *   resendId       string | null
 *   triggeredBy    "trigger" | "manual_resend" | "queue_worker"
 *   timestamp      Timestamp
 */

"use strict";

const admin     = require("firebase-admin");
const functions = require("firebase-functions");

const db         = admin.firestore();
const FieldValue = admin.firestore.FieldValue;

/**
 * Writes a structured log entry to the emailLogs collection.
 * This function is SAFE — it never throws. All errors are swallowed
 * so that logging never breaks the main email flow.
 *
 * @param {Object} opts
 * @param {string}      opts.bookingId
 * @param {string}      opts.ticketId
 * @param {string}      opts.email
 * @param {"success"|"failure"|"skipped"} opts.status
 * @param {string|null} [opts.errorMessage]
 * @param {number}      [opts.retryCount]
 * @param {string}      [opts.templateVersion]
 * @param {string|null} [opts.resendId]
 * @param {"trigger"|"manual_resend"|"queue_worker"} [opts.triggeredBy]
 */
async function writeEmailLog({
  bookingId,
  ticketId,
  email,
  status,
  errorMessage   = null,
  retryCount     = 0,
  templateVersion = "v1",
  resendId       = null,
  triggeredBy    = "trigger",
}) {
  try {
    await db.collection("emailLogs").add({
      bookingId:       bookingId || null,
      ticketId:        ticketId  || null,
      email:           email     || null,
      status,
      errorMessage,
      retryCount,
      templateVersion,
      resendId,
      triggeredBy,
      timestamp: FieldValue.serverTimestamp(),
    });

    functions.logger.info("[EmailLogs] Log entry written", {
      ticketId, status, triggeredBy,
    });
  } catch (err) {
    // Best-effort — log to console but never crash caller
    functions.logger.warn("[EmailLogs] Failed to write log entry", {
      ticketId,
      message: err.message,
    });
  }
}

module.exports = { writeEmailLog };
