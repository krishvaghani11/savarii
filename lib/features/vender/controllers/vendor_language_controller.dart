import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VendorLanguageController extends GetxController {
  // Reactive state for the selected language
  final RxString selectedLanguage = 'English'.obs;

  void selectLanguage(String language) {
    selectedLanguage.value = language;
  }

  void saveLanguage() {
    print("Language saved as: ${selectedLanguage.value}");

    Get.snackbar(
      'Language Updated',
      'Your preferred language has been updated to ${selectedLanguage.value}.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade50,
      colorText: Colors.green.shade800,
    );

    // In a real app, you would update Get.updateLocale() here
    Future.delayed(const Duration(seconds: 1), () => Get.back());
  }
}
