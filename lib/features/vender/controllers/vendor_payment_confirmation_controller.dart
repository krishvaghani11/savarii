import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VendorPaymentConfirmationController extends GetxController {
  late final String bookingId;
  late final String passengerName;
  late final String journeyDate;
  late final String busImageUrl;
  late final String route;
  late final String busAndSeat;
  late final String paymentMethod;

  // Pricing Data
  late final double ticketPrice;
  late final double gst;
  late final double platformFee;
  late final double totalPaid;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>? ?? {};

    bookingId = args['bookingId'] ?? "PNR-10005";
    passengerName = args['passengerName'] ?? "Unknown Passenger";
    journeyDate = args['journeyDate'] ?? "Unknown Date";
    busImageUrl = args['busImage'] ?? '';
    route = args['route'] ?? "Unknown Route";
    busAndSeat = args['busAndSeat'] ?? "Unknown Bus | N/A";
    paymentMethod = args['paymentMethod'] ?? "UPI";

    final tp = args['ticketPrice'] ?? 0.0;
    ticketPrice = (tp is int) ? tp.toDouble() : (tp is double ? tp : double.tryParse(tp.toString()) ?? 0.0);

    final g = args['gst'] ?? 0.0;
    gst = (g is int) ? g.toDouble() : (g is double ? g : double.tryParse(g.toString()) ?? 0.0);

    final pf = args['platformFee'] ?? 10.00;
    platformFee = (pf is int) ? pf.toDouble() : (pf is double ? pf : double.tryParse(pf.toString()) ?? 10.00);

    final to = args['totalPaid'] ?? (ticketPrice + gst + platformFee);
    totalPaid = (to is int) ? to.toDouble() : (to is double ? to : double.tryParse(to.toString()) ?? (ticketPrice + gst + platformFee));
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
