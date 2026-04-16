
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:savarii/routes/app_routes.dart';

class DriverLoginController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Reactive state for password visibility toggle
  final RxBool isPasswordVisible = false.obs;

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void login() {
    if (formKey.currentState!.validate()) {
      print("Logging in driver...");
      print("Email: ${emailController.text}");
      
      // Simulate API call and routing to Driver Dashboard
      // Get.offAllNamed('/driver-dashboard');
    }
  }

  void goToForgotPassword() {
    Get.toNamed(AppRoutes.driverForgotPassword);
  }

  void goToSignUp() {
     Get.toNamed(AppRoutes.driverSignup);
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}