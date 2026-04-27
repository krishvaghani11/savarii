import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../auth/controllers/auth_controller.dart';

class VendorLoginController extends GetxController {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final AuthController _authController = Get.find();

  var isLoading = false.obs;
  var isPasswordHidden = true.obs;

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  /// ─── EMAIL LOGIN FLOW ───
  void login() async {
    try {
      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      if (!GetUtils.isEmail(email)) {
        Get.snackbar(
          "Invalid Email",
          "Please enter a valid email address.",
          snackPosition: SnackPosition.TOP,
        );
        return;
      }
      if (password.isEmpty) {
        Get.snackbar(
          "Missing Password",
          "Please enter your password.",
          snackPosition: SnackPosition.TOP,
        );
        return;
      }

      isLoading.value = true;

      // Store role context
      _authController.selectedRole.value = "vendor";

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // AuthController listener will handle routing automatically
    } catch (e) {
      Get.snackbar(
        "Login Failed",
        e.toString(),
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void forgotPassword() {
    print("Navigating to forgot password...");
    Get.toNamed('/vendor-forgot-password');
  }

  void goToRegister() {
    Get.toNamed('/vendor-registration');
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
