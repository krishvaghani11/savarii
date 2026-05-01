/**
 * fcm.js — Shared FCM utilities for all Savarii notification triggers.
 *
 * Public API:
 *   sendToUser(uid, role, payload)   — Send to one user by UID + role.
 *   sendToMany(recipients, payload)  — Bulk send (parallel, allSettled).
 *   logNotification(uid, role, payload) — Write to notifications/ history.
 *   isIdempotent(eventId)            — Check / mark Cloud Function event IDs.
 *
 * Role → Firestore collection:
 *   customer → users/{uid}
 *   vendor   → vendors/{uid}
 *   driver   → drivers/{uid}
 *
 * Payload shape:
 *   {
 *     type:      string,          // e.g. 'booking_confirmed'
 *     title:     string,
 *     body:      string,
 *     data?:     Object,          // extra key/value pairs
 *     priority?: 'critical' | 'normal',  // default: 'normal'
 *   }
 */

"use strict";

const admin = require("firebase-admin");
const functions = require("firebase-functions");

// ─── Priority / channel config ───────────────────────────────────────────────

/**
 * Maps notification types to their priority class.
 * 'critical' → high-importance channel, time-sensitive iOS, short TTL default.
 * 'normal'   → default channel.
 */
const CRITICAL_TYPES = new Set([
  "booking_confirmed",
  "bus_arriving_soon",
  "drop_point_approaching",
  "driver_offline_alert",
  "ticket_cancelled",
  "payment_failure",
  "trip_cancelled_by_vendor",
  "vehicle_breakdown_alert",
  "bus_reached_boarding_point",
]);

/** TTL in seconds per notification type. FCM max = 4 weeks (2419200 s). */
const TTL_BY_TYPE = {
  bus_arriving_soon:      5 * 60,          // 5 minutes — stale = useless
  drop_point_approaching: 5 * 60,          // 5 minutes
  driver_offline_alert:   15 * 60,         // 15 minutes
  booking_confirmed:      24 * 60 * 60,    // 24 hours
  ticket_cancelled:       24 * 60 * 60,    // 24 hours
  payment_success:        24 * 60 * 60,    // 24 hours
  payment_failure:        24 * 60 * 60,    // 24 hours
  refund_processed:       24 * 60 * 60,    // 24 hours
  new_booking_received:   6 * 60 * 60,     // 6 hours
  driver_assigned:        6 * 60 * 60,     // 6 hours
  unexpected_long_stop:   30 * 60,         // 30 minutes
  trip_cancelled_by_vendor: 24 * 60 * 60,  // 24 hours
  vehicle_breakdown_alert: 6 * 60 * 60,    // 6 hours
  bus_reached_boarding_point: 5 * 60,      // 5 minutes
  boarding_point_nearby: 10 * 60,          // 10 minutes
  driver_late_start_alert: 30 * 60,        // 30 minutes
  passenger_waiting_alert: 5 * 60,         // 5 minutes
};
const TTL_DEFAULT = 4 * 7 * 24 * 60 * 60; // 4 weeks (FCM max)

/**
 * Tracking-class types that should coalesce on the device.
 * Maps type → collapse key prefix (appended with busId from data if present).
 */
const COLLAPSE_KEY_PREFIX = {
  bus_arriving_soon:      "bus_tracking",
  drop_point_approaching: "bus_tracking",
  unexpected_long_stop:   "bus_stop",
  driver_offline_alert:   "driver_status",
};

// Transient FCM error codes safe to retry
const RETRYABLE_CODES = new Set([
  "messaging/server-unavailable",
  "messaging/internal-error",
  "messaging/quota-exceeded",
]);

// ─── Collection map ───────────────────────────────────────────────────────────

function collectionForRole(role) {
  switch (role) {
    case "vendor":  return "vendors";
    case "driver":  return "drivers";
    case "customer":
    default:        return "users";
  }
}

// ─── Exponential backoff helper ───────────────────────────────────────────────

/**
 * Pause for `ms` milliseconds.
 */
function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

/**
 * Attempt `fn` up to `maxAttempts` times with exponential backoff.
 * Retries only on error codes listed in RETRYABLE_CODES.
 *
 * @param {() => Promise<any>} fn
 * @param {number} maxAttempts
 * @returns {Promise<any>}
 */
async function withRetry(fn, maxAttempts = 3) {
  let lastErr;
  for (let attempt = 1; attempt <= maxAttempts; attempt++) {
    try {
      return await fn();
    } catch (err) {
      lastErr = err;
      if (!RETRYABLE_CODES.has(err.code)) throw err; // Non-retryable — bubble up
      if (attempt < maxAttempts) {
        const delayMs = Math.pow(2, attempt) * 1000; // 2s, 4s, 8s
        functions.logger.warn(
          `[FCM] Transient error (${err.code}), retrying in ${delayMs}ms (attempt ${attempt}/${maxAttempts}).`
        );
        await sleep(delayMs);
      }
    }
  }
  throw lastErr; // All retries exhausted
}

// ─── Message builder ──────────────────────────────────────────────────────────

/**
 * Build a fully-configured FCM message object.
 *
 * @param {string} token  — FCM registration token.
 * @param {{ type, title, body, data?, priority? }} payload
 * @returns {Object} FCM message object.
 */
function buildMessage(token, payload) {
  const { type, title, body, data = {}, priority } = payload;

  const isCritical =
    priority === "critical" || CRITICAL_TYPES.has(type);

  const ttlSeconds = TTL_BY_TYPE[type] ?? TTL_DEFAULT;

  // Build collapse key: group tracking updates for the same bus/driver
  const collapsePrefix = COLLAPSE_KEY_PREFIX[type];
  const collapseKey = collapsePrefix
    ? `${collapsePrefix}_${data.busId || data.driverId || "unknown"}`
    : undefined;

  const stringifiedData = Object.fromEntries(
    Object.entries({ type, title, body, ...data }).map(([k, v]) => [k, String(v)])
  );

  const message = {
    token,
    notification: { title, body },
    data: stringifiedData,

    android: {
      collapseKey,
      ttl: ttlSeconds * 1000,
      priority: isCritical ? "high" : "normal",
      notification: {
        channelId: isCritical ? "savarii_critical" : "savarii_notifications",
        priority: isCritical ? "max" : "default",
        sound: "default",
        defaultSound: true,
        defaultVibrateTimings: true,
      },
    },

    apns: {
      headers: {
        "apns-expiration": String(Math.floor(Date.now() / 1000) + ttlSeconds),
        "apns-priority": isCritical ? "10" : "5",
        "apns-push-type": isCritical ? "alert" : "background",
      },
      payload: {
        aps: {
          sound: "default",
          badge: 1,
          "interruption-level": isCritical ? "time-sensitive" : "active",
        },
      },
    },
  };

  return message;
}

// ─── Core send helper ─────────────────────────────────────────────────────────

/**
 * Send a push notification to a single user and log it to Firestore.
 *
 * @param {string} uid   — Firebase Auth UID of the recipient.
 * @param {string} role  — 'customer' | 'vendor' | 'driver'
 * @param {{ type: string, title: string, body: string, data?: Object, priority?: string }} payload
 */
async function sendToUser(uid, role, payload) {
  const db = admin.firestore();

  // 1. Fetch FCM token from the correct collection
  const collection = collectionForRole(role);
  const docRef = db.collection(collection).doc(uid);
  const snap = await docRef.get();

  if (!snap.exists) {
    functions.logger.warn(`[FCM] No document for ${collection}/${uid}`);
    return;
  }

  const fcmToken = snap.data()?.fcmToken;
  if (!fcmToken) {
    functions.logger.warn(`[FCM] No FCM token for ${collection}/${uid}`);
    return;
  }

  // 2. Build message
  const message = buildMessage(fcmToken, payload);

  // 3. Send with exponential backoff retry
  try {
    const response = await withRetry(() => admin.messaging().send(message));
    functions.logger.info(
      `[FCM] Sent "${payload.type}" to ${uid} (${role}): ${response}`
    );
  } catch (err) {
    // Stale / invalid token → remove from Firestore so we don't retry forever
    if (
      err.code === "messaging/registration-token-not-registered" ||
      err.code === "messaging/invalid-registration-token"
    ) {
      functions.logger.warn(
        `[FCM] Stale token for ${uid} — removing from Firestore.`
      );
      await docRef.update({ fcmToken: admin.firestore.FieldValue.delete() });
    } else {
      // Permanent non-token failure — log for audit / monitoring
      functions.logger.error(
        `[FCM] Permanent error sending "${payload.type}" to ${uid}:`,
        err
      );
      await _logFailure(uid, role, payload, err);
    }
    return;
  }

  // 4. Write to notifications/ history
  await logNotification(uid, role, payload);
}

// ─── Notification history logger ──────────────────────────────────────────────

/**
 * Write a notification record to notifications/{auto-id} for in-app history.
 */
async function logNotification(uid, role, payload) {
  try {
    const db = admin.firestore();
    await db.collection("notifications").add({
      userId: uid,
      role,
      type: payload.type,
      title: payload.title,
      body: payload.body,
      data: payload.data || {},
      readStatus: false,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  } catch (err) {
    functions.logger.error("[FCM] logNotification error:", err);
  }
}

// ─── Failure logger ───────────────────────────────────────────────────────────

/**
 * Write a delivery failure record to failed_notifications/{auto-id}.
 * Used for monitoring and alerting on persistent send errors.
 */
async function _logFailure(uid, role, payload, err) {
  try {
    const db = admin.firestore();
    await db.collection("failed_notifications").add({
      userId: uid,
      role,
      type: payload.type,
      errorCode: err.code || "unknown",
      error: err.message || String(err),
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  } catch (logErr) {
    functions.logger.error("[FCM] _logFailure error:", logErr);
  }
}

// ─── Multi-send helper ────────────────────────────────────────────────────────

/**
 * Send the same notification to multiple users in parallel.
 *
 * @param {Array<{ uid: string, role: string }>} recipients
 * @param {{ type, title, body, data?, priority? }} payload
 */
async function sendToMany(recipients, payload) {
  await Promise.allSettled(
    recipients.map(({ uid, role }) => sendToUser(uid, role, payload))
  );
}

// ─── Idempotency guard ────────────────────────────────────────────────────────

/**
 * Checks and marks a Cloud Function event as processed using a Firestore
 * transaction on processed_events/{eventId}.
 *
 * @param {string} eventId — context.eventId from the Cloud Function trigger.
 * @returns {Promise<boolean>} true if this is a NEW (unprocessed) event, false if duplicate.
 */
async function isIdempotent(eventId) {
  if (!eventId) return true; // No ID → always proceed (safe default)

  const db = admin.firestore();
  const docRef = db.collection("processed_events").doc(eventId);

  try {
    return await db.runTransaction(async (t) => {
      const doc = await t.get(docRef);
      if (doc.exists) {
        functions.logger.info(`[Idempotency] Skipping duplicate event: ${eventId}`);
        return false; // Already processed
      }
      t.set(docRef, {
        processedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      return true; // First time — proceed
    });
  } catch (err) {
    functions.logger.error(`[Idempotency] Transaction error for ${eventId}:`, err);
    return true; // On error, proceed to avoid blocking legitimate notifications
  }
}

// ─── Exports ──────────────────────────────────────────────────────────────────

module.exports = { sendToUser, sendToMany, logNotification, isIdempotent };
