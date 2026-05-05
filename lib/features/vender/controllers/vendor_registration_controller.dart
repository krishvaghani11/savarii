import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/firestore_service.dart';
import '../../../models/user_model.dart';
import '../../../models/vendor_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../auth/controllers/auth_controller.dart';

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

    final authController = Get.find<AuthController>();

    try {
      isLoading.value = true;

      // 🔑 Block the auth-state listener from auto-routing while we write
      // to Firestore. Without this, _handleAuthChanged fires before the
      // user document exists and shows "Profile Not Found".
      authController.isRegistering.value = true;

      final email = emailController.text.trim();

      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: email,
            password: passwordController.text,
          );
      final uid = credential.user!.uid;

      // Check if already registered (edge-case: shouldn't happen on new accounts)
      final existing = await _firestore.getUserProfile(uid);
      if (existing != null) {
        authController.isRegistering.value = false;
        Get.snackbar(
          "Already Registered",
          "This email is already registered. Please login instead.",
        );
        isLoading.value = false;
        return;
      }

      // ── Write user doc ──
      await _firestore.createUserProfile(
        UserModel(
          uid: uid,
          email: email,
          role: 'vendor',
          createdAt: DateTime.now(),
        ),
      );

      // ── Write vendor profile doc ──
      await _firestore.createVendorProfile(
        VendorModel(
          uid: uid,
          userId: uid,
          name: fullNameController.text.trim(),
          email: email,
          phone: rawPhone,
          businessName: '',
          address: '',
          createdAt: DateTime.now(),
        ),
      );

      // ✅ Both docs written — navigate to vendor app
      await authController.navigateAfterRegistration(uid, 'vendor');

    } catch (e) {
      // Reset guard so the normal auth flow is not permanently blocked
      authController.isRegistering.value = false;
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
