import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VendorForgotPasswordController extends GetxController {
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
      
      // Optional: You can add a check here to ensure the email actually exists in your Firestore DB
      // final userDoc = await _firestore.getUser(email.toLowerCase());
      // if (!userDoc.exists) throw Exception("Account not found for this email.");
      
      await Future.delayed(const Duration(seconds: 1)); // Brief delay for smooth UX

      // Navigate DIRECTLY to the reset password screen, and pass the email!
      Get.toNamed('/vendor-reset-password', arguments: {'email': email});

      // Clear field after navigating
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