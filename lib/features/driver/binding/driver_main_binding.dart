import 'package:get/get.dart';
import 'package:savarii/features/driver/controller/driver_main_controller.dart';
import 'package:savarii/features/driver/controller/driver_home_controller.dart';
import 'package:savarii/features/driver/controller/driver_profile_controller.dart';
import 'package:savarii/features/driver/controller/driver_settings_controller.dart';

class DriverMainBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DriverMainController>(() => DriverMainController());
    Get.lazyPut<DriverHomeController>(() => DriverHomeController());
    Get.lazyPut<DriverProfileController>(() => DriverProfileController());
    Get.lazyPut<DriverSettingsController>(() => DriverSettingsController());
  }
}
