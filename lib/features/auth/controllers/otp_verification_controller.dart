import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/auth_api_service.dart';
import '../../../core/services/firestore_service.dart';
import 'auth_controller.dart';

class OTPVerificationController extends GetxController {
  final AuthApiService _api = Get.find();
  final FirestoreService _firestore = Get.find();
  final AuthController _authController = Get.find();

  String get phoneNumber => _authController.phone.value;

  final List<TextEditingController> otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );

  final List<FocusNode> focusNodes = List.generate(6, (index) => FocusNode());

  var isLoading = false.obs;

  void onOTPChanged(String value, int index) {
    if (value.length > 1) {
      for (int i = 0; i < value.length; i++) {
        if (index + i < 6) {
          otpControllers[index + i].text = value[i];
        }
      }
      focusNodes[(index + value.length).clamp(0, 5)].requestFocus();
      return;
    }

    if (value.length == 1 && index < 5) {
      focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      focusNodes[index - 1].requestFocus();
    }
  }

  String get enteredOtp => otpControllers.map((e) => e.text).join();

  Future<void> onVerifyClicked() async {
    try {
      final otp = enteredOtp;

      if (otp.length != 6) {
        Get.snackbar("Error", "Enter valid OTP");
        return;
      }

      isLoading.value = true;

      /// ✅ VERIFY OTP
      final uid = await _api.verifyOtp(_authController.phone.value, otp);

      // CRITICAL: Store UID in AuthController before moving to next screen
      _authController.uid = uid;

      final doc = await _firestore.getUser(uid);

      if (!doc.exists) {
        if (_authController.selectedRole.value == "customer") {
          await _createCustomer(uid);
          Get.offAllNamed('/location-access');
        } else {
          // Navigating to vendor registration
          Get.toNamed('/vendor-registration');
        }
      } else {
        final role = doc['role'];

        if (role != _authController.selectedRole.value) {
          throw Exception("Wrong role selected");
        }

        Get.offAllNamed('/location-access');
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _createCustomer(String uid) async {
    await _firestore.createUser(uid, {
      "phone": _authController.phone.value,
      "role": "customer",
      "createdAt": DateTime.now(),
    });

    await _firestore.createWallet(uid);
  }

  @override
  void onClose() {
    for (var c in otpControllers) c.dispose();
    for (var f in focusNodes) f.dispose();
    super.onClose();
  }
}
