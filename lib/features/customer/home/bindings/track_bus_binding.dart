import 'package:get/get.dart';
import 'package:savarii/core/services/realtime_db_service.dart';
import 'package:savarii/features/customer/home/controller/track_bus_controller.dart';

class TrackBusBinding extends Bindings {
  @override
  void dependencies() {
    // Register RTDB service if not already registered
    if (!Get.isRegistered<RealtimeDbService>()) {
      Get.put<RealtimeDbService>(RealtimeDbService(), permanent: true);
    }
    Get.lazyPut<TrackBusController>(() => TrackBusController());
  }
}
