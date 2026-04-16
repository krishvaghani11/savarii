import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DriverSignupController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  // Reactive states for password visibility toggles
  final RxBool isPasswordVisible = false.obs;
  final RxBool isConfirmPasswordVisible = false.obs;

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  void signUp() {
    if (formKey.currentState!.validate()) {
      print("Creating driver account...");
      print("Name: ${nameController.text}");
      print("Email: ${emailController.text}");
      
      // Simulate API call and routing to Driver Dashboard or OTP verification
      Get.snackbar(
        'Success',
        'Account created successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade50,
        colorText: Colors.green.shade800,
      );
    }
  }

  void goToLogin() {
    print("Navigating back to Driver Login...");
    // Just pop the current screen to return to the Login view
    Get.back(); 
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}