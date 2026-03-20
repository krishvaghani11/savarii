const twilio = require("twilio");

const client = twilio(
  process.env.ACCOUNT_SID,
  process.env.AUTH_TOKEN
);

module.exports = async (req, res) => {
  if (req.method !== "POST") {
    return res.status(405).send("Method Not Allowed");
  }

  try {
    const { phone } = req.body;

    await client.verify.v2.services(process.env.VERIFY_SID)
      .verifications.create({
        to: phone,
        channel: "sms",
      });

    res.status(200).json({ success: true });

  } catch (e) {
    res.status(500).json({ error: e.message });
  }
};