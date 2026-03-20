import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'auth_controller.dart';

class PhoneLoginController extends GetxController {
  final AuthController _authController = Get.find();

  // Controller for the text field
  final TextEditingController phoneController = TextEditingController();

  // Loading state
  RxBool get isLoading => _authController.isLoading;

  // Store the role passed from the previous screen
  late final String userRole;

  @override
  void onInit() {
    super.onInit();
    // Retrieve the role argument (defaults to customer if null)
    userRole = Get.arguments?['role'] ?? 'customer';
    _authController.selectedRole.value = userRole;
  }

  @override
  void onClose() {
    phoneController.dispose();
    super.onClose();
  }

  Future<void> sendOtp(String phoneNumber) async {
    await _authController.sendOtp(phoneNumber);
  }
}
