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

  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    mobileNumber = Get.arguments['mobile'];
  }

  String get enteredOtp => otpControllers.map((e) => e.text).join();

  /// ─── EXISTING VENDOR: Verify OTP → Check Firestore → Location ───
  Future<void> verifyOtp() async {
    try {
      final otp = enteredOtp;

      if (otp.length != 6) {
        Get.snackbar("Error", "Enter a valid 6-digit OTP");
        return;
      }

      isLoading.value = true;

      final phone = "+91$mobileNumber";

      // Verify with Twilio backend — returns uid (which equals phone)
      final uid = await _api.verifyOtp(phone, otp);

      if (uid == null || uid.isEmpty) {
        Get.snackbar("Error", "OTP verification failed. Please try again.");
        return;
      }

      // Store session
      _authController.uid = uid;
      _authController.phone.value = phone;
      _authController.isLoggedIn.value = true;

      // Check Firestore for existing vendor
      final doc = await _firestore.getUser(uid);

      if (!doc.exists) {
        // Account not found — show error and redirect to register
        Get.snackbar(
          "Not Registered",
          "No vendor account found. Please register first.",
        );
        Get.offAllNamed('/vendor-login');
        return;
      }

      final role = doc['role'];
      if (role != "vendor") {
        Get.snackbar("Error", "This number is not registered as a vendor.");
        Get.offAllNamed('/vendor-login');
        return;
      }

      // Update last login
      await _firestore.createUser(uid, {
        "lastLogin": DateTime.now(),
        "isLoggedIn": true,
      });

      Get.offAllNamed('/vendor-location-access');
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void resendOtp() async {
    try {
      final phone = "+91$mobileNumber";
      await _api.sendOtp(phone);

      for (var c in otpControllers) {
        c.clear();
      }
      focusNodes[0].requestFocus();

      Get.snackbar("OTP", "OTP resent successfully");
    } catch (e) {
      Get.snackbar("Error", "Failed to resend OTP: ${e.toString()}");
    }
  }

  @override
  void onClose() {
    for (var c in otpControllers) c.dispose();
    for (var f in focusNodes) f.dispose();
    super.onClose();
  }
}
