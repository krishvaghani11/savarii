/**
 * storageService.js — Firebase Storage helper for ticket PDFs.
 *
 * Exports:
 *   uploadTicketPdf(bookingId, pdfBuffer) → Promise<string>  (download URL)
 *
 * Storage path: tickets/{bookingId}.pdf
 *
 * Strategy:
 *   1. Upload buffer with public read metadata via a download token.
 *   2. Return a permanent download URL (no expiry issues for passengers).
 */

"use strict";

const admin = require("firebase-admin");
const { v4: uuidv4 } = require("uuid");

/**
 * Uploads a PDF buffer to Firebase Storage and returns a permanent public URL.
 * @param {string} bookingId
 * @param {Buffer} pdfBuffer
 * @returns {Promise<string>} Permanent download URL
 */
async function uploadTicketPdf(bookingId, pdfBuffer) {
  const bucket   = admin.storage().bucket();
  const filePath = `tickets/${bookingId}.pdf`;
  const file     = bucket.file(filePath);

  // A download token makes the URL permanent (no expiry)
  const downloadToken = uuidv4();

  await file.save(pdfBuffer, {
    metadata: {
      contentType: "application/pdf",
      metadata: {
        firebaseStorageDownloadTokens: downloadToken,
      },
    },
  });

  // Build the permanent download URL
  const encodedPath = encodeURIComponent(filePath);
  const bucketName  = bucket.name;
  const url =
    `https://firebasestorage.googleapis.com/v0/b/${bucketName}/o/` +
    `${encodedPath}?alt=media&token=${downloadToken}`;

  return url;
}

module.exports = { uploadTicketPdf };
