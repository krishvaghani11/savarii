import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../core/services/firestore_service.dart';
import '../../../models/user_model.dart';

class CustomerRegistrationController extends GetxController {
  final AuthController _authController = Get.find();

  // Text Controllers
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  // States
  final RxBool isLoading = false.obs;
  final RxBool isPasswordHidden = true.obs;
  final RxBool isConfirmPasswordHidden = true.obs;

  @override
  void onInit() {
    super.onInit();
    _authController.selectedRole.value = 'customer';
  }

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordHidden.value = !isConfirmPasswordHidden.value;
  }

  void signUp() async {
    final fullName = fullNameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    // Validations
    if (fullName.isEmpty) {
      Get.snackbar(
        "Missing Name",
        "Please enter your full name.",
        snackPosition: SnackPosition.TOP,
      );
      return;
    }
    if (!GetUtils.isEmail(email)) {
      Get.snackbar(
        "Invalid Email",
        "Please enter a valid email address.",
        snackPosition: SnackPosition.TOP,
      );
      return;
    }
    if (password.length < 6) {
      Get.snackbar(
        "Weak Password",
        "Password must be at least 6 characters.",
        snackPosition: SnackPosition.TOP,
      );
      return;
    }
    if (password != confirmPassword) {
      Get.snackbar(
        "Mismatch",
        "Passwords do not match.",
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    final authController = Get.find<AuthController>();

    try {
      isLoading.value = true;

      // 🔑 Block the auth-state listener from auto-routing while Firestore
      // writes are in progress. Without this, _handleAuthChanged fires before
      // the user document exists and shows "Profile Not Found".
      authController.isRegistering.value = true;

      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      final uid = credential.user!.uid;
      await credential.user!.updateDisplayName(fullName);

      final firestoreService = Get.find<FirestoreService>();
      await firestoreService.createUserProfile(
        UserModel(
          uid: uid,
          email: email,
          role: 'customer',
          createdAt: DateTime.now(),
        ),
      );

      // ✅ Firestore doc written — navigate to customer app
      await authController.navigateAfterRegistration(uid, 'customer');

    } catch (e) {
      // Reset guard so the normal auth flow is not permanently blocked
      authController.isRegistering.value = false;
      Get.snackbar(
        "Registration Failed",
        e.toString(),
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void goToLogin() {
    Get.back(); // Or Get.offNamed('/customer-login');
  }

  @override
  void onClose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
