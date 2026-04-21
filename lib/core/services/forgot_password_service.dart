import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// Result returned by [ForgotPasswordService.sendResetLink].
class ForgotPasswordResult {
  /// Whether the request was accepted by the server.
  final bool success;

  /// User-facing message (always generic to prevent enumeration).
  final String message;

  const ForgotPasswordResult({required this.success, required this.message});
}

/// Shared service that calls the Savarii Cloud Function to trigger a
/// password-reset email.
///
/// All three roles (customer, vendor, driver) use this single service —
/// the [role] field is sent to the backend for logging / analytics only.
///
/// The Cloud Function uses Firebase Admin SDK to generate the reset link
/// and Resend to deliver a branded email from support@savarii.co.in.
class ForgotPasswordService {
  ForgotPasswordService._(); // Prevent instantiation

  /// The base URL of the deployed Firebase Cloud Function.
  /// Read from the .env file at runtime.
  static String get _cloudFunctionUrl =>
      dotenv.env['CLOUD_FUNCTION_URL'] ??
      'https://us-central1-savarii-96869.cloudfunctions.net/forgotPassword';

  /// Sends a password-reset request to the backend.
  ///
  /// [email] — the user's email address (validated client-side first).
  /// [role]  — "customer" | "vendor" | "driver".
  ///
  /// Returns a [ForgotPasswordResult] that is always safe to show to the user
  /// (the server never reveals whether the email is registered).
  static Future<ForgotPasswordResult> sendResetLink({
    required String email,
    required String role,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(_cloudFunctionUrl),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({'email': email.trim().toLowerCase(), 'role': role}),
          )
          .timeout(const Duration(seconds: 20));

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && body['success'] == true) {
        return ForgotPasswordResult(
          success: true,
          message: body['message'] as String? ??
              'If your email is registered, a reset link has been sent.',
        );
      }

      // 400 — validation error (invalid email / role) — safe to surface
      if (response.statusCode == 400) {
        return ForgotPasswordResult(
          success: false,
          message: body['message'] as String? ?? 'Invalid request. Please check your email.',
        );
      }

      // 429 — rate limited
      if (response.statusCode == 429) {
        return ForgotPasswordResult(
          success: false,
          message: 'Too many attempts. Please wait a few minutes and try again.',
        );
      }

      // 5xx or unexpected
      return const ForgotPasswordResult(
        success: false,
        message: 'Service temporarily unavailable. Please try again later.',
      );
    } on http.ClientException {
      return const ForgotPasswordResult(
        success: false,
        message: 'Network error. Please check your connection and try again.',
      );
    } catch (_) {
      return const ForgotPasswordResult(
        success: false,
        message: 'An unexpected error occurred. Please try again.',
      );
    }
  }
}
