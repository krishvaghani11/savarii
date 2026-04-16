import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddDriverController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Personal Details
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController altMobileController = TextEditingController();

  // Identification & License
  final TextEditingController dlController = TextEditingController();
  final TextEditingController aadharController = TextEditingController();

  // Address Details
  final TextEditingController streetController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController pinCodeController = TextEditingController();

  // Actions
  void uploadDrivingLicense() {
    print("Trigger file picker for Driving License");
  }

  void uploadAadharCard() {
    print("Trigger file picker for Aadhar Card");
  }

  void selectPhoto() {
    print("Trigger gallery picker for Driver Photo");
  }

  void takeLivePhoto() {
    print("Trigger camera for Live Photo");
  }

  void saveDriverProfile() {
    // Collect data and validate
    print("Saving Driver Profile...");
    print("Name: ${nameController.text}");
    print("Phone: ${mobileController.text}");

    // Simulate API call
    Get.snackbar(
      'Profile Saved',
      'Driver details have been added successfully.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade50,
      colorText: Colors.green.shade800,
    );

    // Return to the driver management screen
    Get.back();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    altMobileController.dispose();
    dlController.dispose();
    aadharController.dispose();
    streetController.dispose();
    cityController.dispose();
    stateController.dispose();
    pinCodeController.dispose();
    super.onClose();
  }
}