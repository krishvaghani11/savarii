import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditProfileController extends GetxController {
  // Global key to manage and validate the form
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Text Controllers for input fields
  final TextEditingController nameController = TextEditingController(
    text: "John Doe",
  ); // Pre-filled for demo
  final TextEditingController emailController = TextEditingController(
    text: "johndoe@email.com",
  );
  final TextEditingController phoneController = TextEditingController(
    text: "+1 (555) 012-3456",
  );
  final TextEditingController dobController = TextEditingController(
    text: "January 01, 1990",
  );
  final RxString selectedGender = 'Male'.obs;

  void selectGender(String gender) {
    selectedGender.value = gender;
  }

  // Action Methods
  void saveProfile() {
    if (formKey.currentState!.validate()) {
      print("--- Saving Profile ---");
      print("Name: ${nameController.text}");
      print("Email: ${emailController.text}");
      print("Phone: ${phoneController.text}");
      print("DOB: ${dobController.text}");
      print("Gender: ${selectedGender.value}");
      // TODO: Implement actual save logic (API call) here
      Get.back();
      Get.snackbar(
        'Profile Updated',
        'Your changes have been saved successfully.',
      );
    }
  }

  void changeProfilePicture() {
    print("Opening gallery/camera for profile picture...");
    // TODO: Implement image picker logic
  }

  void changePassword() {
    print("Navigating to Change Password flow...");
    // TODO: Navigate to Change Password screen
  }

  void deleteAccount() {
    print("Requesting Account Deletion...");
    // TODO: Show confirmation dialog, then proceed to deletion
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    dobController.dispose();
    super.onClose();
  }
}
