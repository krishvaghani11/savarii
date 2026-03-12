import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VendorLoginController extends GetxController {
  final TextEditingController mobileController = TextEditingController();

  void login() {
    if (mobileController.text.length < 10) {
      Get.snackbar(
        'Invalid Number',
        'Please enter a valid mobile number.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    print("Logging in Vendor with +91 ${mobileController.text}");
    // Simulate moving to an OTP screen or Dashboard
    Get.snackbar(
      'OTP Sent',
      'An OTP has been sent to your registered mobile number.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade50,
      colorText: Colors.green.shade800,
    );
    // Get.toNamed('/vendor-otp'); // Future step
  }

  void goToRegister() {
    print("Navigating to Vendor Registration...");
    Get.toNamed('/vendor-registration');
  }

  @override
  void onClose() {
    mobileController.dispose();
    super.onClose();
  }
}
