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

  String? uid;

  /// SEND OTP
  Future<void> sendOtp(String phoneNumber) async {
    try {
      isLoading.value = true;
      phone.value = phoneNumber;

      await _api.sendOtp(phoneNumber);
      Get.toNamed(AppRoutes.otpVerify);
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// VERIFY OTP
  Future<void> verifyOtp(String otp) async {
    try {
      isLoading.value = true;

      uid = await _api.verifyOtp(phone.value, otp);

      final doc = await _firestore.getUser(uid!);

      if (!doc.exists) {
        /// NEW USER
        if (selectedRole.value == "customer") {
          await _createCustomer();
          Get.offAllNamed(AppRoutes.locationAccess);
        } else {
          Get.toNamed(AppRoutes.vendorRegistration);
        }
      } else {
        /// EXISTING USER
        final role = doc['role'];

        if (role != selectedRole.value) {
          throw Exception("Wrong role selected");
        }

        Get.offAllNamed(AppRoutes.locationAccess);
      }
    } catch (e) {
      Get.snackbar("Auth Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// CREATE CUSTOMER
  Future<void> _createCustomer() async {
    await _firestore.createUser(uid!, {
      "phone": phone.value,
      "role": "customer",
      "createdAt": DateTime.now(),
    });

    await _firestore.createWallet(uid!);
  }

  /// CREATE VENDOR
  Future<void> createVendor({
    required String name,
    required String email,
    required String businessName,
    required String address,
  }) async {
    await _firestore.createUser(uid!, {
      "phone": phone.value,
      "role": "vendor",
      "createdAt": DateTime.now(),
    });

    await _firestore.createVendor(uid!, {
      "userId": uid,
      "name": name,
      "email": email,
      "businessName": businessName,
      "address": address,
    });

    Get.offAllNamed(AppRoutes.locationAccess);
  }
}
