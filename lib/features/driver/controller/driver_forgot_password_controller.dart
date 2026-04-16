import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DriverForgotPasswordController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();

  void submitResetRequest() {
    if (formKey.currentState!.validate()) {
      print("Submitting password reset for: ${emailController.text}");
      
      // Simulate API call
      Get.snackbar(
        'Request Sent',
        'Password reset instructions have been sent to your email.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade50,
        colorText: Colors.green.shade800,
        duration: const Duration(seconds: 4),
      );

      // Return to login screen after successful request
      Future.delayed(const Duration(seconds: 2), () {
        Get.back();
      });
    }
  }

  void backToLogin() {
    print("Returning to Driver Login...");
    Get.back();
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}