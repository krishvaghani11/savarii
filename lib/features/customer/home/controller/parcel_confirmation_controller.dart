import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Needed for Clipboard
import 'package:get/get.dart';

class ParcelConfirmationController extends GetxController {
  final String trackingId = '#SAV-8923';

  // Timeline Data matching the previous screen
  final String pickupLocation = 'Downtown Bus Terminal';
  final String pickupTime = '10:30 AM Today';
  final String dropoffLocation = 'Sector 42, Gurgaon';
  final String dropoffTime = '03:00 PM Today';

  void copyTrackingId() {
    Clipboard.setData(ClipboardData(text: trackingId));
    Get.snackbar(
      'Copied',
      'Tracking ID copied to clipboard.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.black87,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  void downloadInvoice() {
    print("Downloading invoice...");
    Get.snackbar(
      'Downloading...',
      'Your invoice is being downloaded.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue.shade50,
      colorText: Colors.blue.shade800,
    );
  }

  void trackParcel() {
    print("Navigating to Track Parcel Screen...");
    // TODO: Create and route to the Track Parcel screen
    // Get.toNamed('/track-parcel');
  }

  void backToHome() {
    print("Returning to Dashboard...");
    // Clears the entire navigation stack and goes back to the main layout
    Get.until((route) => Get.currentRoute == '/main-layout' || route.isFirst);
  }
}