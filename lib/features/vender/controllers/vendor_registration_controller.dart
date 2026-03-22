import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/firestore_service.dart';
import '../../auth/controllers/auth_controller.dart';

class VendorRegistrationController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController travelsNameController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController currentAddressController =
      TextEditingController();
  final TextEditingController permanentAddressController =
      TextEditingController();

  final FirestoreService _firestore = Get.find();
  final AuthController _authController = Get.find();

  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (_authController.phone.value.isNotEmpty) {
      String displayPhone = _authController.phone.value;
      if (displayPhone.startsWith('+91')) {
        displayPhone = displayPhone.substring(3);
      }
      mobileController.text = displayPhone;
    }
  }

  Future<void> completeRegistration() async {
    print("UID: ${_authController.uid}");
    if (!formKey.currentState!.validate()) return;
    if (isLoading.value) return;

    // Unfocus to prevent disposed controller errors during navigation
    FocusManager.instance.primaryFocus?.unfocus();

    try {
      final uid = _authController.uid;

      if (uid == null || uid.isEmpty) {
        Get.offAllNamed('/vendor-login');
        Get.snackbar("Session Expired", "Please login again");
        return;
      }

      isLoading.value = true;

      final phone = _authController.phone.value;

      /// CHECK EXISTING
      final existing = await _firestore.getUser(uid);
      if (existing.exists) {
        Get.snackbar("Error", "User already registered");
        isLoading.value = false;
        return;
      }

      /// VALIDATE EMAIL
      if (!GetUtils.isEmail(emailController.text.trim())) {
        Get.snackbar("Error", "Invalid email");
        isLoading.value = false;
        return;
      }

      /// CREATE USER
      await _firestore.createUser(uid, {
        "phone": phone,
        "role": "vendor",
        "createdAt": DateTime.now(),
        "lastLogin": DateTime.now(),
        "isLoggedIn": true,
      });

      /// CREATE VENDOR
      await _firestore.createVendor(uid, {
        "userId": uid,
        "travelsName": travelsNameController.text.trim(),
        "fullName": fullNameController.text.trim(),
        "email": emailController.text.trim(),
        "currentAddress": currentAddressController.text.trim(),
        "permanentAddress": permanentAddressController.text.trim(),
        "createdAt": DateTime.now(),
      });

      Get.snackbar("Success", "Registration completed");
      Get.offAllNamed('/vendor-location-access');
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    travelsNameController.dispose();
    fullNameController.dispose();
    mobileController.dispose();
    emailController.dispose();
    currentAddressController.dispose();
    permanentAddressController.dispose();
    super.onClose();
  }
}
