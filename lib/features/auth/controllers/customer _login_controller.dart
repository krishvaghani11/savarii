import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../auth/controllers/auth_controller.dart';

class CustomerLoginController extends GetxController {
  final AuthController _authController = Get.find();

  // Text Controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // States
  final RxBool isLoading = false.obs;
  final RxBool isPasswordHidden = true.obs;

  @override
  void onInit() {
    super.onInit();
    // Ensure the app knows we are in the customer flow
    _authController.selectedRole.value = 'customer';
  }

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (!GetUtils.isEmail(email)) {
      Get.snackbar(
        "Invalid Email",
        "Please enter a valid email address.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (password.isEmpty) {
      Get.snackbar(
        "Missing Password",
        "Please enter your password.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoading.value = true;

      // ❌ DELETE lines 44-50 (mock):
      // TODO: Implement actual Firebase/Backend Email+Password login logic here
      // Example: await _authController.loginWithEmail(email, password);
      await Future.delayed(const Duration(seconds: 2)); // Mock network delay
      Get.offAllNamed('/customer-home');

      // ✅ REPLACE WITH:
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user!.uid;
      await _authController.saveVendorSession(vendorUid: uid, vendorPhone: '');
      Get.offAllNamed('/customer-home');
    } catch (e) {
      Get.snackbar(
        "Login Failed",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void goToSignUp() {
    // Navigate to the customer registration screen
    Get.toNamed('/customer-registration');
  }

  void goToForgotPassword() {
    // Navigate to the customer forgot password screen
    Get.toNamed('/customer-forgot-password');
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
