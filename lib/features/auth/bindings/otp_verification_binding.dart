import 'package:get/get.dart';
import '../../../core/services/auth_api_service.dart';
import '../../../core/services/firestore_service.dart';
import '../controllers/auth_controller.dart';
import '../controllers/otp_verification_controller.dart';

class OTPVerificationBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure services and dependencies are available
    if (!Get.isRegistered<AuthApiService>()) {
      Get.lazyPut<AuthApiService>(() => AuthApiService());
    }
    if (!Get.isRegistered<FirestoreService>()) {
      Get.lazyPut<FirestoreService>(() => FirestoreService());
    }
    if (!Get.isRegistered<AuthController>()) {
      Get.lazyPut<AuthController>(() => AuthController());
    }

    Get.lazyPut<OTPVerificationController>(() => OTPVerificationController());
  }
}
