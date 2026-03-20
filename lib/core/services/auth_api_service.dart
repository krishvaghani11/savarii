import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthApiService {
  static const String computerIp = "172.20.10.3";
  final String baseUrl = "https://abc123.ngrok-free.app";

  /// SEND OTP
  Future<void> sendOtp(String phone) async {
    final response = await http
        .post(
          Uri.parse("$baseUrl/send-otp"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"phone": phone}),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['error'] ?? "Failed to send OTP");
    }
  }

  /// VERIFY OTP
  Future<String> verifyOtp(String phone, String otp) async {
    final response = await http
        .post(
          Uri.parse("$baseUrl/verify-otp"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"phone": phone, "otp": otp}),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['error'] ?? "Invalid OTP");
    }

    final data = jsonDecode(response.body);
    return data['uid'];
  }
}
