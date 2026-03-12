import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VendorPaymentConfirmationController extends GetxController {
  // Dummy Data from your mockup
  final String bookingId = "SV-2023-10-105";
  final String passengerName = "Ramesh Kumar";
  final String journeyDate = "10/05/2023";
  final String route = "Delhi to Jaipur";
  final String busAndSeat = "Exp 402 | L1 (Lower)";
  final String paymentMethod = "UPI";

  // Pricing Data
  final double ticketPrice = 800.00;
  final double gst = 40.00;
  final double platformFee = 10.00;
  late final double totalPaid;

  @override
  void onInit() {
    super.onInit();
    totalPaid = ticketPrice + gst + platformFee;
  }

  void downloadTicket() {
    print("Downloading ticket $bookingId...");
    Get.snackbar(
      'Downloading',
      'Ticket is being saved to your device.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue.shade50,
      colorText: Colors.blue.shade800,
    );
  }

  void backToHome() {
    print("Returning to Vendor Dashboard...");
    // Clear the navigation stack and go back to the main layout
    Get.until((route) => Get.currentRoute == '/vendor-main' || route.isFirst);
  }
}
