import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OTPVerificationController extends GetxController {
  // Dummy data for UI display
  final String dummyPhoneNumber = "+91 00000 00000";

  // Basic controllers just to hold the UI structure
  final List<TextEditingController> otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> focusNodes = List.generate(6, (index) => FocusNode());

  @override
  void onOTPChanged(String value, int index) {
    // Handle Pasting a full 6-digit code
    if (value.length > 1) {
      for (int i = 0; i < value.length; i++) {
        if (index + i < 6) {
          otpControllers[index + i].text = value[i];
        }
      }
      int focusTarget = (index + value.length).clamp(0, 5);
      focusNodes[focusTarget].requestFocus();
      return;
    }

    // Handle standard typing: Move focus to the NEXT box
    if (value.length == 1 && index < 5) {
      focusNodes[index + 1].requestFocus();
    }
    // Handle backspace: Move focus to the PREVIOUS box
    else if (value.isEmpty && index > 0) {
      focusNodes[index - 1].requestFocus();
    }
  }

  void onVerifyClicked() {
    Get.offAllNamed('/location-access');
    // Placeholder for when you add logic later
    print("Verify button clicked");
  }
}
