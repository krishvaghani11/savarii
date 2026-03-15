import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VendorHelpCenterController extends GetxController {
  final TextEditingController searchController = TextEditingController();

  void openCategory(String categoryName) {
    print("Opening category: $categoryName");
    Get.snackbar(
      'Category Selected',
      'Loading articles for $categoryName...',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void openArticle(String articleTitle) {
    print("Opening article: $articleTitle");
    Get.snackbar(
      'Opening Article',
      articleTitle,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void contactSupport() {
    print("Navigating to Contact Developer screen...");
    Get.toNamed(
      '/vendor-contact-developer',
    ); // Linking to the screen we built earlier!
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
