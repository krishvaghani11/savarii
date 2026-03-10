import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:savarii/features/customer/home/controller/main_layout_controller.dart';

class CustomerHomeController extends GetxController {
  // Global key to control the Scaffold's Drawer from anywhere
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  // User details (dummy data for now)
  final String userName = "Savarii User";
  final double walletBalance = 45.50;

  // --- Sidebar Logic ---
  void openSidebar() {
    scaffoldKey.currentState?.openDrawer();
  }

  void closeSidebar() {
    scaffoldKey.currentState?.closeDrawer();
  }

  // --- Dashboard Quick Actions ---
  void goToNotifications() {
    print("Navigating to Notifications Screen...");
    // Get.toNamed('/notifications');
  }

  void goToBookTicket() {
    print("Navigating to Seat Selection/Bus Search...");
    Get.toNamed('/book-ticket');
  }

  void goToTrackBus() {
    closeSidebar(); // Closes sidebar if opened from there
    print("Navigating to Live Tracking...");
    Get.toNamed('/track-bus');
  }

  void goToBookParcel() {
    print("Navigating to Parcel Booking...");
    Get.toNamed('/book-parcel');
  }

  void goToWallet() {
    print("Navigating to Wallet...");
    if (Get.isRegistered<MainLayoutController>()) {
      // 0 = Home, 1 = Trips, 2 = Wallet, 3 = Profile
      Get.find<MainLayoutController>().changeTab(2);
    } else {
      // Fallback: If for some reason they aren't on the dashboard, route directly
      Get.toNamed('/wallet');
    }
  }

  // --- Sidebar Navigation ---
  void goToMyBookings() {
    closeSidebar();
    print("Navigating to My Bookings...");
    Get.toNamed('/my-bookings');
  }

  void goToHelpAndSupport() {
    closeSidebar();
    print("Navigating to Help & Support...");
    Get.toNamed('/help-support');
  }

  void goToLanguage() {
    closeSidebar();
    print("Navigating to Language Settings...");
    Get.toNamed('/language');
  }

  void goToAboutUs() {
    closeSidebar();
    print("Navigating to About Us...");
    Get.toNamed('/about-us');
  }

  void logout() {
    closeSidebar();
    print("Logging out user...");
    // Get.offAllNamed('/role-selection');
  }
}
