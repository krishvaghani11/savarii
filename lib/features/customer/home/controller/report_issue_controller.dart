import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_assets.dart';

class ReportIssueController extends GetxController {
  // Dummy trip data (In a real app, you'd fetch this using the bookingId from Get.arguments)
  final String tripTitle = "Bus 402 - Downtown Express";
  final String tripDate = "Trip on Oct 24, 2023 • 08:45 AM";
  final String tripImage = AppAssets.busInteriorImage;

  // Form Data
  final List<String> issueCategories = [
    'Driver Behavior',
    'Bus Cleanliness',
    'Late Arrival/Departure',
    'Lost Item',
    'Payment Issue',
    'Other',
  ];
  final RxnString selectedCategory = RxnString();
  final TextEditingController descriptionController = TextEditingController();

  void selectCategory(String? category) {
    selectedCategory.value = category;
  }

  void uploadProof() {
    print("Opening gallery/camera to pick an image...");
    // TODO: Implement image picker logic
  }

  void submitReport() {
    if (selectedCategory.value == null || descriptionController.text.isEmpty) {
      Get.snackbar(
        'Missing Details',
        'Please select a category and provide a description.',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    print("--- Submitting Report ---");
    print("Category: ${selectedCategory.value}");
    print("Description: ${descriptionController.text}");

    // Navigate back to bookings
    Get.back();
    Get.snackbar(
      'Report Submitted',
      'We have received your report and our support team will look into it.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green.shade50,
      colorText: Colors.green.shade800,
    );
  }

  @override
  void onClose() {
    descriptionController.dispose();
    super.onClose();
  }
}
