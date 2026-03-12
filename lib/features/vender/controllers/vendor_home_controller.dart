import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VendorHomeController extends GetxController {
  final String vendorName = "Rajesh Kumar"; // Updated to match mockup
  final String agencyName = "ROYAL TRAVELS INDIA";
  final String mobileNumber = "+91 98765 43210";
  final String date = "Oct 24, 2023";

  // Stats
  final String activeBuses = "12";
  final String ticketsSold = "84";
  final String earnings = "₹14k";
  final String todaysTrips = "48"; // New stat for the drawer

  void openNotifications() => print("Opening notifications...");

  // Dashboard Actions
  void addBusAndRoute() {
    print("Navigating to Add Bus...");
    Get.toNamed('/add-bus');
  }

  void viewBusTickets() {
    print("Navigating to View Tickets...");
    Get.toNamed('/vendor-view-tickets');
  }

  void bookTicket() {
    print("Navigating to Manual Booking...");
    Get.toNamed('/vendor-book-ticket');
  }

  void busTracking() => print("Navigating to Fleet Tracking...");

  // Sidebar Actions
  void closeDrawer() => Get.back();

  void goToLanguage() => print("Navigating to Language Selection...");

  void contactDeveloper() => print("Opening Contact Developer...");

  void logout() {
    print("Logging out Vendor...");
    Get.offAllNamed('/role-selection'); // Send them all the way back out
  }
}
