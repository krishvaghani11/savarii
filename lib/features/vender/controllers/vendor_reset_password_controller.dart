import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import '../../../core/services/firestore_service.dart'; // Uncomment when DB is connected

class VendorResetPasswordController extends GetxController {
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  final RxBool isLoading = false.obs;
  
  final RxBool isNewPasswordHidden = true.obs;
  final RxBool isConfirmPasswordHidden = true.obs;

  late String targetEmail; // To store the email passed from the previous screen

  @override
  void onInit() {
    super.onInit();
    // Retrieve the email passed from the Forgot Password screen
    final args = Get.arguments;
    if (args != null && args['email'] != null) {
      targetEmail = args['email'];
    } else {
      targetEmail = ''; // Fallback
    }
  }

  void toggleNewPasswordVisibility() {
    isNewPasswordHidden.value = !isNewPasswordHidden.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordHidden.value = !isConfirmPasswordHidden.value;
  }

  void updatePassword() async {
    final newPass = newPasswordController.text;
    final confirmPass = confirmPasswordController.text;

    if (newPass.length < 6) {
      Get.snackbar("Weak Password", "Password must be at least 6 characters long.", snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if (newPass != confirmPass) {
      Get.snackbar("Mismatch", "Passwords do not match. Please try again.", snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if (targetEmail.isEmpty) {
      Get.snackbar("Error", "User email not found. Please go back and try again.", snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      isLoading.value = true;
      
      // TODO: Connect to Firebase/Backend to update the password using 'targetEmail'
      // Example using Firestore (Assuming ID is the lowercase email for mock purposes):
      // final uid = targetEmail.toLowerCase();
      // await _firestore.updateUser(uid, {"password": newPass}); // Note: Use Firebase Auth for real apps, not plain text!
      
      await Future.delayed(const Duration(seconds: 2)); // Mock DB delay

      Get.snackbar(
        "Success",
        "Your password has been successfully updated!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade50,
        colorText: Colors.green.shade800,
      );

      // Navigate all the way back to the login screen
      Get.offAllNamed('/vendor-login');
      
    } catch (e) {
      Get.snackbar("Error", e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  void goBackToLogin() {
    Get.offAllNamed('/vendor-login');
  }

  @override
  void onClose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}