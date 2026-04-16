import 'package:get/get.dart';
import 'package:savarii/features/driver/controller/driver_signup_controller.dart';


class DriverSignupBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DriverSignupController>(() => DriverSignupController());
  }
}