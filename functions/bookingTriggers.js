/**
 * bookingTriggers.js — Booking lifecycle notification triggers.
 *
 * Sprint 1:
 *   onBookingCreated       → booking_confirmed (customer) + new_booking_received (vendor)
 *   onBookingStatusChanged → ticket_cancelled + booking_cancellation_alert
 *                            payment_success / payment_failure / refund_processed
 *   onDriverAssigned       → driver_assigned (customers) + driver_assigned_confirmation (vendor)
 *                            new_trip_assigned (driver)
 */

"use strict";

const functions = require("firebase-functions");
const admin = require("firebase-admin");
const { sendToUser } = require("./fcm");

const db = admin.firestore();
const NEARLY_FULL_THRESHOLD = 0.8;

// ─── 1. onBookingCreated ─────────────────────────────────────────────────────
exports.onBookingCreated = functions.firestore
  .document("tickets/{ticketId}")
  .onCreate(async (snap, context) => {
    const ticket = snap.data();
    const ticketId = context.params.ticketId;
    if (!ticket) return;

    const { customerId, vendorId, busId } = ticket;
    const bookingId = ticket.bookingId || ticketId;
    const from = ticket.from || ticket.boardingPoint || "origin";
    const to = ticket.to || ticket.droppingPoint || "destination";
    const journeyDate = ticket.journeyDate || ticket.travelDate || "";
    const seatNumbers = Array.isArray(ticket.selectedSeats)
      ? ticket.selectedSeats.join(", ")
      : ticket.seatNumber || "N/A";
    const totalAmount = ticket.totalAmount || ticket.amount || 0;
    const passengerName = ticket.passengerName || ticket.customerName || "Passenger";

    const tasks = [];

    if (customerId) {
      tasks.push(
        sendToUser(customerId, "customer", {
          type: "booking_confirmed",
          title: "🎉 Booking Confirmed!",
          body: `${from} → ${to} on ${journeyDate}. Seats: ${seatNumbers}. PNR: ${bookingId}`,
          data: { bookingId, busId, ticketId, originCity: from, to, journeyDate },
        })
      );
    }

    if (vendorId) {
      tasks.push(
        sendToUser(vendorId, "vendor", {
          type: "new_booking_received",
          title: "📋 New Booking Received",
          body: `${passengerName} booked ${seatNumbers} for ${from} → ${to} on ${journeyDate}. ₹${totalAmount}`,
          data: { bookingId, busId, ticketId, originCity: from, to, journeyDate },
        })
      );
    }

    await Promise.allSettled(tasks);

    // Check seat occupancy thresholds
    if (busId && vendorId) {
      await _checkSeatOccupancy(busId, vendorId, journeyDate);
    }
  });

// ─── 2. onBookingStatusChanged ───────────────────────────────────────────────
exports.onBookingStatusChanged = functions.firestore
  .document("tickets/{ticketId}")
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();
    const ticketId = context.params.ticketId;
    if (!before || !after) return;

    const { customerId, vendorId, busId } = after;
    const bookingId = after.bookingId || ticketId;
    const from = after.from || after.boardingPoint || "origin";
    const to = after.to || after.droppingPoint || "destination";
    const journeyDate = after.journeyDate || after.travelDate || "";
    const tasks = [];

    // Cancellation
    if (before.status !== after.status && after.status === "cancelled") {
      if (customerId) {
        tasks.push(
          sendToUser(customerId, "customer", {
            type: "ticket_cancelled",
            title: "❌ Ticket Cancelled",
            body: `Your booking (PNR: ${bookingId}) for ${from} → ${to} has been cancelled.`,
            data: { bookingId, busId, ticketId },
          })
        );
      }
      if (vendorId) {
        tasks.push(
          sendToUser(vendorId, "vendor", {
            type: "booking_cancellation_alert",
            title: "⚠️ Booking Cancelled",
            body: `A passenger cancelled booking ${bookingId} for ${from} → ${to} on ${journeyDate}.`,
            data: { bookingId, busId, ticketId },
          })
        );
      }
    }

    // Payment status
    if (before.paymentStatus !== after.paymentStatus && customerId) {
      if (after.paymentStatus === "paid") {
        tasks.push(
          sendToUser(customerId, "customer", {
            type: "payment_success",
            title: "✅ Payment Successful",
            body: `Payment confirmed for booking ${bookingId}. Enjoy your journey!`,
            data: { bookingId, busId, ticketId },
          })
        );
      } else if (after.paymentStatus === "failed") {
        tasks.push(
          sendToUser(customerId, "customer", {
            type: "payment_failure",
            title: "❌ Payment Failed",
            body: `Payment for booking ${bookingId} could not be processed. Please retry.`,
            data: { bookingId, busId, ticketId },
          })
        );
      }
    }

    // Refund
    if (before.refundStatus !== after.refundStatus && after.refundStatus === "processed" && customerId) {
      const refundAmount = after.refundAmount || after.totalAmount || 0;
      tasks.push(
        sendToUser(customerId, "customer", {
          type: "refund_processed",
          title: "💰 Refund Processed",
          body: `₹${refundAmount} refund for booking ${bookingId} has been initiated.`,
          data: { bookingId, busId, ticketId },
        })
      );
    }

    // Seat Updated
    if (JSON.stringify(before.selectedSeats) !== JSON.stringify(after.selectedSeats) && customerId) {
      const newSeats = Array.isArray(after.selectedSeats) ? after.selectedSeats.join(", ") : after.selectedSeats;
      tasks.push(
        sendToUser(customerId, "customer", {
          type: "seat_updated",
          title: "💺 Seat Updated",
          body: `Your seat for booking ${bookingId} has been updated to: ${newSeats}.`,
          data: { bookingId, busId, ticketId, newSeats },
        })
      );
    }

    await Promise.allSettled(tasks);
  });

// ─── 3. onDriverAssigned ─────────────────────────────────────────────────────
exports.onDriverAssigned = functions.firestore
  .document("buses/{busId}")
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();
    const busId = context.params.busId;
    if (!before || !after) return;

    const beforeMobile = before.driver?.mobile || "";
    const afterMobile = after.driver?.mobile || "";
    if (beforeMobile === afterMobile || !afterMobile) return;

    const vendorId = after.vendorId;
    const driverName = after.driver?.name || "your driver";
    const busName = after.busName || after.busNumber || "your bus";
    const from = after.route?.from || "origin";
    const to = after.route?.to || "destination";
    const departureTime = after.route?.departureTime || "";
    const today = _todayFormatted();
    const tasks = [];

    // Find confirmed-ticket customers for today on this bus
    const ticketSnap = await db
      .collection("tickets")
      .where("busId", "==", busId)
      .where("status", "==", "confirmed")
      .get();

    const customerIds = new Set();
    ticketSnap.docs.forEach((doc) => {
      const t = doc.data();
      const jd = (t.journeyDate || t.travelDate || "").replace(/\//g, "-");
      if (jd === today && t.customerId) customerIds.add(t.customerId);
    });

    for (const customerId of customerIds) {
      tasks.push(
        sendToUser(customerId, "customer", {
          type: "driver_assigned",
          title: "🚌 Driver Assigned",
          body: `${driverName} is driving your bus (${busName}) for ${from} → ${to} at ${departureTime}.`,
          data: { busId, originCity: from, to },
        })
      );
    }

    if (vendorId) {
      tasks.push(
        sendToUser(vendorId, "vendor", {
          type: "driver_assigned_confirmation",
          title: "✅ Driver Assigned",
          body: `${driverName} is now assigned to ${busName} for ${from} → ${to}.`,
          data: { busId },
        })
      );
    }

    // Notify the driver
    const driverSnap = await db
      .collection("drivers")
      .where("phone", "==", afterMobile)
      .limit(1)
      .get();

    if (!driverSnap.empty) {
      const driverId = driverSnap.docs[0].id;
      tasks.push(
        sendToUser(driverId, "driver", {
          type: "new_trip_assigned",
          title: "🚌 New Trip Assigned",
          body: `You are assigned to ${busName}: ${from} → ${to} at ${departureTime}.`,
          data: { busId, originCity: from, to, departureTime },
        })
      );
    }

    await Promise.allSettled(tasks);
  });

// ─── 4. onBusStatusChanged ───────────────────────────────────────────────────
exports.onBusStatusChanged = functions.firestore
  .document("buses/{busId}")
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();
    const busId = context.params.busId;
    if (!before || !after) return;

    const tasks = [];
    const busName = after.busName || after.busNumber || "your bus";
    const today = _todayFormatted();

    // A. Trip Cancelled by Vendor
    if (before.status !== "cancelled" && after.status === "cancelled") {
      const ticketSnap = await db
        .collection("tickets")
        .where("busId", "==", busId)
        .where("status", "==", "confirmed")
        .get();

      const customerIds = new Set();
      ticketSnap.docs.forEach((doc) => {
        const t = doc.data();
        const jd = (t.journeyDate || t.travelDate || "").replace(/\//g, "-");
        if (jd === today && t.customerId) customerIds.add(t.customerId);
      });

      for (const customerId of customerIds) {
        tasks.push(
          sendToUser(customerId, "customer", {
            type: "trip_cancelled_by_vendor",
            title: "❌ Trip Cancelled",
            body: `Your trip on ${busName} today has been cancelled by the vendor. Check your bookings for details.`,
            data: { busId },
          })
        );
      }
    }

    // B. Vehicle Breakdown
    if (!before.breakdown && after.breakdown) {
      const ticketSnap = await db
        .collection("tickets")
        .where("busId", "==", busId)
        .where("status", "==", "confirmed")
        .get();

      const customerIds = new Set();
      ticketSnap.docs.forEach((doc) => {
        const t = doc.data();
        const jd = (t.journeyDate || t.travelDate || "").replace(/\//g, "-");
        if (jd === today && t.customerId) customerIds.add(t.customerId);
      });

      for (const customerId of customerIds) {
        tasks.push(
          sendToUser(customerId, "customer", {
            type: "vehicle_breakdown_alert",
            title: "⚠️ Vehicle Breakdown",
            body: `We're sorry, your bus (${busName}) is experiencing technical issues. A replacement or update will be provided soon.`,
            data: { busId },
          })
        );
      }
    }

    await Promise.allSettled(tasks);
  });

// ─── Internal helpers ─────────────────────────────────────────────────────────

async function _checkSeatOccupancy(busId, vendorId, journeyDate) {
  try {
    const busSnap = await db.collection("buses").doc(busId).get();
    if (!busSnap.exists) return;
    const busData = busSnap.data();
    const totalSeats = busData.totalSeats || busData.capacity || 0;
    if (!totalSeats) return;

    const formatted = journeyDate.replace(/\//g, "-");
    const booked = ((busData.bookedSeatsByDate || {})[formatted] || []).length;
    const busName = busData.busName || busData.busNumber || busId;

    if (booked === totalSeats) {
      await sendToUser(vendorId, "vendor", {
        type: "bus_fully_booked",
        title: "🔴 Bus Fully Booked",
        body: `${busName} is fully booked for ${journeyDate}. All ${totalSeats} seats taken.`,
        data: { busId, journeyDate },
      });
    } else if (booked / totalSeats >= NEARLY_FULL_THRESHOLD) {
      await sendToUser(vendorId, "vendor", {
        type: "bus_nearly_full",
        title: "🟡 Bus Nearly Full",
        body: `${busName} has only ${totalSeats - booked} seat(s) left for ${journeyDate}.`,
        data: { busId, journeyDate },
      });
    }
  } catch (err) {
    functions.logger.error("[bookingTriggers] _checkSeatOccupancy:", err);
  }
}

// ─── 5. onTripReminders (Scheduled) ──────────────────────────────────────────
exports.onTripReminders = functions.pubsub
  .schedule("every 30 minutes")
  .onRun(async (context) => {
    const now = new Date();
    const tasks = [];

    // Reminders for trips in ~24 hours and ~2 hours
    const reminderConfigs = [
      { windowHours: 24, type: "trip_reminder_24hr", title: "📅 Trip Tomorrow", bodyPrefix: "Your journey is in 24 hours." },
      { windowHours: 2, type: "trip_reminder_2hr", title: "🎒 Journey Today", bodyPrefix: "Your journey starts in 2 hours." },
    ];

    for (const config of reminderConfigs) {
      const targetTime = new Date(now.getTime() + config.windowHours * 60 * 60 * 1000);
      const targetDate = targetTime.toISOString().split("T")[0].replace(/-/g, "/");
      
      // Note: This is a bit simplified. In a real app, you'd query by journeyDate and departureTime.
      // For now, we'll query tickets for today/tomorrow and filter in JS.
      const ticketSnap = await db
        .collection("tickets")
        .where("status", "==", "confirmed")
        .where("journeyDate", "==", targetDate)
        .get();

      ticketSnap.docs.forEach((doc) => {
        const ticket = doc.data();
        const flag = `_notifiedReminder_${config.windowHours}h`;
        if (ticket[flag]) return;

        const depTimeStr = ticket.boardingTime || "scheduled time";
        
        tasks.push(
          sendToUser(ticket.customerId, "customer", {
            type: config.type,
            title: config.title,
            body: `${config.bodyPrefix} PNR: ${ticket.bookingId || doc.id} at ${depTimeStr}.`,
            data: { ticketId: doc.id },
          })
        );
        tasks.push(doc.ref.update({ [flag]: true }));
      });
    }

    // Low Occupancy Alert (check trips starting in 6 hours with < 20% occupancy)
    const upcomingTrips = await db
      .collection("buses")
      .where("status", "==", "ACTIVE")
      .get();

    for (const doc of upcomingTrips.docs) {
      const bus = doc.data();
      const flag = "_notifiedLowOccupancy";
      if (bus[flag]) continue;

      const depTimeStr = bus.route?.departureTime;
      if (!depTimeStr) continue;

      const [hours, minutes] = depTimeStr.split(":").map(Number);
      const depTime = new Date();
      depTime.setHours(hours, minutes, 0, 0);

      const diffMs = depTime.getTime() - now.getTime();
      if (diffMs > 0 && diffMs < 6 * 60 * 60 * 1000) {
        const totalSeats = bus.totalSeats || bus.capacity || 40;
        const formatted = _todayFormatted().replace(/-/g, "/");
        const booked = ((bus.bookedSeatsByDate || {})[formatted] || []).length;

        if (booked / totalSeats < 0.2) {
          if (bus.vendorId) {
            tasks.push(
              sendToUser(bus.vendorId, "vendor", {
                type: "low_occupancy_alert",
                title: "📉 Low Occupancy Alert",
                body: `Bus ${bus.busName || doc.id} has only ${booked} seats booked for today's trip at ${depTimeStr}.`,
                data: { busId: doc.id },
              })
            );
            tasks.push(doc.ref.update({ [flag]: true }));
          }
        }
      }
    }

    await Promise.allSettled(tasks);
  });

function _todayFormatted() {
  return new Date().toISOString().split("T")[0];
}
