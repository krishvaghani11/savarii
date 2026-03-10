import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TrackBusController extends GetxController {
  // Dummy Data from your mockup
  final String driverName = "Ramesh Kumar";
  final String driverPhone = "+91 98765 43210";
  final String driverRating = "4.8";
  final String busNumber = "KL-01-AB-1234";
  final String status = "Arriving in 5 mins";
  final String nextStop = "MG Road";

  final TextEditingController searchController = TextEditingController();

  void callDriver() {
    print("Calling driver at $driverPhone...");
    // TODO: Implement url_launcher to open phone dialer
  }

  void shareLiveLocation() {
    print("Opening share dialog for live location...");
    Get.snackbar(
      'Location Shared',
      'Live tracking link generated successfully.',
      snackPosition: SnackPosition.TOP,
    );
  }

  void recenterMap() {
    print("Recentering map to current location...");
  }

  void zoomIn() => print("Zooming in...");

  void zoomOut() => print("Zooming out...");

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
