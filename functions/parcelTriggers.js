"use strict";

const functions = require("firebase-functions");
const admin = require("firebase-admin");
const { sendParcelConfirmationEmail } = require("./emailService");

const db = admin.firestore();

/**
 * onParcelCreated
 * Triggered when a new parcel is booked.
 * Sends a confirmation email to the sender.
 */
exports.onParcelCreated = functions.firestore
  .document("parcels/{parcelId}")
  .onCreate(async (snap, context) => {
    const parcel = snap.data();
    const { parcelId } = context.params;

    if (!parcel) return;

    // Use the sender email captured in the Flutter app
    // In our implementation, we saved it under the 'email' key specifically for the server trigger
    const email = parcel.email || parcel.senderEmail;

    if (!email) {
      functions.logger.warn(`[ParcelTrigger] parcelId=${parcelId} has no sender email. Skipping email.`);
      return;
    }

    try {
      functions.logger.info(`[ParcelTrigger] Sending confirmation email to ${email} for trackingId=${parcel.trackingId}`);
      
      await sendParcelConfirmationEmail(parcel, email);

      // Update the document to mark email as sent
      await snap.ref.update({
        emailSent: true,
        emailSentAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      functions.logger.info(`[ParcelTrigger] Email sent successfully for parcelId=${parcelId}`);
    } catch (error) {
      functions.logger.error(`[ParcelTrigger] Failed to send email for parcelId=${parcelId}`, error);
      
      // Update with error for debugging
      await snap.ref.update({
        emailError: error.message,
        emailFailedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }
  });
