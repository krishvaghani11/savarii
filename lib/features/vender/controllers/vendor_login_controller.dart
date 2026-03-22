import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/auth_api_service.dart';
import '../../auth/controllers/auth_controller.dart';

class VendorLoginController extends GetxController {
  final TextEditingController mobileController = TextEditingController();

  final AuthApiService _api = Get.find();
  final AuthController _authController = Get.find();

  var isLoading = false.obs;

  /// ─── EXISTING VENDOR: Enter phone → Send OTP → Verify OTP → Location ───
  void login() async {
    try {
      isLoading.value = true;

      final phone = mobileController.text.trim();

      if (phone.length != 10) {
        Get.snackbar("Error", "Enter a valid 10-digit mobile number");
        return;
      }

      final fullPhone = "+91$phone";

      // Store phone and role before navigating
      _authController.phone.value = fullPhone;
      _authController.selectedRole.value = "vendor";
      _authController.uid = null;

      // Send OTP via Twilio
      await _api.sendOtp(fullPhone);

      Get.toNamed('/vendor-otp', arguments: {"mobile": phone});
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// ─── NEW VENDOR: Go directly to registration form ───
  void goToRegister() {
    // New vendors fill the registration form directly.
    // No OTP at this stage — phone in the form is used as UID.
    Get.toNamed('/vendor-registration');
  }

  @override
  void onClose() {
    mobileController.dispose();
    super.onClose();
  }
}
