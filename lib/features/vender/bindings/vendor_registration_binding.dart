import 'package:get/get.dart';
import '../../../core/services/firestore_service.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/vendor_registration_controller.dart';

class VendorRegistrationBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<FirestoreService>()) {
      Get.lazyPut<FirestoreService>(() => FirestoreService());
    }

    if (!Get.isRegistered<AuthController>()) {
      // Ensure AuthController is present
      Get.put<AuthController>(AuthController(), permanent: true);
    }

    Get.lazyPut<VendorRegistrationController>(
      () => VendorRegistrationController(),
    );
  }
}
