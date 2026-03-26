import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../auth/controllers/auth_controller.dart'; // Update path if needed
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
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (!GetUtils.isEmail(email)) {
      Get.snackbar(
        "Invalid Email",
        "Please enter a valid email address.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (password.length < 6) {
      Get.snackbar(
        "Weak Password",
        "Password must be at least 6 characters.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (password != confirmPassword) {
      Get.snackbar(
        "Mismatch",
        "Passwords do not match.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoading.value = true;

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
      // AuthController will auto-route using authStateChanges
    } catch (e) {
      Get.snackbar(
        "Registration Failed",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
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
