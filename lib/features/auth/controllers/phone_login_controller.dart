import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PhoneLoginController extends GetxController {
  // Controller for the text field
  final TextEditingController phoneController = TextEditingController();

  // Store the role passed from the previous screen
  late final String userRole;

  @override
  void onInit() {
    super.onInit();
    // Retrieve the role argument (defaults to customer if null)
    userRole = Get.arguments?['role'] ?? 'customer';
  }

  @override
  void onClose() {
    phoneController.dispose();
    super.onClose();
  }

  void sendOtp() {
    final phoneNumber = phoneController.text.trim();
    if (phoneNumber.length < 10) {
      Get.snackbar(
        'Invalid Number',
        'Please enter a valid 10-digit mobile number.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // TODO: Integrate Firebase Auth here later
    print('Sending OTP to +91 $phoneNumber for role: $userRole');
    Get.toNamed('/otp-verify');
    // Navigate to OTP verification screen (we will build this next)
    // Get.toNamed('/otp-verify', arguments: {'phone': phoneNumber, 'role': userRole});
  }
}
