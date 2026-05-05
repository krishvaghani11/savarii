/**
 * pushFallback.js — Backup push notification when email delivery fails.
 *
 * v3 Feature #2: If email fails or hits permanent failure, send FCM push
 * notification to the customer's device as a reliable fallback.
 *
 * Exports:
 *   sendTicketPushFallback(booking, ticketId) → Promise<void>
 *
 * Payload includes a deep-link to the ticket screen so the user can
 * view their booking without needing the email.
 */

"use strict";

const functions   = require("firebase-functions");
const { sendToUser } = require("./fcm");

/**
 * Sends a backup FCM push notification to the customer when email fails.
 * Uses the existing sendToUser infrastructure (token lookup + retry + logging).
 *
 * @param {Object} booking   — Firestore ticket document data
 * @param {string} ticketId  — Firestore document ID
 */
async function sendTicketPushFallback(booking, ticketId) {
  const customerId = booking.customerId;

  if (!customerId) {
    functions.logger.warn("[PushFallback] No customerId found — cannot send push.", { ticketId });
    return;
  }

  const bookingId = booking.bookingId || ticketId;
  const from      = booking.fromLocation || "origin";
  const to        = booking.toLocation   || "destination";
  const pnr       = booking.pnr          || bookingId;

  functions.logger.info("[PushFallback] Sending fallback push notification.", {
    customerId, ticketId, bookingId,
  });

  try {
    await sendToUser(customerId, "customer", {
      type:     "ticket_email_fallback",
      title:    "Your ticket is confirmed 🎉",
      body:     `${from} → ${to}. PNR: ${pnr}. Tap to view your ticket.`,
      priority: "critical",   // ensures heads-up display on Android + iOS
      data: {
        // Deep-link data — Flutter reads these to navigate to ticket screen
        screen:    "ticket_detail",
        ticketId,
        bookingId,
        pnr,
        // pdfUrl included if already uploaded — allows in-app PDF view
        pdfUrl:    booking.ticketPdfUrl || "",
      },
    });

    functions.logger.info("[PushFallback] ✅ Fallback push sent.", { customerId, ticketId });
  } catch (err) {
    // Never crash the caller — fallback is best-effort
    functions.logger.error("[PushFallback] ❌ Failed to send fallback push.", {
      customerId,
      ticketId,
      error: err.message,
    });
  }
}

module.exports = { sendTicketPushFallback };
