import 'package:get/get.dart';
import '../../../core/services/auth_api_service.dart';
import '../../../core/services/firestore_service.dart';
import '../../../routes/app_routes.dart';

class AuthController extends GetxController {
  final AuthApiService _api = Get.find();
  final FirestoreService _firestore = Get.find();

  var selectedRole = ''.obs;
  var phone = ''.obs;
  var isLoading = false.obs;
  var isLoggedIn = false.obs;

  String? uid;

  /// ==============================
  /// SEND OTP
  /// ==============================
  Future<void> sendOtp(String phoneNumber) async {
    try {
      isLoading.value = true;

      /// CLEAR OLD SESSION
      uid = null;

      phone.value = phoneNumber;

      await _api.sendOtp(phoneNumber);

      Get.toNamed(AppRoutes.otpVerify);
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// ==============================
  /// VERIFY OTP
  /// ==============================
  Future<void> verifyOtp(String otp) async {
    try {
      isLoading.value = true;

      /// VERIFY WITH TWILIO
      final verifiedUid = await _api.verifyOtp(phone.value, otp);

      /// 🔥 STORE SESSION
      uid = verifiedUid;
      isLoggedIn.value = true;

      final doc = await _firestore.getUser(uid!);

      /// ==============================
      /// NEW USER FLOW
      /// ==============================
      if (!doc.exists) {
        if (selectedRole.value == "customer") {
          await _createCustomer();

          Get.offAllNamed(AppRoutes.locationAccess);
        } else {
          /// Vendor → go to registration
          Get.toNamed(AppRoutes.vendorRegistration);
        }
      }
      /// ==============================
      /// EXISTING USER FLOW
      /// ==============================
      else {
        final role = doc['role'];

        if (role != selectedRole.value) {
          throw Exception("Wrong role selected");
        }

        /// 🔥 UPDATE LOGIN STATUS
        await _firestore.createUser(uid!, {
          "lastLogin": DateTime.now(),
          "isLoggedIn": true,
        });

        Get.offAllNamed(AppRoutes.locationAccess);
      }
    } catch (e) {
      Get.snackbar("Auth Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// ==============================
  /// CREATE CUSTOMER
  /// ==============================
  Future<void> _createCustomer() async {
    await _firestore.createUser(uid!, {
      "phone": phone.value,
      "role": "customer",
      "createdAt": DateTime.now(),
      "lastLogin": DateTime.now(),
      "isLoggedIn": true,
    });

    await _firestore.createWallet(uid!);
  }

  /// ==============================
  /// CREATE VENDOR (AFTER REGISTRATION)
  /// ==============================
  Future<void> createVendor({
    required String name,
    required String email,
    required String businessName,
    required String address,
  }) async {
    try {
      if (uid == null || uid!.isEmpty) {
        Get.snackbar("Session Expired", "Please login again");
        Get.offAllNamed(AppRoutes.phoneLogin);
        return;
      }

      /// CREATE USER
      await _firestore.createUser(uid!, {
        "phone": phone.value,
        "role": "vendor",
        "createdAt": DateTime.now(),
        "lastLogin": DateTime.now(),
        "isLoggedIn": true,
      });

      /// CREATE VENDOR DATA
      await _firestore.createVendor(uid!, {
        "userId": uid,
        "name": name,
        "email": email,
        "businessName": businessName,
        "address": address,
        "createdAt": DateTime.now(),
      });

      Get.offAllNamed(AppRoutes.locationAccess);
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  /// ==============================
  /// LOGOUT (FUTURE USE)
  /// ==============================
  void logout() {
    uid = null;
    phone.value = "";
    selectedRole.value = "";
    isLoggedIn.value = false;

    Get.offAllNamed(AppRoutes.phoneLogin);
  }
}
