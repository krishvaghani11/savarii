import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/firestore_service.dart';
import '../../../models/user_model.dart';
import '../../../models/vendor_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VendorRegistrationController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final FirestoreService _firestore = Get.find();

  final RxBool isLoading = false.obs;

  // Password Visibility States
  final RxBool isPasswordHidden = true.obs;
  final RxBool isConfirmPasswordHidden = true.obs;

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordHidden.value = !isConfirmPasswordHidden.value;
  }

  Future<void> completeRegistration() async {
    // Basic validations
    if (fullNameController.text.trim().isEmpty) {
      Get.snackbar("Error", "Please enter your full name");
      return;
    }

    final rawPhone = mobileController.text.trim();
    if (rawPhone.length != 10) {
      Get.snackbar("Error", "Enter a valid 10-digit mobile number");
      return;
    }

    if (!GetUtils.isEmail(emailController.text.trim())) {
      Get.snackbar("Error", "Enter a valid email address");
      return;
    }

    if (passwordController.text.length < 6) {
      Get.snackbar("Error", "Password must be at least 6 characters");
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      Get.snackbar("Error", "Passwords do not match");
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();

    try {
      isLoading.value = true;

      final email = emailController.text.trim();

      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: email,
            password: passwordController.text,
          );
      final uid = credential.user!.uid;

      // Check if already registered
      final existing = await _firestore.getUserProfile(uid);
      if (existing != null) {
        Get.snackbar(
          "Already Registered",
          "This email is already registered. Please login instead.",
        );
        isLoading.value = false;
        return;
      }

      // ── Save user doc ──
      await _firestore.createUserProfile(
        UserModel(
          uid: uid,
          email: email,
          role: 'vendor',
          createdAt: DateTime.now(),
        ),
      );

      // ── Save vendor profile doc ──
      await _firestore.createVendorProfile(
        VendorModel(
          uid: uid,
          userId: uid,
          name: fullNameController.text.trim(),
          email: email,
          phone: rawPhone,
          businessName: '', // Assuming not collected in this form
          address: '',      // Assuming not collected in this form
          createdAt: DateTime.now(),
        )
      );

      Get.snackbar(
        "Success",
        "Account created successfully!",
        snackPosition: SnackPosition.BOTTOM,
      );

      // AuthController will handle routing automatically
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void goToLogin() {
    Get.back(); // Or Get.toNamed('/vendor-login') depending on your routing flow
  }

  @override
  void onClose() {
    fullNameController.dispose();
    mobileController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
