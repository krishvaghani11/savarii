import 'package:get/get.dart';
import '../controllers/vendor_registration_controller.dart';

class VendorRegistrationBinding extends Bindings {
  @override
  void dependencies() {
    // AuthApiService, FirestoreService, and AuthController are permanent
    // singletons registered in main.dart — always available via Get.find().
    Get.lazyPut<VendorRegistrationController>(
      () => VendorRegistrationController(),
    );
  }
}
