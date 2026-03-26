import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomerForgotPasswordController extends GetxController {
  final TextEditingController emailController = TextEditingController();
  final RxBool isLoading = false.obs;

  void sendResetLink() async {
    final email = emailController.text.trim();

    if (!GetUtils.isEmail(email)) {
      Get.snackbar(
        "Invalid Email",
        "Please enter a valid email address.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoading.value = true;
      
      // TODO: Connect to Firebase Auth to actually send the password reset email
      // Example: await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      
      await Future.delayed(const Duration(seconds: 2)); // Simulating network request

      // Show success message
      Get.snackbar(
        "Link Sent!",
        "Password reset instructions have been sent to $email.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade50,
        colorText: Colors.green.shade800,
      );

      // Clear the field and return the user to the login screen automatically
      emailController.clear();
      Future.delayed(const Duration(seconds: 1), () => Get.back());
      
    } catch (e) {
      Get.snackbar("Error", e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  void goBackToLogin() {
    Get.back();
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}