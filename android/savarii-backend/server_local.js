const express = require("express");
const cors = require("cors");
const bodyParser = require("body-parser");
const twilio = require("twilio");

const app = express();
app.use(cors());
app.use(bodyParser.json());

const PORT = 3000;



const client = twilio(accountSid, authToken);

// ===== LOGGING =====
app.use((req, res, next) => {
  console.log(`📩 ${req.method} ${req.url}`);
  next();
});

// ===== SEND OTP =====
app.post("/send-otp", async (req, res) => {
  try {
    const { phone } = req.body;

    if (!phone) {
      return res.status(400).send({ error: "Phone required" });
    }

    console.log("📱 Sending OTP to:", phone);

    await client.verify.v2.services(verifySid)
      .verifications.create({
        to: phone,
        channel: "sms",
      });

    console.log("✅ OTP Sent via Twilio");

    res.send({ success: true });

  } catch (e) {
    console.error("❌ Send OTP Error:", e.message);
    res.status(500).send({ error: "Failed to send OTP" });
  }
});

// ===== VERIFY OTP =====
app.post("/verify-otp", async (req, res) => {
  try {
    const { phone, otp } = req.body;

    if (!phone || !otp) {
      return res.status(400).send({ error: "Phone and OTP required" });
    }

    console.log(`🔍 Verifying OTP ${otp} for ${phone}`);

    const verificationCheck = await client.verify.v2
      .services(verifySid)
      .verificationChecks.create({
        to: phone,
        code: otp,
      });

    if (verificationCheck.status !== "approved") {
      console.log("❌ Invalid OTP");
      return res.status(400).send({ error: "Invalid OTP" });
    }

    console.log("✅ OTP Verified Successfully");

    // Stable UID (IMPORTANT)
    const uid = phone;

    res.send({
      success: true,
      uid,
    });

  } catch (e) {
    console.error("❌ Verify OTP Error:", e.message);
    res.status(500).send({ error: "Verification failed" });
  }
});

// ===== START SERVER =====
// Listen on '0.0.0.0' to allow connections from other devices on the same network
app.listen(PORT, "0.0.0.0", () => {
  console.log("=================================");
  console.log("🚀 Savarii Backend Running (Twilio)");
  console.log(`🌐 Accepting connections on port ${PORT}`);
  console.log("=================================");
});
