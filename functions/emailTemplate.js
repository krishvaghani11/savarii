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

module.exports = { buildResetEmailHtml };
