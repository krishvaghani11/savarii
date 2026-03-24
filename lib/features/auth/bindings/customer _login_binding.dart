import 'package:get/get.dart';
import 'package:savarii/features/auth/controllers/customer%20_login_controller.dart';

class CustomerLoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CustomerLoginController>(() => CustomerLoginController());
  }
}