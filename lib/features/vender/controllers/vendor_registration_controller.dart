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
    // Pre-fill phone if already set (e.g. coming from login screen)
    final existingPhone = _authController.phone.value;
    if (existingPhone.isNotEmpty) {
      String display = existingPhone;
      if (display.startsWith('+91')) display = display.substring(3);
      mobileController.text = display;
    }
  }

  Future<void> completeRegistration() async {
    if (!formKey.currentState!.validate()) return;
    if (isLoading.value) return;

    FocusManager.instance.primaryFocus?.unfocus();

    try {
      isLoading.value = true;

      final rawPhone = mobileController.text.trim();

      // Validate phone length
      if (rawPhone.length != 10) {
        Get.snackbar("Error", "Enter a valid 10-digit mobile number");
        return;
      }

      // UID is derived directly from the phone number (same as what backend returns)
      final uid = "+91$rawPhone";
      final phone = "+91$rawPhone";

      // Validate email
      if (!GetUtils.isEmail(emailController.text.trim())) {
        Get.snackbar("Error", "Enter a valid email address");
        return;
      }

      // Check if already registered
      final existing = await _firestore.getUser(uid);
      if (existing.exists) {
        Get.snackbar(
          "Already Registered",
          "This number is already registered. Please login instead.",
        );
        isLoading.value = false;
        return;
      }

      // ── Save user doc ──
      await _firestore.createUser(uid, {
        "phone": phone,
        "role": "vendor",
        "createdAt": DateTime.now(),
        "lastLogin": DateTime.now(),
        "isLoggedIn": true,
      });

      // ── Save vendor profile doc ──
      await _firestore.createVendor(uid, {
        "userId": uid,
        "travelsName": travelsNameController.text.trim(),
        "fullName": fullNameController.text.trim(),
        "email": emailController.text.trim(),
        "currentAddress": currentAddressController.text.trim(),
        "permanentAddress": permanentAddressController.text.trim(),
        "createdAt": DateTime.now(),
      });

      // ── Store session in AuthController ──
      _authController.uid = uid;
      _authController.phone.value = phone;
      _authController.isLoggedIn.value = true;

      Get.snackbar("Success", "Registration completed!");
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
