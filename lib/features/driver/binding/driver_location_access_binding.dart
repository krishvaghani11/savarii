import 'package:get/get.dart';
import 'package:savarii/features/driver/controller/driver_location_access_controller.dart';

class DriverLocationAccessBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DriverLocationAccessController>(() => DriverLocationAccessController());
  }
}