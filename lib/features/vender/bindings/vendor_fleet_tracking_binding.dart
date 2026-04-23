import 'package:get/get.dart';
import 'package:savarii/core/services/realtime_db_service.dart';
import '../controllers/vendor_fleet_tracking_controller.dart';

class VendorFleetTrackingBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<RealtimeDbService>()) {
      Get.put<RealtimeDbService>(RealtimeDbService(), permanent: true);
    }
    Get.lazyPut<VendorFleetTrackingController>(
      () => VendorFleetTrackingController(),
    );
  }
}
