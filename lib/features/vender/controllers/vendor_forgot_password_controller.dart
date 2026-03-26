import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VendorForgotPasswordController extends GetxController {
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
      
      // Optional: Connect to your backend/Firebase here
      // final userDoc = await _firestore.getUser(email.toLowerCase());
      // if (!userDoc.exists) throw Exception("Account not found for this email.");
      
      // Simulating a network request to send the email
      await Future.delayed(const Duration(seconds: 2)); 

      // Show success message
      Get.snackbar(
        "Link Sent!",
        "Password reset instructions have been sent to $email.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade50,
        colorText: Colors.green.shade800,
      );

      // Clear the text field and safely navigate back to login
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