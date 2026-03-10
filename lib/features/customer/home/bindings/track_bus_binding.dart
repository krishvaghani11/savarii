import 'package:get/get.dart';
import 'package:savarii/features/customer/home/controller/track_bus_controller.dart';

class TrackBusBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TrackBusController>(() => TrackBusController());
  }
}
