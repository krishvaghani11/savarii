import 'package:get/get.dart';
import 'package:savarii/features/driver/controller/driver_login_controller.dart';

class DriverLoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DriverLoginController>(() => DriverLoginController());
  }
}