import 'package:get/get.dart';
import '../../../core/services/auth_api_service.dart';
import '../../../core/services/firestore_service.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/vendor_login_controller.dart';

class VendorLoginBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AuthApiService>()) {
      Get.lazyPut<AuthApiService>(() => AuthApiService());
    }
    if (!Get.isRegistered<FirestoreService>()) {
      Get.lazyPut<FirestoreService>(() => FirestoreService());
    }
    if (!Get.isRegistered<AuthController>()) {
      Get.lazyPut<AuthController>(() => AuthController());
    }

    Get.lazyPut<VendorLoginController>(() => VendorLoginController());
  }
}
