import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:savarii/core/services/forgot_password_service.dart';

class DriverForgotPasswordController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final RxBool isLoading = false.obs;

  /// Sends a password-reset request to the Savarii Cloud Function.
  /// The function uses Firebase Admin SDK + Resend to deliver a branded
  /// email from support@savarii.co.in.
  ///
  /// Always shows a generic success message — the backend never reveals
  /// whether the email is registered (prevents user enumeration).
  Future<void> submitResetRequest() async {
    // Validate the form (includes email format check via TextFormField validator)
    if (!formKey.currentState!.validate()) return;

    final email = emailController.text.trim();

    isLoading.value = true;

    final result = await ForgotPasswordService.sendResetLink(
      email: email,
      role: 'driver',
    );

    isLoading.value = false;

    if (result.success) {
      Get.snackbar(
        'Check Your Inbox',
        result.message,
        snackPosition: SnackPosition.TOP,
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
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade800,
        icon: const Icon(Icons.error_outline, color: Colors.red),
      );
    }
  }

  void backToLogin() => Get.back();

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}