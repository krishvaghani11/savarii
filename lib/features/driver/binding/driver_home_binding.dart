import 'package:get/get.dart';
import 'package:savarii/features/driver/controller/driver_home_controller.dart';


class DriverHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DriverHomeController>(() => DriverHomeController());
  }
}