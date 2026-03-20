import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/auth_api_service.dart';
import '../../../core/services/firestore_service.dart';
import '../../auth/controllers/auth_controller.dart';

class VendorOtpController extends GetxController {
  final AuthApiService _api = Get.find();
  final FirestoreService _firestore = Get.find();
  final AuthController _authController = Get.find();

  String mobileNumber = "";

  final List<TextEditingController> otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );

  final List<FocusNode> focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void onInit() {
    super.onInit();
    mobileNumber = Get.arguments['mobile'];
  }

  String get enteredOtp => otpControllers.map((e) => e.text).join();

  Future<void> verifyOtp() async {
    try {
      final otp = enteredOtp;

      if (otp.length != 6) {
        Get.snackbar("Error", "Enter valid OTP");
        return;
      }

      final phone = "+91$mobileNumber";

      /// VERIFY WITH TWILIO
      final uid = await _api.verifyOtp(phone, otp);

      _authController.uid = uid;

      /// CHECK FIRESTORE
      final doc = await _firestore.getUser(uid);

      if (!doc.exists) {
        /// NEW VENDOR → REGISTRATION
        Get.toNamed('/vendor-registration');
      } else {
        /// EXISTING → LOGIN
        final role = doc['role'];

        if (role != "vendor") {
          throw Exception("Not a vendor account");
        }

        Get.offAllNamed('/vendor-location-access');
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  void resendOtp() async {
    final phone = "+91$mobileNumber";

    await _api.sendOtp(phone);

    for (var c in otpControllers) {
      c.clear();
    }

    focusNodes[0].requestFocus();

    Get.snackbar("OTP", "OTP Resent");
  }

  @override
  void onClose() {
    for (var c in otpControllers) c.dispose();
    for (var f in focusNodes) f.dispose();
    super.onClose();
  }
}
