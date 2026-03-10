import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BookingConfirmationController extends GetxController {
  final String bookingId = 'SV-98231';

  // Dummy Data for the ticket
  final String fromCity = "Mumbai";
  final String toCity = "Pune";
  final String departureTime = "10:00\nAM";
  final String arrivalTime = "01:45\nPM";
  final String duration = "3h 45m";
  final String date = "Oct 24,\n2023";
  final String seat = "4A (Window)";
  final String passengers = "1 Adult";
  final String travelClass = "Sleeper AC";

  void closeAndGoHome() {
    print("Returning to Dashboard...");
    // Clears the stack and goes back to the main layout
    Get.until((route) => Get.currentRoute == '/main-layout' || route.isFirst);
  }

  void downloadETicket() {
    print("Downloading e-ticket...");
    Get.snackbar(
      'Downloading...',
      'Your E-Ticket is saving to your device.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue.shade50,
      colorText: Colors.blue.shade800,
    );
  }

  void needHelp() {
    print("Opening Help Center for booking $bookingId...");
    // Get.toNamed('/help-support');
  }
}
