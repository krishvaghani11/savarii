/**
 * trackingTriggers.js — RTDB + Firestore event-driven notification triggers
 * for live tracking events in Savarii.
 */

"use strict";

const functions = require("firebase-functions");
const admin = require("firebase-admin");
const { sendToUser, isIdempotent } = require("./fcm");

const db = admin.firestore();
const rtdb = admin.database();

// ── Proximity config ──────────────────────────────────────────────────────────
const REACHED_BOARDING_RADIUS_M = 100;
const ARRIVING_SOON_RADIUS_M = 500;
const PASSENGER_WAITING_RADIUS_M = 1000;
const DROP_POINT_RADIUS_M = 1000;
const OFFLINE_THRESHOLD_MS = 10 * 60 * 1000;   // 10 min — Driver Offline
const LONG_STOP_THRESHOLD_MS = 10 * 60 * 1000;  // 10 min — Unexpected Long Stop
const LONG_STOP_SPEED_THRESHOLD = 2;            // km/h
const ALERT_COOLDOWN_MS = 30 * 60 * 1000;       // 30 min — prevents alert spam

// ──────────────────────────────────────────────────────────────────────────────
// 1. onLiveTrackingUpdate
// ──────────────────────────────────────────────────────────────────────────────
exports.onLiveTrackingUpdate = functions.database
  .ref("live_tracking/{busId}")
  .onWrite(async (change, context) => {
    // Idempotency check
    if (!(await isIdempotent(context.eventId))) return;

    const busId = context.params.busId;
    const after = change.after.val();
    if (!after) return;

    const busLat = after.latitude;
    const busLng = after.longitude;
    if (!busLat || !busLng) return;

    const today = _todayFormatted();

    // Fetch active confirmed tickets for this bus departing today
    const ticketSnap = await db
      .collection("tickets")
      .where("busId", "==", busId)
      .where("status", "==", "confirmed")
      .get();

    for (const doc of ticketSnap.docs) {
      const ticketId = doc.id;
      const ticket = doc.data();

      // Filter by journey date
      const journeyDate = (ticket.journeyDate || ticket.travelDate || "").replace(/\//g, "-");
      if (journeyDate !== today) continue;

      // ── ATOMIC PROXIMITY CHECK ──
      // We use a transaction to ensure flags are updated exactly once even if
      // rapid GPS updates trigger this function multiple times in parallel.
      await db.runTransaction(async (transaction) => {
        const tDocRef = db.collection("tickets").doc(ticketId);
        const tSnap = await transaction.get(tDocRef);
        if (!tSnap.exists) return;

        const tData = tSnap.data();
        const updates = {};

        // 🚌 Boarding Point Nearby (500m)
        const bLat = tData.boardingLat || tData.boardingPointLat;
        const bLng = tData.boardingLng || tData.boardingPointLng;
        if (bLat && bLng && !tData._notifiedArrivingSoon) {
          const dist = _haversineMetres(busLat, busLng, bLat, bLng);
          if (dist <= ARRIVING_SOON_RADIUS_M) {
            await sendToUser(tData.customerId, "customer", {
              type: "boarding_point_nearby",
              title: "🚌 Bus Arriving Soon!",
              body: `Your bus is ${Math.round(dist)}m away from your boarding point. Get ready!`,
              data: { busId, ticketId },
            });
            updates._notifiedArrivingSoon = true;
          }
        }

        // 🚌 Bus Reached Boarding Point (100m)
        if (bLat && bLng && !tData._notifiedBusReached) {
          const dist = _haversineMetres(busLat, busLng, bLat, bLng);
          if (dist <= REACHED_BOARDING_RADIUS_M) {
            await sendToUser(tData.customerId, "customer", {
              type: "bus_reached_boarding_point",
              title: "🚌 Bus Reached!",
              body: `Your bus has reached the boarding point. Please board now.`,
              data: { busId, ticketId },
            });
            updates._notifiedBusReached = true;
          }
        }

        // 🚌 Missed Boarding Alert (Bus moved past boarding point)
        if (bLat && bLng && tData._notifiedBusReached && !tData._notifiedMissedBoarding && !tData.checkedIn) {
          const dist = _haversineMetres(busLat, busLng, bLat, bLng);
          if (dist > 500) { // Bus is now more than 500m away after having reached it
            await sendToUser(tData.customerId, "customer", {
              type: "missed_boarding_alert",
              title: "❓ Did you board?",
              body: `The bus has moved past your boarding point. If you missed it, please contact the driver.`,
              data: { busId, ticketId },
            });
            updates._notifiedMissedBoarding = true;
          }
        }

        // 📍 Drop Point Approaching
        const dLat = tData.droppingLat || tData.droppingPointLat;
        const dLng = tData.droppingLng || tData.droppingPointLng;
        if (dLat && dLng && !tData._notifiedDropApproaching) {
          const dist = _haversineMetres(busLat, busLng, dLat, dLng);
          if (dist <= DROP_POINT_RADIUS_M) {
            await sendToUser(tData.customerId, "customer", {
              type: "drop_point_approaching",
              title: "📍 Approaching Your Stop",
              body: `Your drop point is ${Math.round(dist)}m away. Prepare to get off.`,
              data: { busId, ticketId },
            });
            updates._notifiedDropApproaching = true;
          }
        }

        if (Object.keys(updates).length > 0) {
          transaction.update(tDocRef, updates);
        }
      });
    }

    // 🚌 Driver: Passenger Waiting Alert
    // Check if we are near any boarding point for today's tickets
    const boardingPoints = {}; // name -> { lat, lng, count }
    ticketSnap.docs.forEach((doc) => {
      const t = doc.data();
      const jd = (t.journeyDate || t.travelDate || "").replace(/\//g, "-");
      if (jd !== today) return;

      const name = t.boardingPoint || "Unknown Point";
      const lat = t.boardingLat || t.boardingPointLat;
      const lng = t.boardingLng || t.boardingPointLng;
      if (!lat || !lng) return;

      if (!boardingPoints[name]) {
        boardingPoints[name] = { lat, lng, count: 0 };
      }
      boardingPoints[name].count++;
    });

    for (const [name, pt] of Object.entries(boardingPoints)) {
      const dist = _haversineMetres(busLat, busLng, pt.lat, pt.lng);
      if (dist <= PASSENGER_WAITING_RADIUS_M && dist > REACHED_BOARDING_RADIUS_M) {
        // Use a flag on the bus to avoid spamming the driver
        const busDocRef = db.collection("buses").doc(busId);
        await db.runTransaction(async (transaction) => {
          const busSnap = await transaction.get(busDocRef);
          if (!busSnap.exists) return;
          const busData = busSnap.data();
          const notifiedPoints = busData._notifiedWaitingPoints || {};

          if (!notifiedPoints[name]) {
            const driverSnap = await db.collection("drivers").where("busId", "==", busId).limit(1).get();
            if (!driverSnap.empty) {
              const driverId = driverSnap.docs[0].id;
              await sendToUser(driverId, "driver", {
                type: "passenger_waiting_alert",
                title: "👥 Passengers Waiting",
                body: `${pt.count} passenger(s) waiting at ${name}.`,
                data: { busId, boardingPoint: name },
              });
              notifiedPoints[name] = true;
              transaction.update(busDocRef, { _notifiedWaitingPoints: notifiedPoints });
            }
          }
        });
      }
    }
  });

// ──────────────────────────────────────────────────────────────────────────────
// 2. onDriverStatusChanged
// ──────────────────────────────────────────────────────────────────────────────
exports.onDriverStatusChanged = functions.firestore
  .document("drivers/{driverId}")
  .onUpdate(async (change, context) => {
    if (!(await isIdempotent(context.eventId))) return;

    const before = change.before.data();
    const after = change.after.data();
    const driverId = context.params.driverId;
    if (!before || !after || before.status === after.status) return;

    const tasks = [];

    // Notify driver of status update
    tasks.push(
      sendToUser(driverId, "driver", {
        type: "trip_status_changed",
        title: "📢 Status Updated",
        body: `Your trip status has been updated to: ${after.status}.`,
        data: { driverId },
      })
    );

    // If driver went offline unexpectedly (ON TRIP -> ACTIVE without stopTracking)
    if (before.status === "ON TRIP" && after.status === "ACTIVE") {
      const busId = after.busId || driverId;
      const rtdbSnap = await rtdb.ref(`live_tracking/${busId}`).once("value");
      if (rtdbSnap.exists() && after.vendorId) {
        tasks.push(
          sendToUser(after.vendorId, "vendor", {
            type: "driver_offline_alert",
            title: "⚠️ Driver Went Offline",
            body: `${after.name || "Driver"} has gone offline unexpectedly.`,
            data: { driverId, busId },
          })
        );
      }
    }

    await Promise.allSettled(tasks);
  });

// ──────────────────────────────────────────────────────────────────────────────
// 3. onFleetHealthCheck (Scheduled)
// ──────────────────────────────────────────────────────────────────────────────
exports.onFleetHealthCheck = functions.pubsub
  .schedule("every 5 minutes")
  .onRun(async (context) => {
    const now = Date.now();
    
    // OPTIMIZATION: Bounded query.
    // Only fetch buses that have been updated in the last 15 minutes.
    // This ensures the query stays fast as the total number of historical nodes grows.
    const snap = await rtdb
      .ref("live_tracking")
      .orderByChild("timestamp")
      .startAt(now - 15 * 60 * 1000)
      .once("value");

    if (!snap.exists()) return;

    const buses = snap.val();
    const tasks = [];

    for (const [busId, data] of Object.entries(buses)) {
      const lastUpdated = data.timestamp || 0;
      const duration = now - lastUpdated;

      // Fetch bus/vendor info
      const busSnap = await db.collection("buses").doc(busId).get();
      if (!busSnap.exists) continue;
      const busData = busSnap.data();
      const vendorId = busData.vendorId;
      if (!vendorId) continue;

      // A. HEARTBEAT: Driver offline (no updates for 10 min)
      if (duration > OFFLINE_THRESHOLD_MS) {
        // Cooldown check
        if (now - (busData._lastOfflineAlert || 0) > ALERT_COOLDOWN_MS) {
          tasks.push(
            sendToUser(vendorId, "vendor", {
              type: "driver_offline_alert",
              title: "⚠️ Driver Signal Lost",
              body: `Bus ${busData.busName || busId} has not sent updates for 10 minutes.`,
              data: { busId },
            })
          );
          tasks.push(db.collection("buses").doc(busId).update({ _lastOfflineAlert: now }));
        }
      } 
      // B. LONG STOP: Speed < 2km/h for 10 min
      else if ((data.speed || 0) < LONG_STOP_SPEED_THRESHOLD && duration > LONG_STOP_THRESHOLD_MS) {
        if (now - (busData._lastLongStopAlert || 0) > ALERT_COOLDOWN_MS) {
          tasks.push(
            sendToUser(vendorId, "vendor", {
              type: "unexpected_long_stop",
              title: "🛑 Unexpected Long Stop",
              body: `Bus ${busData.busName || busId} has been stopped for over 10 minutes.`,
              data: { busId },
            })
          );
          tasks.push(db.collection("buses").doc(busId).update({ _lastLongStopAlert: now }));
        }
      }
      // D. SPEED WARNING: Speed > 80 km/h
      else if ((data.speed || 0) > 80) {
        if (now - (busData._lastSpeedAlert || 0) > ALERT_COOLDOWN_MS) {
          const driverSnap = await db.collection("drivers").where("busId", "==", busId).limit(1).get();
          if (!driverSnap.empty) {
            const driverId = driverSnap.docs[0].id;
            tasks.push(
              sendToUser(driverId, "driver", {
                type: "speed_warning",
                title: "⚠️ Speed Warning",
                body: `You are driving at ${Math.round(data.speed)} km/h. Please maintain a safe speed.`,
                data: { busId, speed: data.speed },
              })
            );
            tasks.push(db.collection("buses").doc(busId).update({ _lastSpeedAlert: now }));
          }
        }
      }
    }

    // C. LATE START: Check buses scheduled to start but haven't
    const upcomingBuses = await db
      .collection("buses")
      .where("status", "==", "ACTIVE")
      .get();

    upcomingBuses.docs.forEach((doc) => {
      const bus = doc.data();
      const depTimeStr = bus.route?.departureTime; // Expecting "HH:mm"
      if (!depTimeStr) return;

      const [hours, minutes] = depTimeStr.split(":").map(Number);
      const depTime = new Date();
      depTime.setHours(hours, minutes, 0, 0);

      // If departure was more than 10 mins ago but bus is still ACTIVE
      if (now - depTime.getTime() > 10 * 60 * 1000 && now - depTime.getTime() < 60 * 60 * 1000) {
        if (bus.vendorId && (now - (bus._lastLateStartAlert || 0) > ALERT_COOLDOWN_MS)) {
          tasks.push(
            sendToUser(bus.vendorId, "vendor", {
              type: "driver_late_start_alert",
              title: "⏰ Late Start Alert",
              body: `Bus ${bus.busName || doc.id} was scheduled to depart at ${depTimeStr} but has not started tracking.`,
              data: { busId: doc.id },
            })
          );
          tasks.push(db.collection("buses").doc(doc.id).update({ _lastLateStartAlert: now }));
        }
      }
    });

    await Promise.allSettled(tasks);
  });

// ── Helpers ───────────────────────────────────────────────────────────────────
function _haversineMetres(lat1, lng1, lat2, lng2) {
  const R = 6371000;
  const dLat = (lat2 - lat1) * Math.PI / 180;
  const dLng = (lng2 - lng1) * Math.PI / 180;
  const a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
            Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
            Math.sin(dLng / 2) * Math.sin(dLng / 2);
  return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
}

function _todayFormatted() {
  return new Date().toISOString().split("T")[0];
}
