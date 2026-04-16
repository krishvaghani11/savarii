import 'package:get/get.dart';
import 'package:savarii/features/driver/controller/driver_forgot_password_controller.dart';

class DriverForgotPasswordBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DriverForgotPasswordController>(() => DriverForgotPasswordController());
  }
}