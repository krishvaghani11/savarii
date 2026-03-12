import 'package:get/get.dart';
import '../controllers/vendor_registration_controller.dart';

class VendorRegistrationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VendorRegistrationController>(
      () => VendorRegistrationController(),
    );
  }
}
