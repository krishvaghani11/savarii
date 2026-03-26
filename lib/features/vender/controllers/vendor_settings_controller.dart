import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VendorSettingsController extends GetxController {
  // Notification States
  final RxBool pushNotifications = true.obs;
  final RxBool smsAlerts = false.obs;
  final RxBool emailUpdates = true.obs;

  // App States
  final RxBool darkMode = false.obs;
  final RxString currentLanguage = 'English'.obs;

  // Toggle Methods
  void togglePushNotifications(bool value) => pushNotifications.value = value;

  void toggleSmsAlerts(bool value) => smsAlerts.value = value;

  void toggleEmailUpdates(bool value) => emailUpdates.value = value;

  void toggleDarkMode(bool value) {
    darkMode.value = value;
    // TODO: Implement actual theme switching logic here
  }

  // Navigation Actions

  void changeLanguage() {
    print("Opening Language Selector from Settings...");
    Get.toNamed('/vendor-language');
  }

  void openHelpCenter() {
    print("Navigating to Help Center...");
    Get.toNamed('/vendor-help-center');
  }

  void openPrivacyPolicy() {
    print("Navigating to Privacy Policy...");
    Get.toNamed('/vendor-privacy-policy');
  }

  void openTerms() {
    print("Navigating to Terms & Conditions...");
    Get.toNamed('/vendor-terms');
  }

  void deactivateAccount() {
    print("Initiating account deactivation...");
    Get.defaultDialog(
      title: "Deactivate Account?",
      middleText:
          "Are you sure you want to deactivate your vendor account? This action cannot be undone.",
      textConfirm: "Deactivate",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      cancelTextColor: Colors.black87,
      onConfirm: () {
        Get.back(); // Close dialog
        Get.snackbar(
          'Account Deactivated',
          'Your request is being processed.',
          snackPosition: SnackPosition.BOTTOM,
        );
      },
    );
  }
}
