/**
 * storageCleanup.js — Scheduled Cloud Function to purge old ticket PDFs.
 *
 * v3 Feature #5: Delete PDFs older than 90 days from Firebase Storage
 * to control storage costs. Runs daily at 2:00 AM IST (20:30 UTC).
 *
 * Exports:
 *   cleanupOldTicketPdfs — Scheduled Cloud Function
 *
 * Strategy:
 *   1. Query Firestore tickets where createdAt < (now - 90 days)
 *      AND ticketPdfUrl is set (meaning a PDF was uploaded)
 *   2. For each stale ticket:
 *      a. Delete the PDF from Firebase Storage (tickets/{bookingId}.pdf)
 *      b. Update Firestore: remove ticketPdfUrl, set pdfCleaned=true
 *   3. Log summary (deleted count, error count)
 *
 * Safety:
 *   - Processes in batches of 50 to avoid memory pressure
 *   - Each deletion is isolated — one failure does not stop others
 *   - Firestore document is only updated AFTER successful storage deletion
 */

"use strict";

const functions  = require("firebase-functions");
const admin      = require("firebase-admin");

const db         = admin.firestore();
const FieldValue = admin.firestore.FieldValue;

const RETENTION_DAYS  = 90;
const BATCH_SIZE      = 50;
const STORAGE_PREFIX  = "tickets/";

/**
 * Derives the Firebase Storage file path from a ticket document.
 * Path format: tickets/{bookingId}.pdf
 *
 * @param {Object} ticketData
 * @param {string} ticketId
 * @returns {string}
 */
function _deriveStoragePath(ticketData, ticketId) {
  const bookingId = ticketData.bookingId || ticketId;
  return `${STORAGE_PREFIX}${bookingId}.pdf`;
}

/**
 * Deletes a single file from Firebase Storage.
 * Returns true on success, false if file not found (already deleted).
 * Throws on other errors.
 *
 * @param {string} filePath
 * @returns {Promise<boolean>}
 */
async function _deleteStorageFile(filePath) {
  const bucket = admin.storage().bucket();
  const file   = bucket.file(filePath);
  try {
    await file.delete();
    return true;
  } catch (err) {
    // 404 = already deleted — treat as success
    if (err.code === 404 || err.message?.includes("No such object")) return false;
    throw err;
  }
}

/**
 * Scheduled Cloud Function — runs daily at 02:00 IST (20:30 UTC).
 */
const cleanupOldTicketPdfs = functions.pubsub
  .schedule("30 20 * * *")   // 20:30 UTC = 02:00 IST
  .timeZone("UTC")
  .onRun(async () => {
    functions.logger.info("[StorageCleanup] Starting daily PDF cleanup...");

    const cutoffDate = new Date(Date.now() - RETENTION_DAYS * 24 * 60 * 60 * 1000);
    functions.logger.info(`[StorageCleanup] Retention cutoff: ${cutoffDate.toISOString()} (${RETENTION_DAYS} days ago)`);

    let deletedCount = 0;
    let errorCount   = 0;
    let lastDoc      = null;  // for pagination

    try {
      while (true) {
        // Build paginated query
        let query = db.collection("tickets")
          .where("createdAt", "<", cutoffDate)
          .where("ticketPdfUrl", "!=", "")   // only tickets with an uploaded PDF
          .orderBy("createdAt", "asc")
          .limit(BATCH_SIZE);

        if (lastDoc) query = query.startAfter(lastDoc);

        const snap = await query.get();
        if (snap.empty) break;  // no more stale tickets

        functions.logger.info(`[StorageCleanup] Processing batch of ${snap.size} tickets...`);

        for (const doc of snap.docs) {
          const ticketData = doc.data();
          const ticketId   = doc.id;
          const filePath   = _deriveStoragePath(ticketData, ticketId);

          try {
            const deleted = await _deleteStorageFile(filePath);

            if (deleted) {
              functions.logger.info(`[StorageCleanup] Deleted: ${filePath}`);
            } else {
              functions.logger.info(`[StorageCleanup] Already gone: ${filePath}`);
            }

            // Update Firestore regardless (file is gone either way)
            await doc.ref.update({
              ticketPdfUrl: FieldValue.delete(),
              pdfCleaned:   true,
              pdfCleanedAt: FieldValue.serverTimestamp(),
            });

            deletedCount++;
          } catch (err) {
            errorCount++;
            functions.logger.error(`[StorageCleanup] Failed for ticketId=${ticketId}`, {
              filePath,
              error: err.message,
            });
            // Continue — don't let one failure stop the whole batch
          }
        }

        lastDoc = snap.docs[snap.docs.length - 1];

        // Stop if this was a partial batch (last page)
        if (snap.size < BATCH_SIZE) break;
      }
    } catch (outerErr) {
      functions.logger.error("[StorageCleanup] Fatal error in cleanup loop.", {
        error: outerErr.message,
      });
    }

    functions.logger.info("[StorageCleanup] ✅ Cleanup complete.", {
      deleted:    deletedCount,
      errors:     errorCount,
      cutoffDate: cutoffDate.toISOString(),
    });
  });

module.exports = { cleanupOldTicketPdfs };
