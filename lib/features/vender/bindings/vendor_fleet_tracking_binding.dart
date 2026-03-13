import 'package:get/get.dart';
import '../controllers/vendor_fleet_tracking_controller.dart';

class VendorFleetTrackingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VendorFleetTrackingController>(
      () => VendorFleetTrackingController(),
    );
  }
}
