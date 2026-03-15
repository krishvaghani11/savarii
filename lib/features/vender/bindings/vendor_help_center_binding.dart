import 'package:get/get.dart';
import '../controllers/vendor_help_center_controller.dart';

class VendorHelpCenterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VendorHelpCenterController>(() => VendorHelpCenterController());
  }
}
