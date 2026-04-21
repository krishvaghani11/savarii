import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:savarii/core/services/forgot_password_service.dart';

class VendorForgotPasswordController extends GetxController {
  final TextEditingController emailController = TextEditingController();
  final RxBool isLoading = false.obs;

  /// Sends a password-reset request to the Savarii Cloud Function.
  /// The function uses Firebase Admin SDK + Resend to deliver a branded
  /// email from support@savarii.co.in.
  ///
  /// Always shows a generic success message — the backend never reveals
  /// whether the email is registered (prevents user enumeration).
  Future<void> sendResetLink() async {
    final email = emailController.text.trim();

    // Client-side email format validation
    if (!GetUtils.isEmail(email)) {
      Get.snackbar(
        'Invalid Email',
        'Please enter a valid email address.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade50,
        colorText: Colors.orange.shade800,
        icon: const Icon(Icons.warning_amber_rounded, color: Colors.orange),
      );
      return;
    }

    isLoading.value = true;

    final result = await ForgotPasswordService.sendResetLink(
      email: email,
      role: 'vendor',
    );

    isLoading.value = false;

    if (result.success) {
      Get.snackbar(
        'Check Your Inbox',
        result.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade50,
        colorText: Colors.green.shade800,
        duration: const Duration(seconds: 6),
        icon: const Icon(Icons.mark_email_read_outlined, color: Colors.green),
      );
      emailController.clear();
      Future.delayed(const Duration(seconds: 2), () => Get.back());
    } else {
      Get.snackbar(
        'Error',
        result.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade800,
        icon: const Icon(Icons.error_outline, color: Colors.red),
      );
    }
  }

  void goBackToLogin() => Get.back();

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}