import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VendorTermsController extends GetxController {
  void acceptTerms() {
    print("Terms Accepted.");
    Get.snackbar(
      'Terms Accepted',
      'Thank you for accepting the Savarii Vendor terms.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green.shade50,
      colorText: Colors.green.shade800,
    );

    // Navigate back to the previous screen
    Future.delayed(const Duration(seconds: 1), () => Get.back());
  }
}
