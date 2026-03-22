import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/auth_api_service.dart';
import '../../../core/services/firestore_service.dart';
import '../../auth/controllers/auth_controller.dart';

class VendorLoginController extends GetxController {
  final TextEditingController mobileController = TextEditingController();

  final AuthApiService _api = Get.find();
  final FirestoreService _firestore = Get.find();
  final AuthController _authController = Get.find();

  var isLoading = false.obs;

  void login() async {
    try {
      isLoading.value = true;

      final phone = mobileController.text.trim();

      if (phone.length != 10) {
        Get.snackbar("Error", "Enter valid number");
        return;
      }

      final fullPhone = "+91$phone";

      _authController.phone.value = fullPhone;
      _authController.selectedRole.value = "vendor";

      /// SEND OTP (TWILIO)
      await _api.sendOtp(fullPhone);

      Get.toNamed('/vendor-otp', arguments: {"mobile": phone});
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void goToRegister() {
    Get.toNamed('/vendor-registration');
  }

  @override
  void onClose() {
    mobileController.dispose();
    super.onClose();
  }
}
