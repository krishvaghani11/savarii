import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReviewTripController extends GetxController {
  // Using 4 as default rating based on your UI mockup
  final RxInt overallRating = 4.obs;
  final RxInt driverRating = 5.obs;
  final RxInt cleanlinessRating = 3.obs;
  final RxInt punctualityRating = 4.obs;

  final TextEditingController feedbackController = TextEditingController();

  void setOverallRating(int rating) => overallRating.value = rating;

  void setDriverRating(int rating) => driverRating.value = rating;

  void setCleanlinessRating(int rating) => cleanlinessRating.value = rating;

  void setPunctualityRating(int rating) => punctualityRating.value = rating;

  void submitReview() {
    print("--- Submitting Review ---");
    print("Overall: ${overallRating.value}");
    print("Driver: ${driverRating.value}");
    print("Cleanliness: ${cleanlinessRating.value}");
    print("Punctuality: ${punctualityRating.value}");
    print("Feedback: ${feedbackController.text}");

    // TODO: Send data to API/Database here

    Get.back(); // Go back to bookings screen
    Get.snackbar(
      'Thank You!',
      'Your review has been successfully submitted.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade50,
      colorText: Colors.green.shade800,
    );
  }

  @override
  void onClose() {
    feedbackController.dispose();
    super.onClose();
  }
}
