"use strict";

const functions = require("firebase-functions");
const admin = require("firebase-admin");
const { sendWalletTopupEmail } = require("./emailService");

const db = admin.firestore();

/**
 * onWalletTopupCreated
 * Triggered when a user adds money to their wallet.
 * Sends a confirmation email via Resend.
 */
exports.onWalletTopupCreated = functions.firestore
  .document("wallet_transactions/{userId}/wallet_topup/{txnId}")
  .onCreate(async (snap, context) => {
    const transaction = snap.data();
    const { userId, txnId } = context.params;

    if (!transaction) return;

    // Only send if it's a completed top-up
    if (transaction.status !== "Completed") {
      functions.logger.info(`[WalletTrigger] txnId=${txnId} status is not Completed. Skipping email.`);
      return;
    }

    const email = transaction.email;
    if (!email) {
      functions.logger.warn(`[WalletTrigger] txnId=${txnId} has no email address. Skipping email.`);
      return;
    }

    try {
      functions.logger.info(`[WalletTrigger] Sending top-up email to ${email} for amount ₹${transaction.amount}`);
      
      await sendWalletTopupEmail(transaction, email);

      // Update the document to mark email as sent
      await snap.ref.update({
        emailSent: true,
        emailSentAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      functions.logger.info(`[WalletTrigger] Email sent successfully for txnId=${txnId}`);
    } catch (error) {
      functions.logger.error(`[WalletTrigger] Failed to send email for txnId=${txnId}`, error);
      
      // Update with error for debugging
      await snap.ref.update({
        emailError: error.message,
        emailFailedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }
  });
