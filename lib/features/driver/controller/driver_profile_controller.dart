import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DriverProfileController extends GetxController {
  
  // Mock Data mapped perfectly from the screenshot
  final String driverName = "Rajesh Sharma";
  final String driverId = "SAV-9821";
  final String joinDate = "Member since July 2021";
  
  final String rating = "4.9/5";
  final String totalTrips = "1.2k";
  final String totalEarnings = "₹45k";

  final String mobileNumber = "+91 98765 43210";
  final String vehicleDetails = "Bharat Benz GJ 01 AA 1234";
  final String drivingLicense = "DL-20210056789";

  void showMoreOptions() {
    print("Opening top right menu...");
  }

  void editProfile() {
    print("Navigating to Edit Profile...");
    // Get.toNamed('/driver-edit-profile');
  }

  void viewVehicleDocuments() {
    print("Navigating to Vehicle Documents...");
    // Get.toNamed('/driver-vehicle-documents');
  }

  void openSupport() {
    print("Navigating to Support...");
    // Get.toNamed('/support');
  }

  void openSettings() {
    print("Navigating to Settings...");
    // Get.toNamed('/settings');
  }

  void logOut() {
    print("Logging out...");
    Get.defaultDialog(
      title: "Log Out",
      middleText: "Are you sure you want to log out of your account?",
      textConfirm: "Log Out",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      buttonColor: Colors.redAccent,
      onConfirm: () {
        // Clear session and navigate to Role Selection/Login
        Get.offAllNamed('/role-selection');
      },
    );
  }
}