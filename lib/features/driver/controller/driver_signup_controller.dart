import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:savarii/features/auth/controllers/auth_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/services/firestore_service.dart';
import '../../../models/user_model.dart';
import 'package:savarii/routes/app_routes.dart';

class DriverSignupController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController licenseNumberController = TextEditingController();
  final TextEditingController licenseExpiryController = TextEditingController();
  final TextEditingController vehicleTypeController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final FirestoreService _firestoreService = Get.find();

  // Reactive states for password visibility toggles
  final RxBool isPasswordVisible = false.obs;
  final RxBool isConfirmPasswordVisible = false.obs;
  final RxBool isLoading = false.obs;

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  Future<void> signUp() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    try {
      isLoading.value = true;

      final email = emailController.text.trim();
      final password = passwordController.text.trim();
      final name = nameController.text.trim();
      final phone = phoneController.text.trim();
      final licenseNumber = licenseNumberController.text.trim();
      final licenseExpiry = licenseExpiryController.text.trim();
      final vehicleType = vehicleTypeController.text.trim();

      // Validate email format
      if (!GetUtils.isEmail(email)) {
        Get.snackbar(
          'Invalid Email',
          'Please enter a valid email address.',
          snackPosition: SnackPosition.TOP,
        );
        isLoading.value = false;
        return;
      }

      // Validate password length
      if (password.length < 6) {
        Get.snackbar(
          'Weak Password',
          'Password must be at least 6 characters long.',
          snackPosition: SnackPosition.TOP,
        );
        isLoading.value = false;
        return;
      }

      // Validate passwords match
      if (password != confirmPasswordController.text.trim()) {
        Get.snackbar(
          'Password Mismatch',
          'Passwords do not match.',
          snackPosition: SnackPosition.TOP,
        );
        isLoading.value = false;
        return;
      }

      // 1. Verify that the Vendor pre-registered this Driver via Phone AND Email
      final driverQuery = await FirebaseFirestore.instance
          .collection('drivers')
          .where('phone', isEqualTo: phone)
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (driverQuery.docs.isEmpty) {
        Get.snackbar(
          'Registration Denied',
          'Your vendor has not pre-registered this Phone and Email. Please contact your vendor.',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 4),
        );
        isLoading.value = false;
        return;
      }

      final existingDoc = driverQuery.docs.first;
      final existingData = existingDoc.data();
      final oldDocId = existingDoc.id;

      // 2. Create Firebase Auth account
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      final uid = credential.user!.uid;

      // 3. Create generic user document for Role access (in 'users' collection)
      await _firestoreService.createUserProfile(
        UserModel(
          uid: uid,
          email: email,
          role: 'driver',
          createdAt: DateTime.now(),
        ),
      );

      // 4. Transform and Migrate the Vendor record to the new Authenticated UID record
      final updatedDriverData = {
        ...existingData,
        'uid': uid,
        'email': email,
        'isVerified': true, // Verified since they matched vendor data and created Auth
        'status': 'ACTIVE',
      };

      // Create new document with UID as ID
      await FirebaseFirestore.instance.collection('drivers').doc(uid).set(updatedDriverData);

      // Delete the old unauthenticated document
      if (oldDocId != uid) {
        await FirebaseFirestore.instance.collection('drivers').doc(oldDocId).delete();
      }

      // 5. Update assigned Bus references if any
      final busQuery = await FirebaseFirestore.instance
          .collection('buses')
          .where('driver.driverId', isEqualTo: oldDocId)
          .get();
      
      for (var busDoc in busQuery.docs) {
        await FirebaseFirestore.instance
            .collection('buses')
            .doc(busDoc.id)
            .update({'driver.driverId': uid});
      }

      final AuthController authController = Get.find();
      authController.selectedRole.value = 'driver';

      Get.snackbar(
        'Success',
        'Profile Claimed & Signup Completed!',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.shade50,
        colorText: Colors.green.shade800,
      );

      // Explicitly direct the user to the location access screen immediately
      Get.offAllNamed(AppRoutes.driverLocationAccess);
    } catch (e) {
      Get.snackbar(
        'Signup Failed',
        e.toString(),
        snackPosition: SnackPosition.TOP,
      );
      print('Error during driver signup: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void goToLogin() {
    Get.back();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    licenseNumberController.dispose();
    licenseExpiryController.dispose();
    vehicleTypeController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
