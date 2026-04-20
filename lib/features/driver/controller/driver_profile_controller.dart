import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:savarii/features/auth/controllers/auth_controller.dart';

class DriverProfileController extends GetxController {
  
  final rxDriverName = "".obs;
  final rxMobileNumber = "".obs;
  final rxJoinDate = "".obs;
  final rxVehicleDetails = "N/A".obs;
  final rxDrivingLicense = "N/A".obs;
  final rxProfileImageUrl = "".obs;

  @override
  void onInit() {
    super.onInit();
    fetchDriverDetails();
  }

  Future<void> fetchDriverDetails() async {
    final authController = Get.find<AuthController>();
    final uid = authController.uid;
    if (uid == null) return;

    try {
      final doc = await FirebaseFirestore.instance.collection('drivers').doc(uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        rxDriverName.value = data['name'] ?? 'Unknown Driver';
        rxMobileNumber.value = data['phone'] ?? '';
        rxDrivingLicense.value = data['dlNumber'] ?? data['licenseNumber'] ?? 'N/A';
        rxProfileImageUrl.value = data['profileImageUrl'] ?? '';

        // Fetch vehicle details by querying the buses collection for this driver's mobile
        try {
           final busQuery = await FirebaseFirestore.instance
               .collection('buses')
               .where('driver.mobile', isEqualTo: rxMobileNumber.value)
               .get();
               
           if (busQuery.docs.isNotEmpty) {
               final busData = busQuery.docs.first.data();
               rxVehicleDetails.value = "${busData['busName'] ?? ''} - ${busData['busNumber'] ?? ''}";
           } else {
               rxVehicleDetails.value = "No Bus Assigned";
           }
        } catch (busError) {
           print("Error fetching mapped bus: $busError");
        }
      }
    } catch (e) {
      print("Error fetching driver profile: $e");
    }
  }

  void showMoreOptions() {
    print("Opening top right menu...");
  }

  void editProfile() {
    print("Navigating to Edit Profile...");
     Get.toNamed('/edit-driver-profile');
  }

  void viewVehicleDocuments() {
    print("Navigating to Vehicle Documents...");
     Get.toNamed('/driver-documents');
  }

  void openSupport() {
    print("Navigating to Support...");
     Get.toNamed('/driver-support');
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