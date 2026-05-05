/**
 * monitoringService.js — Real-time failure rate monitoring and alerting.
 *
 * v3 Feature #3: Detect high email failure rates and alert admin via
 * Resend email and/or Slack webhook.
 *
 * Exports:
 *   checkEmailFailureRate()           → Promise<void>  (called after each failure)
 *   onEmailFailureRateCheck           — Scheduled Cloud Function (every 5 minutes)
 *
 * Strategy:
 *   - Count emailLogs where status=failure in the last 5 minutes
 *   - If count >= ALERT_THRESHOLD → send alert (email + Slack)
 *   - Deduplication: track last alert time in Firestore to avoid spam
 *
 * Environment:
 *   RESEND_API_KEY          — Resend API key (already present)
 *   SLACK_WEBHOOK_URL       — Slack incoming webhook URL (optional)
 *   ADMIN_ALERT_EMAIL       — Admin email address for alerts
 */

"use strict";

const functions   = require("firebase-functions");
const admin       = require("firebase-admin");
const { Resend }  = require("resend");

const db         = admin.firestore();
const FieldValue = admin.firestore.FieldValue;

// ─── Alert Configuration ──────────────────────────────────────────────────────
const MONITOR_WINDOW_MINUTES = 5;              // sliding window
const ALERT_THRESHOLD        = 10;             // failures in window → alert
const ALERT_COOLDOWN_MS      = 30 * 60 * 1000; // 30-minute cooldown between alerts
const ADMIN_EMAIL            = process.env.ADMIN_ALERT_EMAIL || "admin@savarii.co.in";
const MONITORING_DOC         = "system/emailMonitoring";

// ─── Internal helpers ─────────────────────────────────────────────────────────

/**
 * Counts email failures in the past N minutes from emailLogs collection.
 * @returns {Promise<number>}
 */
async function _countRecentFailures() {
  const windowStart = new Date(Date.now() - MONITOR_WINDOW_MINUTES * 60 * 1000);
  const snap = await db.collection("emailLogs")
    .where("status",    "==",  "failure")
    .where("timestamp", ">=",  windowStart)
    .get();
  return snap.size;
}

/**
 * Checks if we are in alert cooldown (prevents alert spam).
 * @returns {Promise<boolean>} true if we should NOT send an alert yet
 */
async function _isInCooldown() {
  try {
    const snap = await db.doc(MONITORING_DOC).get();
    if (!snap.exists) return false;
    const lastAlert = snap.data()?.lastAlertAt?.toDate?.() || null;
    return lastAlert && (Date.now() - lastAlert.getTime()) < ALERT_COOLDOWN_MS;
  } catch {
    return false;
  }
}

/**
 * Records the current time as the last alert timestamp.
 */
async function _recordAlertSent(failureCount) {
  await db.doc(MONITORING_DOC).set({
    lastAlertAt:         FieldValue.serverTimestamp(),
    lastFailureCount:    failureCount,
    lastAlertWindow:     `${MONITOR_WINDOW_MINUTES} minutes`,
  }, { merge: true });
}

/**
 * Sends an alert email to admin via Resend.
 * @param {number} failureCount
 */
async function _sendAlertEmail(failureCount) {
  try {
    if (!process.env.RESEND_API_KEY) return;
    const resend = new Resend(process.env.RESEND_API_KEY);
    await resend.emails.send({
      from:    "Savarii Monitoring <support@savarii.co.in>",
      to:      ADMIN_EMAIL,
      subject: `🚨 Savarii Alert: ${failureCount} email failures in ${MONITOR_WINDOW_MINUTES} minutes`,
      html: `
        <div style="font-family:sans-serif;max-width:500px;margin:auto;padding:24px">
          <h2 style="color:#dc2626">🚨 Email System Alert</h2>
          <p><strong>${failureCount} ticket confirmation emails</strong> failed in the last
          <strong>${MONITOR_WINDOW_MINUTES} minutes</strong>.</p>
          <p>Threshold: ${ALERT_THRESHOLD} failures / ${MONITOR_WINDOW_MINUTES} min</p>
          <hr/>
          <p>Check the <strong>emailLogs</strong> Firestore collection for details.</p>
          <p>Timestamp: ${new Date().toISOString()}</p>
        </div>
      `,
    });
    functions.logger.info("[Monitoring] Alert email sent to admin.", { failureCount });
  } catch (err) {
    functions.logger.warn("[Monitoring] Failed to send alert email.", { error: err.message });
  }
}

/**
 * Sends an alert to Slack via incoming webhook.
 * @param {number} failureCount
 */
async function _sendSlackAlert(failureCount) {
  const webhookUrl = process.env.SLACK_WEBHOOK_URL;
  if (!webhookUrl) return;

  try {
    const payload = JSON.stringify({
      text: `🚨 *Savarii Email Alert*\n*${failureCount}* ticket confirmation emails failed in the last *${MONITOR_WINDOW_MINUTES} minutes* (threshold: ${ALERT_THRESHOLD}).\nCheck Firebase Console → Firestore → \`emailLogs\` for details.\nTimestamp: ${new Date().toISOString()}`,
    });

    // Use node's built-in https to avoid new dependencies
    const https = require("https");
    const url   = new URL(webhookUrl);

    await new Promise((resolve, reject) => {
      const req = https.request({
        hostname: url.hostname,
        path:     url.pathname + url.search,
        method:   "POST",
        headers:  { "Content-Type": "application/json", "Content-Length": Buffer.byteLength(payload) },
      }, (res) => {
        res.on("data", () => {});
        res.on("end", resolve);
      });
      req.on("error", reject);
      req.write(payload);
      req.end();
    });

    functions.logger.info("[Monitoring] Slack alert sent.", { failureCount });
  } catch (err) {
    functions.logger.warn("[Monitoring] Failed to send Slack alert.", { error: err.message });
  }
}

// ─── Public API ───────────────────────────────────────────────────────────────

/**
 * Called after every email failure to check the sliding-window failure rate.
 * Fires alerts if the threshold is crossed and cooldown has elapsed.
 * Never throws — safe to call in any context.
 */
async function checkEmailFailureRate() {
  try {
    const failureCount = await _countRecentFailures();

    functions.logger.info("[Monitoring] Recent failure count:", {
      count: failureCount,
      threshold: ALERT_THRESHOLD,
      windowMinutes: MONITOR_WINDOW_MINUTES,
    });

    if (failureCount < ALERT_THRESHOLD) return;

    // Check cooldown before firing alert
    if (await _isInCooldown()) {
      functions.logger.info("[Monitoring] Alert suppressed (cooldown active).", { failureCount });
      return;
    }

    // Fire alerts
    functions.logger.error("[Monitoring] 🚨 ALERT THRESHOLD REACHED", {
      failureCount, threshold: ALERT_THRESHOLD, windowMinutes: MONITOR_WINDOW_MINUTES,
    });

    await Promise.allSettled([
      _sendAlertEmail(failureCount),
      _sendSlackAlert(failureCount),
      _recordAlertSent(failureCount),
    ]);

  } catch (err) {
    functions.logger.warn("[Monitoring] checkEmailFailureRate threw:", { error: err.message });
  }
}

/**
 * Scheduled Cloud Function: Proactive health check every 5 minutes.
 * Runs independently of email triggers — catches burst failures
 * even when individual failure checks might miss the window.
 */
const onEmailHealthCheck = functions.pubsub
  .schedule("every 5 minutes")
  .onRun(async () => {
    functions.logger.info("[Monitoring] Running scheduled email health check...");
    await checkEmailFailureRate();
  });

module.exports = { checkEmailFailureRate, onEmailHealthCheck };
