import 'package:get/get.dart';
import 'package:savarii/features/driver/controller/driver_home_controller.dart';
import 'package:savarii/core/services/realtime_db_service.dart';
import 'package:savarii/core/services/driver_tracking_service.dart';


class DriverHomeBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<RealtimeDbService>()) {
      Get.put<RealtimeDbService>(RealtimeDbService(), permanent: true);
    }
    if (!Get.isRegistered<DriverTrackingService>()) {
      Get.put<DriverTrackingService>(DriverTrackingService(), permanent: true);
    }
    Get.lazyPut<DriverHomeController>(() => DriverHomeController());
  }
}