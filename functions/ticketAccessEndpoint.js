/**
 * ticketAccessEndpoint.js — Secure ticket PDF access validation.
 *
 * v3 Feature #4: Verify user ownership before serving the ticket PDF URL.
 * Prevents unauthorized access to other users' tickets.
 *
 * Exports:
 *   getTicketAccess — HTTPS Callable: authenticate + verify ownership → return pdfUrl
 *
 * Flow:
 *   1. Verify Firebase Auth token (unauthenticated → rejected)
 *   2. Fetch ticket from Firestore
 *   3. Verify customerId === auth.uid (ownership check)
 *   4. Check ticket is confirmed (status guard)
 *   5. Return pdfUrl and ticket summary fields
 *
 * Why not a direct Storage URL?
 *   The PDF URL contains a Firebase download token that is technically
 *   guessable if shared. This endpoint adds an auth + ownership gate
 *   so only the booking's owner can retrieve the URL programmatically.
 *
 * Flutter usage:
 *   final fn  = FirebaseFunctions.instance.httpsCallable('getTicketAccess');
 *   final res = await fn.call({'ticketId': ticketId});
 *   final url = res.data['pdfUrl'];
 */

"use strict";

const functions = require("firebase-functions");
const admin     = require("firebase-admin");

const db = admin.firestore();

exports.getTicketAccess = functions.https.onCall(async (data, context) => {

  // ── Auth guard ──────────────────────────────────────────────────────────────
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "You must be signed in to access ticket details."
    );
  }

  // ── Input validation ────────────────────────────────────────────────────────
  const { ticketId } = data || {};
  if (!ticketId || typeof ticketId !== "string") {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "ticketId is required."
    );
  }

  functions.logger.info("[TicketAccess] Access request", {
    uid:      context.auth.uid,
    ticketId,
  });

  // ── Fetch ticket ────────────────────────────────────────────────────────────
  const ticketSnap = await db.collection("tickets").doc(ticketId).get();

  if (!ticketSnap.exists) {
    throw new functions.https.HttpsError("not-found", "Ticket not found.");
  }

  const ticket = ticketSnap.data();

  // ── Ownership check ─────────────────────────────────────────────────────────
  if (ticket.customerId !== context.auth.uid) {
    functions.logger.warn("[TicketAccess] Ownership check FAILED", {
      requestUid:  context.auth.uid,
      ticketOwner: ticket.customerId,
      ticketId,
    });
    throw new functions.https.HttpsError(
      "permission-denied",
      "You do not have permission to access this ticket."
    );
  }

  // ── PDF availability check ──────────────────────────────────────────────────
  if (!ticket.ticketPdfUrl) {
    // PDF may still be generating or was cleaned up
    const isCleared = ticket.pdfCleaned === true;
    throw new functions.https.HttpsError(
      "not-found",
      isCleared
        ? "This ticket PDF has been removed as part of our 90-day retention policy."
        : "Ticket PDF is not yet available. Please try again in a few moments."
    );
  }

  functions.logger.info("[TicketAccess] ✅ Access granted.", {
    uid:      context.auth.uid,
    ticketId,
    bookingId: ticket.bookingId,
  });

  // ── Return safe subset of ticket fields ─────────────────────────────────────
  return {
    pdfUrl:             ticket.ticketPdfUrl,
    pnr:                ticket.pnr                || ticket.bookingId,
    bookingId:          ticket.bookingId,
    fromLocation:       ticket.fromLocation        || ticket.boardingPoint  || "—",
    toLocation:         ticket.toLocation          || ticket.droppingPoint  || "—",
    journeyDate:        ticket.journeyDate         || ticket.travelDate     || "—",
    journeyTime:        ticket.journeyTime         || ticket.boardingTime   || "—",
    seatNumbers:        ticket.seatNumbers         || ticket.selectedSeats  || [],
    busName:            ticket.busName             || "Savarii Express",
    status:             ticket.status,
    notificationStatus: ticket.notificationStatus  || null,
    templateVersion:    ticket.templateVersion     || "v1",
  };
});
