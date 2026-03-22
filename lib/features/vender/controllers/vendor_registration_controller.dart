import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/firestore_service.dart';
import '../../auth/controllers/auth_controller.dart';

class VendorRegistrationController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController travelsNameController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController mobileController =
      TextEditingController(); // UI only
  final TextEditingController emailController = TextEditingController();
  final TextEditingController currentAddressController =
      TextEditingController();
  final TextEditingController permanentAddressController =
      TextEditingController();

  final FirestoreService _firestore = Get.find();
  final AuthController _authController = Get.find();

  @override
  void onInit() {
    super.onInit();
    // Pre-fill the mobile number if available
    if (_authController.phone.value.isNotEmpty) {
      // Remove +91 for display if present
      String displayPhone = _authController.phone.value;
      if (displayPhone.startsWith('+91')) {
        displayPhone = displayPhone.substring(3);
      }
      mobileController.text = displayPhone;
    }
  }

  Future<void> completeRegistration() async {
    if (!formKey.currentState!.validate()) return;

    try {
      final uid = _authController.uid;

      if (uid == null || uid.isEmpty) {
        Get.snackbar("Error", "Authentication session expired. Please login again.");
        return;
      }

      /// 🔥 Prevent duplicate users
      final existing = await _firestore.getUser(uid);
      if (existing.exists) {
        Get.snackbar("Error", "User already registered");
        return;
      }

      /// 🔥 Validate email
      if (!GetUtils.isEmail(emailController.text.trim())) {
        Get.snackbar("Error", "Invalid email");
        return;
      }

      /// 🔥 Use verified phone (NOT input field)
      final phone = _authController.phone.value;

      /// SAVE USER
      await _firestore.createUser(uid, {
        "phone": phone,
        "role": "vendor",
        "createdAt": DateTime.now(),
      });

      /// SAVE VENDOR DATA
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
