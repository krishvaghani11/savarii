/**
 * buildResetEmailHtml
 * Returns a professional branded HTML email for Savarii password reset.
 *
 * @param {string} resetLink - The Firebase password reset URL
 * @param {string} role      - "customer" | "vendor" | "driver"
 * @returns {string}         - Full HTML string
 */
function buildResetEmailHtml(resetLink, role) {
  const roleLabel =
    role.charAt(0).toUpperCase() + role.slice(1).toLowerCase();

  return `
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Reset Your Savarii Password</title>
  <style>
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body {
      background-color: #f4f6f9;
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto,
        Oxygen, Ubuntu, sans-serif;
      -webkit-font-smoothing: antialiased;
    }
    .wrapper {
      max-width: 600px;
      margin: 40px auto;
      padding: 20px;
    }
    .card {
      background: #ffffff;
      border-radius: 16px;
      overflow: hidden;
      box-shadow: 0 4px 24px rgba(0,0,0,0.08);
    }
    .header {
      background: linear-gradient(135deg, #1a56db 0%, #0e3fa3 100%);
      padding: 40px 32px;
      text-align: center;
    }
    .header-logo {
      font-size: 28px;
      font-weight: 800;
      color: #ffffff;
      letter-spacing: -0.5px;
    }
    .header-logo span {
      color: #93c5fd;
    }
    .header-tagline {
      color: rgba(255,255,255,0.75);
      font-size: 13px;
      margin-top: 4px;
    }
    .icon-circle {
      width: 72px;
      height: 72px;
      background: rgba(255,255,255,0.15);
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
      margin: 24px auto 0;
      font-size: 32px;
    }
    .body {
      padding: 40px 36px;
    }
    .greeting {
      font-size: 22px;
      font-weight: 700;
      color: #1a1d2e;
      margin-bottom: 12px;
    }
    .message {
      font-size: 15px;
      color: #5a6478;
      line-height: 1.7;
      margin-bottom: 32px;
    }
    .button-wrap {
      text-align: center;
      margin-bottom: 32px;
    }
    .btn {
      display: inline-block;
      background: linear-gradient(135deg, #1a56db, #0e3fa3);
      color: #ffffff !important;
      text-decoration: none;
      font-size: 16px;
      font-weight: 700;
      padding: 16px 40px;
      border-radius: 10px;
      letter-spacing: 0.3px;
    }
    .divider {
      border: none;
      border-top: 1px solid #eef0f4;
      margin: 0 0 24px;
    }
    .fallback-title {
      font-size: 13px;
      font-weight: 600;
      color: #8a94a6;
      text-transform: uppercase;
      letter-spacing: 0.5px;
      margin-bottom: 8px;
    }
    .fallback-link {
      font-size: 13px;
      color: #1a56db;
      word-break: break-all;
    }
    .info-box {
      background: #f0f7ff;
      border-left: 4px solid #1a56db;
      border-radius: 6px;
      padding: 14px 16px;
      margin-top: 24px;
    }
    .info-box p {
      font-size: 13px;
      color: #3b4a6b;
      line-height: 1.6;
    }
    .info-box p + p {
      margin-top: 6px;
    }
    .footer {
      background: #f9fafb;
      border-top: 1px solid #eef0f4;
      padding: 24px 36px;
      text-align: center;
    }
    .footer p {
      font-size: 12px;
      color: #9aa3b2;
      line-height: 1.6;
    }
    .footer a {
      color: #1a56db;
      text-decoration: none;
    }
    @media (max-width: 480px) {
      .body { padding: 28px 20px; }
      .footer { padding: 20px; }
    }
  </style>
</head>
<body>
  <div class="wrapper">
    <div class="card">

      <!-- ── Header ── -->
      <div class="header">
        <div class="header-logo">Savarii<span>.</span></div>
        <div class="header-tagline">Your trusted travel companion</div>
        <div class="icon-circle">🔐</div>
      </div>

      <!-- ── Body ── -->
      <div class="body">
        <p class="greeting">Reset Your Password</p>
        <p class="message">
          Hi there,<br /><br />
          We received a request to reset the password for your
          <strong>Savarii ${roleLabel}</strong> account.
          Click the button below to choose a new password.
          This link will expire in <strong>1 hour</strong>.
        </p>

        <div class="button-wrap">
          <a class="btn" href="${resetLink}" target="_blank">
            Reset Password
          </a>
        </div>

        <hr class="divider" />

        <p class="fallback-title">Button not working?</p>
        <p class="fallback-link">
          Copy and paste this link into your browser:<br />
          <a href="${resetLink}">${resetLink}</a>
        </p>

        <div class="info-box">
          <p>⏱ <strong>This link expires in 1 hour.</strong> Request a new one if it has expired.</p>
          <p>🔒 If you did not request a password reset, you can safely ignore this email — your account is not at risk.</p>
        </div>
      </div>

      <!-- ── Footer ── -->
      <div class="footer">
        <p>
          This email was sent by <strong>Savarii</strong> to the address associated
          with your ${roleLabel} account.<br />
          &copy; ${new Date().getFullYear()} Savarii. All rights reserved.<br />
          <a href="mailto:support@savarii.co.in">support@savarii.co.in</a>
        </p>
      </div>

    </div><!-- /.card -->
  </div><!-- /.wrapper -->
</body>
</html>
`.trim();
}

/**
 * buildParcelConfirmationEmailHtml
 * Premium Savarii branded email for parcel booking confirmations.
 */
function buildParcelConfirmationEmailHtml(data) {
  const brandRed = "#E82E59";
  const trackingId = data.trackingId || "N/A";

  return `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width,initial-scale=1.0" />
  <title>Parcel Booked Successfully</title>
  <style>
    body { font-family: 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; margin: 0; padding: 0; background-color: #f4f7f9; color: #333; }
    .container { max-width: 600px; margin: 20px auto; background: #ffffff; border-radius: 16px; overflow: hidden; box-shadow: 0 10px 30px rgba(0,0,0,0.05); }
    .header { background: linear-gradient(135deg, ${brandRed} 0%, #ff6b6b 100%); padding: 40px 20px; text-align: center; color: #ffffff; }
    .header h1 { margin: 0; font-size: 28px; font-weight: 700; letter-spacing: 1px; }
    .content { padding: 40px 30px; }
    .tracking-box { background: #fff1f3; border: 1px dashed ${brandRed}; border-radius: 12px; padding: 20px; text-align: center; margin-bottom: 30px; }
    .tracking-id { font-size: 24px; font-weight: 800; color: ${brandRed}; margin: 10px 0; }
    .section-title { font-size: 14px; font-weight: 800; color: #9ca3af; text-transform: uppercase; letter-spacing: 1.5px; margin-bottom: 15px; border-bottom: 1px solid #f3f4f6; padding-bottom: 8px; }
    .detail-row { display: flex; justify-content: space-between; margin-bottom: 12px; font-size: 15px; }
    .detail-label { color: #6b7280; }
    .detail-value { color: #111827; font-weight: 600; }
    .route-container { display: flex; align-items: center; margin: 20px 0; padding: 20px; background: #f9fafb; border-radius: 12px; }
    .route-point { flex: 1; text-align: center; }
    .route-arrow { padding: 0 15px; color: #d1d5db; font-size: 20px; }
    .city-name { font-size: 16px; font-weight: 700; color: #111827; }
    .time-val { font-size: 12px; color: #6b7280; margin-top: 4px; }
    .footer { background: #f9fafb; padding: 30px; text-align: center; color: #9ca3af; font-size: 13px; }
    .btn { display: inline-block; padding: 14px 35px; background-color: ${brandRed}; color: #ffffff; text-decoration: none; border-radius: 10px; font-weight: 700; margin-top: 25px; transition: all 0.3s ease; }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h1>SAVARII</h1>
      <p style="margin-top: 10px; opacity: 0.9; font-weight: 500;">Parcel Booked Successfully!</p>
    </div>
    
    <div class="content">
      <p style="font-size: 16px; line-height: 1.6; color: #4b5563;">Hello <strong>${data.senderName}</strong>,</p>
      <p style="font-size: 16px; line-height: 1.6; color: #4b5563;">Great news! Your parcel has been successfully booked with Savarii. Our logistics team will handle your shipment with the utmost care.</p>
      
      <div class="tracking-box">
        <div style="font-size: 12px; font-weight: 700; color: #6b7280; text-transform: uppercase;">Tracking ID</div>
        <div class="tracking-id">${trackingId}</div>
      </div>

      <div class="section-title">Logistics Details</div>
      <div class="route-container">
        <div class="route-point">
          <div class="city-name">${data.pickupCity}</div>
          <div class="time-val">${data.pickupTime}</div>
        </div>
        <div class="route-arrow">➔</div>
        <div class="route-point">
          <div class="city-name">${data.dropCity}</div>
          <div class="time-val">${data.dropTime}</div>
        </div>
      </div>

      <div class="detail-row">
        <span class="detail-label">Parcel Type</span>
        <span class="detail-value">${data.parcelType}</span>
      </div>
      <div class="detail-row">
        <span class="detail-label">Weight</span>
        <span class="detail-value">${data.weight} KG</span>
      </div>
      <div class="detail-row">
        <span class="detail-label">Receiver</span>
        <span class="detail-value">${data.receiverName}</span>
      </div>

      <div style="margin-top: 30px;" class="section-title">Payment Summary</div>
      <div class="detail-row">
        <span class="detail-label">Total Amount Paid</span>
        <span class="detail-value" style="color: ${brandRed}; font-size: 18px;">₹${parseFloat(data.totalPaid).toFixed(2)}</span>
      </div>
      <div class="detail-row">
        <span class="detail-label">Payment Method</span>
        <span class="detail-value">${data.paymentMethod}</span>
      </div>

      <div style="text-align: center;">
        ${data.receiptUrl 
          ? `<a href="${data.receiptUrl}" class="btn">Download Parcel Receipt</a>`
          : `<a href="https://savarii.app/track/${trackingId}" class="btn">Track Your Parcel</a>`
        }
      </div>
    </div>
    
    <div class="footer">
      <p>Need help? Contact us at support@savarii.co.in</p>
      <p style="margin-top: 10px;">&copy; 2026 Savarii Logistics. All rights reserved.</p>
    </div>
  </div>
</body>
</html>`;
}

/**
 * buildWalletTopupEmailHtml
 * Returns a branded HTML email for wallet top-up confirmation.
 */
function buildWalletTopupEmailHtml(data) {
  const { name, amount, transactionId, date, updatedBalance } = data;
  return `
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Wallet Top-up Successful</title>
  <style>
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body {
      background-color: #f4f6f9;
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
    }
    .wrapper { max-width: 600px; margin: 40px auto; padding: 20px; }
    .card { background: #ffffff; border-radius: 16px; overflow: hidden; box-shadow: 0 4px 24px rgba(0,0,0,0.08); }
    .header { background: linear-gradient(135deg, #E82E59 0%, #B01E42 100%); padding: 40px 32px; text-align: center; color: #ffffff; }
    .header-logo { font-size: 28px; font-weight: 800; letter-spacing: -0.5px; }
    .header-tagline { color: rgba(255,255,255,0.8); font-size: 13px; margin-top: 4px; }
    .icon-circle { width: 72px; height: 72px; background: rgba(255,255,255,0.2); border-radius: 50%; display: flex; align-items: center; justify-content: center; margin: 24px auto 0; font-size: 32px; }
    .body { padding: 40px 36px; }
    .greeting { font-size: 22px; font-weight: 700; color: #1a1d2e; margin-bottom: 8px; }
    .amount-display { font-size: 32px; font-weight: 800; color: #E82E59; margin: 24px 0; text-align: center; }
    .details-table { width: 100%; border-collapse: collapse; margin: 24px 0; border-top: 1px solid #eef0f4; }
    .details-row { border-bottom: 1px solid #eef0f4; }
    .details-label { padding: 12px 0; color: #8a94a6; font-size: 13px; text-transform: uppercase; letter-spacing: 0.5px; width: 40%; }
    .details-value { padding: 12px 0; color: #1a1d2e; font-size: 14px; font-weight: 600; text-align: right; }
    .footer { background: #f9fafb; border-top: 1px solid #eef0f4; padding: 24px 36px; text-align: center; }
    .footer p { font-size: 12px; color: #9aa3b2; line-height: 1.6; }
    .footer a { color: #E82E59; text-decoration: none; }
  </style>
</head>
<body>
  <div class="wrapper">
    <div class="card">
      <div class="header">
        <div class="header-logo">Savarii Wallet</div>
        <div class="header-tagline">Money Credited Successfully</div>
        <div class="icon-circle">💰</div>
      </div>
      <div class="body">
        <p class="greeting">Hi ${name},</p>
        <p style="color: #5a6478; line-height: 1.6;">Good news! Your Savarii wallet has been topped up successfully. The funds are now available for booking tickets and parcels.</p>
        
        <div class="amount-display">₹${parseFloat(amount).toFixed(2)}</div>
        
        <table class="details-table">
          <tr class="details-row">
            <td class="details-label">Transaction ID</td>
            <td class="details-value">${transactionId}</td>
          </tr>
          <tr class="details-row">
            <td class="details-label">Date & Time</td>
            <td class="details-value">${date}</td>
          </tr>
          <tr class="details-row">
            <td class="details-label">Updated Balance</td>
            <td class="details-value">₹${parseFloat(updatedBalance).toFixed(2)}</td>
          </tr>
        </table>
        
        <p style="color: #8a94a6; font-size: 12px; text-align: center; margin-top: 32px;">If you have any questions regarding this transaction, please contact our support team.</p>
      </div>
      <div class="footer">
        <p>&copy; ${new Date().getFullYear()} Savarii. All rights reserved.<br />
        <a href="mailto:support@savarii.co.in">support@savarii.co.in</a></p>
      </div>
    </div>
  </div>
</body>
</html>
`.trim();
}

module.exports = { buildResetEmailHtml, buildWalletTopupEmailHtml, buildParcelConfirmationEmailHtml };
