import 'package:get/get.dart';
import '../controllers/customer_registration_controller.dart';

class CustomerRegistrationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CustomerRegistrationController>(() => CustomerRegistrationController());
  }
}