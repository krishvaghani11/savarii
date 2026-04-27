import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SecuritySettingsController extends GetxController {
  // Toggle States (matching the mockup defaults)
  final RxBool biometricAuth = true.obs;
  final RxBool rememberMe = true.obs;
  final RxBool twoStepVerification = false.obs;
  final RxBool securityAlerts = true.obs;

  void toggleBiometric(bool value) => biometricAuth.value = value;

  void toggleRememberMe(bool value) => rememberMe.value = value;

  void toggleTwoStep(bool value) => twoStepVerification.value = value;

  void toggleSecurityAlerts(bool value) => securityAlerts.value = value;

  // Navigation Actions
  void goToChangePassword() => print("Navigating to Change Password...");

  void goToTrustedDevices() => print("Navigating to Trusted Devices...");

  // Session Management
  void logoutDevice(String deviceName) {
    print("Logging out from $deviceName...");
    Get.snackbar(
      'Session Terminated',
      'You have been logged out of $deviceName.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.black87,
      colorText: Colors.white,
    );
    // TODO: Actually remove the device from the active sessions list in the backend
  }
}
