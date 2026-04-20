import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DriverSupportController extends GetxController {
  final TextEditingController searchController = TextEditingController();

  void openCategory(String categoryName) {
    print("Opening support category: $categoryName");
    // Get.toNamed('/driver-support-category', arguments: {'category': categoryName});
  }

  void callHelpDesk() {
    print("Initiating call to Help Desk...");
    Get.snackbar(
      'Calling Support',
      'Connecting you to the 24/7 help desk...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue.shade50,
      colorText: Colors.blue.shade800,
    );
  }

  void openChat() {
    print("Opening live chat...");
    // Get.toNamed('/driver-live-chat');
  }

  void openEmail() {
    print("Opening email client...");
    // Trigger url_launcher to open mailto:support@savarii.com
  }

  void openFaq(String faqId) {
    print("Opening FAQ article: $faqId");
    // Get.toNamed('/driver-faq-detail', arguments: {'id': faqId});
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}