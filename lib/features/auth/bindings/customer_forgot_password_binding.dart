import 'package:get/get.dart';
import '../controllers/customer_forgot_password_controller.dart';

class CustomerForgotPasswordBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CustomerForgotPasswordController>(() => CustomerForgotPasswordController());
  }
}