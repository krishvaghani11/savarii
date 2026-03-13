import 'package:get/get.dart';
import '../controllers/vendor_edit_profile_controller.dart';

class VendorEditProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VendorEditProfileController>(
      () => VendorEditProfileController(),
    );
  }
}
