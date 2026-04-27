
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:savarii/routes/app_routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:savarii/features/auth/controllers/auth_controller.dart';

class DriverLoginController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Reactive state for password visibility toggle
  final RxBool isPasswordVisible = false.obs;
  final RxBool isLoading = false.obs;

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  Future<void> login() async {
    if (formKey.currentState!.validate()) {
      try {
        isLoading.value = true;
        
        final email = emailController.text.trim();
        final password = passwordController.text.trim();

        final credential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);
        
        final uid = credential.user!.uid;

        // Check if user is a driver
        final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
        if (doc.exists && doc.data()!['role'] == 'driver') {
          // Success
          final AuthController authController = Get.find();
          authController.selectedRole.value = 'driver';

          Get.snackbar(
            'Success',
            'Logged in successfully',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green.shade50,
            colorText: Colors.green.shade800,
          );

          Get.offAllNamed(AppRoutes.driverLocationAccess);
        } else {
          // Not a driver
          await FirebaseAuth.instance.signOut();
          Get.snackbar(
            'Login Failed',
            'You are not registered as a driver.',
            snackPosition: SnackPosition.TOP,
          );
        }
      } on FirebaseAuthException catch (e) {
        Get.snackbar(
             'Login Failed',
             e.message ?? 'Authentication error',
             snackPosition: SnackPosition.TOP,
        );
      } catch (e) {
        Get.snackbar(
             'Login Failed',
             e.toString(),
             snackPosition: SnackPosition.TOP,
        );
      } finally {
        isLoading.value = false;
      }
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