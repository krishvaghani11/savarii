import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VendorEditProfileController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Text Controllers
  late final TextEditingController fullNameController;
  late final TextEditingController mobileController;
  late final TextEditingController emailController;
  late final TextEditingController travelsNameController;

  @override
  void onInit() {
    super.onInit();
    // Pre-filling with data from your mockup
    fullNameController = TextEditingController(text: "Rajesh Kumar");
    mobileController = TextEditingController(text: "9876543210");
    emailController = TextEditingController(text: "rajesh.kumar@travels.com");
    travelsNameController = TextEditingController(
      text: "Kumar Tours & Travels",
    );
  }

  void changePhoto() {
    print("Opening image picker...");
    Get.snackbar(
      'Change Photo',
      'Image picker would open here.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void saveChanges() {
    if (formKey.currentState!.validate()) {
      print("Saving profile changes for ${fullNameController.text}...");

      Get.snackbar(
        'Profile Updated',
        'Your information has been successfully saved.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade50,
        colorText: Colors.green.shade800,
      );

      // Navigate back to the profile screen after a short delay
      Future.delayed(const Duration(seconds: 1), () => Get.back());
    }
  }

  @override
  void onClose() {
    fullNameController.dispose();
    mobileController.dispose();
    emailController.dispose();
    travelsNameController.dispose();
    super.onClose();
  }
}
