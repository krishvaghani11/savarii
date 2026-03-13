import 'package:get/get.dart';
import 'package:savarii/features/vender/controllers/vendor_home_controller.dart';
import 'package:savarii/features/vender/controllers/vendor_profile_controller.dart';
import '../controllers/vendor_main_controller.dart';

class VendorMainBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VendorMainController>(() => VendorMainController());
    // Also inject the home controller so it's ready when the first tab loads
    Get.lazyPut<VendorHomeController>(() => VendorHomeController());
    Get.lazyPut<VendorProfileController>(() => VendorProfileController());
  }
}
