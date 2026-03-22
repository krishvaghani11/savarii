import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthApiService {
  final String baseUrl = "https://savarii-backend.vercel.app/api";

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

  /// VERIFY OTP — returns phone as uid on success, null if backend misbehaves
  Future<String?> verifyOtp(String phone, String otp) async {
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
    return data['uid'] as String?;
  }
}
