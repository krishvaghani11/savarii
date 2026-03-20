import 'package:get/get.dart';
import '../controllers/vendor_location_access_controller.dart';

class VendorLocationAccessBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VendorLocationAccessController>(
      () => VendorLocationAccessController(),
    );
  }
}
