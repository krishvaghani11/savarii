import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VendorTravelsDetailController extends GetxController {
  // Dummy Data from the mockup
  final String travelsName = "Malhotra Express Travels";
  final String establishedDate = "Est. 12th June 2010";
  final String fleetSize = "25";
  final String rating = "4.8";
  final String routes = "120+";

  // Business Info
  final String regNumber = "REG-2023-MH-99210";
  final String gstNumber = "27AAACH9921B1Z5";
  final String businessType = "Private Limited Entity";
  final String ownerName = "Rakesh Malhotra";

  // Coverage
  final String primaryRoutes = "Mumbai - Pune - Goa - Bangalore";

  // Contact Info
  final String primaryMobile = "+91 98765 43210";
  final String supportEmail = "support@malhotraexpress.com";
  final String officeAddress =
      "Suite 402, Business Hub, MG Road,\nPune, Maharashtra 411001";

  void editTravelsDetail() {
    print("Navigating to Edit Travels form...");
    // Redirect to the Add Travels screen
    Get.toNamed('/vendor-add-travels');
  }

  void copyToClipboard(String text, String label) {
    print("Copied $text to clipboard");
    Get.snackbar(
      '$label Copied',
      '$text has been copied to your clipboard.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.black87,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  void sendEmail() {
    print("Opening email client to $supportEmail...");
  }
}
