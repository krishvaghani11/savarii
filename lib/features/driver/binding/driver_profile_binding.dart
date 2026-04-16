import 'package:get/get.dart';
import 'package:savarii/features/driver/controller/driver_profile_controller.dart';


class DriverProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DriverProfileController>(() => DriverProfileController());
  }
}