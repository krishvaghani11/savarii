import 'package:get/get.dart';
import 'package:savarii/features/customer/home/controller/customer_home_controller.dart';

class CustomerHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CustomerHomeController>(() => CustomerHomeController());
  }
}
