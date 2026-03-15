import 'package:get/get.dart';
import '../controllers/vendor_privacy_policy_controller.dart';

class VendorPrivacyPolicyBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VendorPrivacyPolicyController>(
      () => VendorPrivacyPolicyController(),
    );
  }
}
