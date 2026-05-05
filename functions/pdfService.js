"use strict";

/**
 * pdfService.js — Cloud Function ticket PDF generation.
 *
 * Design is pixel-matched to Flutter's ticket_pdf_service.dart:
 *   - Red gradient header (#E82E59 → #FF6B6B)
 *   - Booking ID + CONFIRMED badge row
 *   - Passenger Details card (Name, Phone, Date, Departure Time)
 *   - Travel Details card (Route, Bus & Seat, Payment)
 *   - Dashed separator
 *   - Payment Summary (Price, GST, Platform Fee, Total)
 *   - Pink footer
 */

const PDFDocument = require("pdfkit");
const { getStorage } = require("firebase-admin/storage");
const functions = require("firebase-functions");

// ── Brand Palette (hex → rgb helpers) ────────────────────────────────────
const C = {
  red: "#E82E59",
  redLight: "#FF6B6B",
  dark: "#1A1A2E",
  grey: "#6B7280",
  lightBg: "#F8F9FA",
  white: "#FFFFFF",
  green: "#00A65A",
  greenBg: "#E8F8F0",
  border: "#E5E7EB",
  pinkBg: "#FFF1F3",
  pinkText: "#FFD6DF",
};

function hex(h) {
  const r = parseInt(h.slice(1, 3), 16);
  const g = parseInt(h.slice(3, 5), 16);
  const b = parseInt(h.slice(5, 7), 16);
  return [r, g, b];
}

// ── Public API ────────────────────────────────────────────────────────────

/**
 * Generate PDF bytes for a ticket.
 * @param {object} booking — Firestore ticket document data
 * @param {string} ticketId
 * @returns {Promise<Buffer>}
 */
async function generateTicketPdf(booking, ticketId) {
  return new Promise((resolve, reject) => {
    const doc = new PDFDocument({ size: "A4", margin: 0, compress: true });
    const chunks = [];

    doc.on("data", (c) => chunks.push(c));
    doc.on("end", () => resolve(Buffer.concat(chunks)));
    doc.on("error", reject);

    _buildPage(doc, booking, ticketId);
    doc.end();
  });
}

/**
 * Upload PDF buffer to Firebase Storage.
 * @returns {Promise<string>} public download URL
 */
async function uploadPdfToStorage(pdfBuffer, bookingId) {
  const bucket = getStorage().bucket();
  const filePath = `tickets/${bookingId}.pdf`;
  const file = bucket.file(filePath);

  await file.save(pdfBuffer, {
    metadata: { contentType: "application/pdf" },
    resumable: false,
  });

  await file.makePublic();
  return `https://storage.googleapis.com/${bucket.name}/${filePath}`;
}

// ── Page builder ──────────────────────────────────────────────────────────

const PAGE_W = 595.28;   // A4 width  in pts
const PAD = 40;        // horizontal padding
const INNER = PAGE_W - PAD * 2;

function _buildPage(doc, booking, ticketId) {
  const pnr = booking.pnr || booking.bookingId || ticketId || "N/A";
  const name = booking.passengerName || booking.customerName || "Passenger";
  const phone = booking.phoneNumber || booking.passengerPhone || "N/A";
  const journeyDate = booking.journeyDate || booking.travelDate || "N/A";
  const journeyTime = booking.journeyTime || booking.departureTime || booking.boardingTime || "—";
  const from = booking.fromLocation || booking.origin || booking.boardingPoint || "Origin";
  const to = booking.toLocation || booking.destination || booking.droppingPoint || "Destination";
  const busAndSeat = booking.busAndSeat || `${booking.busName || "Bus"} | ${(booking.seatNumbers || []).join(", ")}`;
  const payment = booking.paymentMethod || "Online Payment";
  const ticketPrice = _num(booking.ticketPrice);
  const gst = _num(booking.gst);
  const platformFee = _num(booking.platformFee ?? 10);
  const totalPaid = _num(booking.totalPaid || booking.fare);
  const route = booking.route || `${from} to ${to}`;

  let y = 0;

  // ── 1. Header (red gradient) ─────────────────────────────────────────────
  const headerH = 90;
  const grad = doc.linearGradient(0, 0, PAGE_W, 0);
  grad.stop(0, C.red).stop(1, C.redLight);
  doc.rect(0, 0, PAGE_W, headerH).fill(grad);

  // SAVARII
  doc.fillColor(C.white).font("Helvetica-Bold").fontSize(28)
    .text("SAVARII", PAD, 22, { lineBreak: false, characterSpacing: 3 });
  doc.fillColor(C.pinkText).font("Helvetica").fontSize(11)
    .text("Bus Booking Service", PAD, 56, { lineBreak: false, characterSpacing: 1 });

  // BUS TICKET label (right)
  doc.fillColor(C.white).font("Helvetica-Bold").fontSize(13)
    .text("BUS TICKET", PAGE_W - PAD - 100, 28, { width: 100, align: "right", characterSpacing: 2, lineBreak: false });
  doc.fillColor(C.pinkText).font("Helvetica").fontSize(10)
    .text("E-Ticket", PAGE_W - PAD - 100, 50, { width: 100, align: "right", lineBreak: false });

  y = headerH + 24;

  // ── 2. Booking row (PNR + CONFIRMED badge) ───────────────────────────────
  doc.fillColor(C.grey).font("Helvetica").fontSize(9)
    .text("BOOKING ID", PAD, y, { lineBreak: false, characterSpacing: 1 });
  y += 14;
  doc.fillColor(C.dark).font("Helvetica-Bold").fontSize(22)
    .text(pnr, PAD, y, { lineBreak: false });

  // CONFIRMED pill (right)
  const badgeW = 95, badgeH = 22, badgeX = PAGE_W - PAD - badgeW;
  const badgeY = y + 2;
  doc.roundedRect(badgeX, badgeY, badgeW, badgeH, 11)
    .fill(C.greenBg);
  doc.fillColor(C.green).font("Helvetica-Bold").fontSize(10)
    .text("CONFIRMED", badgeX, badgeY + 5, { width: badgeW, align: "center", lineBreak: false, characterSpacing: 1 });

  y += 36;

  // ── 3. Divider ──────────────────────────────────────────────────────────
  doc.moveTo(PAD, y).lineTo(PAGE_W - PAD, y).strokeColor(C.border).lineWidth(1).stroke();
  y += 20;

  // ── 4. Passenger Details card ───────────────────────────────────────────
  y = _infoCard(doc, y, "PASSENGER DETAILS", [
    { label: "PASSENGER NAME", value: name },
    { label: "MOBILE", value: phone },
    { label: "JOURNEY DATE", value: journeyDate },
    { label: "DEPARTURE TIME", value: journeyTime },
  ]);
  y += 16;

  // ── 5. Travel Details card ──────────────────────────────────────────────
  y = _infoCard(doc, y, "TRAVEL DETAILS", [
    { label: "ROUTE", value: route },
    { label: "BUS & SEAT", value: busAndSeat },
    { label: "PAYMENT", value: payment },
  ]);
  y += 16;

  // ── 6. Dashed separator ─────────────────────────────────────────────────
  for (let x = PAD; x < PAGE_W - PAD; x += 10) {
    doc.moveTo(x, y).lineTo(Math.min(x + 5, PAGE_W - PAD), y)
      .strokeColor(C.border).lineWidth(1).stroke();
  }
  y += 16;

  // ── 7. Payment Summary ──────────────────────────────────────────────────
  const psTop = y;
  const psH = 150;
  doc.roundedRect(PAD, psTop, INNER, psH, 12)
    .lineWidth(1).strokeColor(C.border).fillAndStroke(C.white, C.border);

  y = psTop + 20;
  doc.fillColor(C.grey).font("Helvetica-Bold").fontSize(9)
    .text("PAYMENT SUMMARY", PAD + 20, y, { lineBreak: false, characterSpacing: 1 });
  y += 20;

  y = _priceRow(doc, y, "Ticket Price", ticketPrice);
  y = _priceRow(doc, y, "GST (5%)", gst);
  y = _priceRow(doc, y, "Platform Fee", platformFee);

  // Total line
  doc.moveTo(PAD + 20, y + 4).lineTo(PAGE_W - PAD - 20, y + 4)
    .strokeColor(C.border).lineWidth(0.5).stroke();
  y += 16;

  doc.fillColor(C.dark).font("Helvetica-Bold").fontSize(14)
    .text("TOTAL PAID", PAD + 20, y, { lineBreak: false });
  doc.fillColor(C.red).font("Helvetica-Bold").fontSize(18)
    .text(`Rs. ${totalPaid}`, PAD + 20, y - 2, { width: INNER - 40, align: "right", lineBreak: false });
  y += 28;

  // ── 8. Footer ────────────────────────────────────────────────────────────
  y += 12;
  const footerH = 44;
  doc.roundedRect(PAD, y, INNER, footerH, 12).fill(C.pinkBg);
  doc.fillColor(C.red).font("Helvetica-Bold").fontSize(12)
    .text("Thank you for travelling with Savarii!", PAD, y + 14, {
      width: INNER, align: "center", lineBreak: false,
    });

  y += footerH + 10;
  doc.fillColor(C.grey).font("Helvetica").fontSize(9)
    .text("System-generated e-ticket. No signature required.", PAD, y, {
      width: INNER, align: "center", lineBreak: false,
    });
}

// ── Section helpers ───────────────────────────────────────────────────────

/**
 * Draw an info card with a title and a grid of label/value pairs.
 * Returns the new Y position after the card.
 */
function _infoCard(doc, y, title, items) {
  const cols = Math.min(items.length, 4);
  const rows = Math.ceil(items.length / cols);
  const rowH = 44;
  const cardH = 28 + rows * rowH + 12;
  const colW = INNER / cols;

  doc.roundedRect(PAD, y, INNER, cardH, 12)
    .lineWidth(1).strokeColor(C.border).fillAndStroke(C.lightBg, C.border);

  // Card title
  doc.fillColor(C.grey).font("Helvetica-Bold").fontSize(9)
    .text(title, PAD + 20, y + 16, { lineBreak: false, characterSpacing: 1 });

  // Items grid
  items.forEach((item, idx) => {
    const col = idx % cols;
    const row = Math.floor(idx / cols);
    const ix = PAD + 20 + col * colW;
    const iy = y + 34 + row * rowH;

    doc.fillColor(C.grey).font("Helvetica-Bold").fontSize(8)
      .text(item.label, ix, iy, { width: colW - 8, lineBreak: false, characterSpacing: 0.5 });
    doc.fillColor(C.dark).font("Helvetica-Bold").fontSize(12)
      .text(String(item.value || "N/A"), ix, iy + 12, { width: colW - 8, lineBreak: false });
  });

  return y + cardH;
}

/**
 * Draw a price row inside the payment summary box.
 */
function _priceRow(doc, y, label, amount) {
  doc.fillColor(C.grey).font("Helvetica").fontSize(12)
    .text(label, PAD + 20, y, { lineBreak: false });
  doc.fillColor(C.dark).font("Helvetica-Bold").fontSize(12)
    .text(`Rs. ${amount}`, PAD + 20, y, { width: INNER - 40, align: "right", lineBreak: false });
  return y + 22;
}

function _num(val) {
  const n = parseFloat(val || 0);
  return isNaN(n) ? "0.00" : n.toFixed(2);
}

module.exports = { generateTicketPdf, uploadPdfToStorage };
