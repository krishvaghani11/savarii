import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomerForgotPasswordController extends GetxController {
  final TextEditingController emailController = TextEditingController();
  final RxBool isLoading = false.obs;

  void verifyEmailAndProceed() async {
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
      
      // Optional: Check here if the customer email actually exists in your Firestore DB
      // final userDoc = await _firestore.getUser(email.toLowerCase());
      // if (!userDoc.exists) throw Exception("Account not found for this email.");
      
      await Future.delayed(const Duration(seconds: 1)); // Brief delay for smooth UX

      // Navigate DIRECTLY to the customer reset password screen, passing the email
      Get.toNamed('/customer-reset-password', arguments: {'email': email});

      // Clear the field after navigating
      emailController.clear();
      
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