"use strict";

/**
 * emailService.js — Resend email delivery with Savarii brand theme.
 *
 * Template Registry:
 *   v1 — Savarii red/pink brand, departure time, route hero, payment summary.
 */

const { Resend } = require("resend");

const RESEND_API_KEY = process.env.RESEND_API_KEY;
const FROM_ADDRESS   = "Savarii <support@savarii.co.in>";

// ── Template version registry ──────────────────────────────────────────────
const TEMPLATE_VERSIONS = { CURRENT: "v1", v1: _buildV1Html };

/**
 * Send ticket confirmation email via Resend.
 * @param {object} booking  — Firestore ticket document data
 * @param {string} ticketId — Firestore document ID
 * @param {string} [pdfUrl] — signed download URL for the PDF attachment
 * @returns {{ templateVersion: string }}
 */
async function sendTicketEmail(booking, ticketId, pdfUrl) {
  if (!RESEND_API_KEY) throw new Error("RESEND_API_KEY not set");

  const resend  = new Resend(RESEND_API_KEY);
  const version = TEMPLATE_VERSIONS.CURRENT;
  const html    = TEMPLATE_VERSIONS[version](booking, ticketId, pdfUrl);

  const to = booking.email || booking.contactEmail || "";
  if (!to) throw new Error("No recipient email in booking document");

  const pnr  = booking.pnr || booking.bookingId || ticketId;
  const from = booking.fromLocation || booking.origin || "Origin";
  const to_  = booking.toLocation   || booking.destination || "Destination";

  const payload = {
    from:    FROM_ADDRESS,
    to:      [to],
    subject: `🎉 Booking Confirmed! PNR ${pnr} — ${from} → ${to_}`,
    html,
  };

  // Attach PDF if URL supplied
  if (pdfUrl) {
    payload.subject = `🎉 Your E-Ticket is Ready! PNR ${pnr}`;
  }

  const result = await resend.emails.send(payload);
  if (result.error) throw new Error(result.error.message || "Resend API error");

  return { templateVersion: version };
}

// ── v1 HTML Template — Savarii Brand ──────────────────────────────────────
function _buildV1Html(booking, ticketId, pdfUrl) {
  const pnr           = booking.pnr || booking.bookingId || ticketId || "N/A";
  const passengerName = booking.passengerName || booking.customerName || "Passenger";
  const from          = booking.fromLocation  || booking.origin       || booking.boardingPoint || "Origin";
  const to            = booking.toLocation    || booking.destination  || booking.droppingPoint || "Destination";
  const journeyDate   = booking.journeyDate   || booking.travelDate   || "N/A";
  const journeyTime   = booking.journeyTime   || booking.departureTime || booking.boardingTime || "—";
  const seats         = Array.isArray(booking.seatNumbers)
    ? booking.seatNumbers.join(", ")
    : (booking.seatNumber || booking.busAndSeat || "N/A");
  const busName       = booking.busName       || "Savarii Bus";
  const payment       = booking.paymentMethod || "Online Payment";
  const ticketPrice   = _fmt(booking.ticketPrice);
  const gst           = _fmt(booking.gst);
  const platformFee   = _fmt(booking.platformFee ?? 10);
  const totalPaid     = _fmt(booking.totalPaid || booking.fare || booking.amount);
  const pdfBtn        = pdfUrl
    ? `<a href="${pdfUrl}" style="display:inline-block;margin-top:8px;padding:10px 28px;background:#E82E59;color:#fff;text-decoration:none;border-radius:8px;font-size:13px;font-weight:600;letter-spacing:0.5px;">⬇ Download E-Ticket PDF</a>`
    : "";

  return `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width,initial-scale=1.0" />
  <title>Savarii Ticket Confirmation</title>
</head>
<body style="margin:0;padding:0;background:#F8F9FA;font-family:'Segoe UI',Roboto,Arial,sans-serif;">

<table width="100%" cellpadding="0" cellspacing="0" style="background:#F8F9FA;padding:32px 0;">
  <tr><td align="center">
  <table width="600" cellpadding="0" cellspacing="0" style="max-width:600px;width:100%;background:#fff;border-radius:16px;overflow:hidden;box-shadow:0 4px 24px rgba(0,0,0,0.08);">

    <!-- ── HEADER ── -->
    <tr>
      <td style="background:linear-gradient(135deg,#E82E59 0%,#FF6B6B 100%);padding:36px 40px;">
        <table width="100%" cellpadding="0" cellspacing="0">
          <tr>
            <td>
              <div style="color:#fff;font-size:30px;font-weight:800;letter-spacing:3px;line-height:1;">SAVARII</div>
              <div style="color:#FFD6DF;font-size:12px;letter-spacing:1px;margin-top:4px;">Bus Booking Service</div>
            </td>
            <td align="right">
              <div style="color:#fff;font-size:13px;font-weight:700;letter-spacing:2px;">BUS TICKET</div>
              <div style="color:#FFD6DF;font-size:11px;margin-top:2px;">E-Ticket</div>
            </td>
          </tr>
        </table>
      </td>
    </tr>

    <!-- ── GREETING ── -->
    <tr>
      <td style="padding:28px 40px 0;">
        <div style="font-size:20px;font-weight:700;color:#1A1A2E;">
          Hi ${_esc(passengerName)}! 🎉
        </div>
        <div style="font-size:14px;color:#6B7280;margin-top:6px;">
          Your booking is <strong style="color:#00A65A;">confirmed</strong>. Here are your travel details.
        </div>
      </td>
    </tr>

    <!-- ── PNR BANNER ── -->
    <tr>
      <td style="padding:20px 40px;">
        <table width="100%" cellpadding="0" cellspacing="0"
          style="background:#FFF1F3;border-left:4px solid #E82E59;border-radius:0 8px 8px 0;padding:16px 20px;">
          <tr>
            <td>
              <div style="font-size:10px;color:#6B7280;letter-spacing:1.5px;font-weight:600;">BOOKING ID / PNR</div>
              <div style="font-size:26px;font-weight:800;color:#1A1A2E;letter-spacing:2px;margin-top:4px;">${_esc(pnr)}</div>
            </td>
            <td align="right">
              <span style="background:#E8F8F0;color:#00A65A;padding:6px 14px;border-radius:20px;font-size:12px;font-weight:700;letter-spacing:1px;">✓ CONFIRMED</span>
            </td>
          </tr>
        </table>
      </td>
    </tr>

    <!-- ── ROUTE HERO ── -->
    <tr>
      <td style="padding:0 40px 20px;">
        <table width="100%" cellpadding="0" cellspacing="0"
          style="background:#1A1A2E;border-radius:12px;padding:24px 28px;">
          <tr>
            <td align="center">
              <table cellpadding="0" cellspacing="0">
                <tr>
                  <td align="center">
                    <div style="color:#FFD6DF;font-size:10px;letter-spacing:1.5px;font-weight:600;">FROM</div>
                    <div style="color:#fff;font-size:22px;font-weight:800;margin-top:4px;">${_esc(from)}</div>
                  </td>
                  <td style="padding:0 24px;">
                    <div style="color:#E82E59;font-size:28px;line-height:1;">→</div>
                  </td>
                  <td align="center">
                    <div style="color:#FFD6DF;font-size:10px;letter-spacing:1.5px;font-weight:600;">TO</div>
                    <div style="color:#fff;font-size:22px;font-weight:800;margin-top:4px;">${_esc(to)}</div>
                  </td>
                </tr>
              </table>
            </td>
          </tr>
        </table>
      </td>
    </tr>

    <!-- ── TRIP INFO GRID ── -->
    <tr>
      <td style="padding:0 40px 20px;">
        <table width="100%" cellpadding="0" cellspacing="0"
          style="background:#F8F9FA;border-radius:12px;border:1px solid #E5E7EB;padding:20px;">
          <tr>
            <td style="padding-bottom:16px;width:50%;vertical-align:top;">
              <div style="font-size:9px;color:#6B7280;letter-spacing:1.5px;font-weight:600;text-transform:uppercase;">Journey Date</div>
              <div style="font-size:14px;font-weight:700;color:#1A1A2E;margin-top:4px;">${_esc(journeyDate)}</div>
            </td>
            <td style="padding-bottom:16px;width:50%;vertical-align:top;">
              <div style="font-size:9px;color:#6B7280;letter-spacing:1.5px;font-weight:600;text-transform:uppercase;">Departure Time</div>
              <div style="font-size:14px;font-weight:700;color:#E82E59;margin-top:4px;">${_esc(journeyTime)}</div>
            </td>
          </tr>
          <tr>
            <td style="padding-bottom:0;width:50%;vertical-align:top;">
              <div style="font-size:9px;color:#6B7280;letter-spacing:1.5px;font-weight:600;text-transform:uppercase;">Seat(s)</div>
              <div style="font-size:14px;font-weight:700;color:#1A1A2E;margin-top:4px;">${_esc(seats)}</div>
            </td>
            <td style="padding-bottom:0;width:50%;vertical-align:top;">
              <div style="font-size:9px;color:#6B7280;letter-spacing:1.5px;font-weight:600;text-transform:uppercase;">Bus</div>
              <div style="font-size:14px;font-weight:700;color:#1A1A2E;margin-top:4px;">${_esc(busName)}</div>
            </td>
          </tr>
        </table>
      </td>
    </tr>

    <!-- ── PAYMENT SUMMARY ── -->
    <tr>
      <td style="padding:0 40px 24px;">
        <table width="100%" cellpadding="0" cellspacing="0"
          style="background:#fff;border-radius:12px;border:1px solid #E5E7EB;padding:20px;">
          <tr>
            <td colspan="2" style="padding-bottom:14px;">
              <div style="font-size:9px;color:#6B7280;letter-spacing:1.5px;font-weight:600;text-transform:uppercase;">Payment Summary</div>
            </td>
          </tr>
          <tr>
            <td style="color:#6B7280;font-size:13px;padding:5px 0;">Ticket Price</td>
            <td align="right" style="color:#1A1A2E;font-size:13px;font-weight:600;">₹${ticketPrice}</td>
          </tr>
          <tr>
            <td style="color:#6B7280;font-size:13px;padding:5px 0;">GST (5%)</td>
            <td align="right" style="color:#1A1A2E;font-size:13px;font-weight:600;">₹${gst}</td>
          </tr>
          <tr>
            <td style="color:#6B7280;font-size:13px;padding:5px 0;">Platform Fee</td>
            <td align="right" style="color:#1A1A2E;font-size:13px;font-weight:600;">₹${platformFee}</td>
          </tr>
          <tr>
            <td colspan="2" style="padding:10px 0 0;"><hr style="border:none;border-top:1px solid #E5E7EB;margin:0;" /></td>
          </tr>
          <tr>
            <td style="color:#1A1A2E;font-size:15px;font-weight:700;padding-top:10px;">Total Paid</td>
            <td align="right" style="color:#E82E59;font-size:18px;font-weight:800;padding-top:10px;">₹${totalPaid}</td>
          </tr>
          <tr>
            <td style="color:#6B7280;font-size:12px;padding-top:6px;">Payment via</td>
            <td align="right" style="color:#6B7280;font-size:12px;padding-top:6px;">${_esc(payment)}</td>
          </tr>
        </table>
      </td>
    </tr>

    <!-- ── PDF BUTTON ── -->
    ${pdfBtn ? `<tr><td align="center" style="padding:0 40px 28px;">${pdfBtn}</td></tr>` : ""}

    <!-- ── FOOTER ── -->
    <tr>
      <td style="background:#FFF1F3;padding:20px 40px;border-top:1px solid #FFD6DF;">
        <div style="text-align:center;color:#E82E59;font-size:14px;font-weight:700;">
          Thank you for travelling with Savarii! 🚌
        </div>
        <div style="text-align:center;color:#6B7280;font-size:11px;margin-top:8px;">
          System-generated e-ticket. No signature required. &nbsp;|&nbsp; support@savarii.co.in
        </div>
      </td>
    </tr>

  </table>
  </td></tr>
</table>

</body>
</html>`;
}

// ── Helpers ────────────────────────────────────────────────────────────────
function _fmt(val) {
  const n = typeof val === "number" ? val : parseFloat(val || "0");
  return isNaN(n) ? "0.00" : n.toFixed(2);
}

function _esc(str) {
  return String(str ?? "")
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;");
}

module.exports = { sendTicketEmail };
