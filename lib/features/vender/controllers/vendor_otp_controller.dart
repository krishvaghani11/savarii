import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VendorOtpController extends GetxController {
  // Capture the phone number passed from the previous screen
  String mobileNumber = "00000 00000";

  // Controllers and FocusNodes for the 6 OTP boxes
  final List<TextEditingController> otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> focusNodes = List.generate(6, (index) => FocusNode());

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null && Get.arguments['mobile'] != null) {
      mobileNumber = Get.arguments['mobile'];
    }
  }

  void verifyOtp() {
    // Combine the text from all 6 boxes
    String otp = otpControllers.map((controller) => controller.text).join();

    if (otp.length < 6) {
      Get.snackbar(
        'Incomplete OTP',
        'Please enter all 6 digits.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    print("Verifying OTP: $otp for +91 $mobileNumber...");

    Get.snackbar(
      'Verification Successful',
      'Welcome to the Vendor Dashboard!',
      backgroundColor: Colors.green.shade50,
      colorText: Colors.green.shade800,
      snackPosition: SnackPosition.BOTTOM,
    );

    // TODO: Route to Vendor Dashboard
    Get.offAllNamed('/vendor-main');
  }

  void resendOtp() {
    print("Resending OTP to +91 $mobileNumber...");
    // Clear current input
    for (var controller in otpControllers) {
      controller.clear();
    }
    focusNodes[0].requestFocus(); // Reset focus to the first box

    Get.snackbar(
      'Code Resent',
      'A new 6-digit code has been sent.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  void onClose() {
    for (var controller in otpControllers) {
      controller.dispose();
    }
    for (var node in focusNodes) {
      node.dispose();
    }
    super.onClose();
  }
}
