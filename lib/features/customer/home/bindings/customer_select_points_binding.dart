import 'package:get/get.dart';
import 'package:savarii/features/customer/home/controller/customer_select_points_controller.dart';


class CustomerSelectPointsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CustomerSelectPointsController>(() => CustomerSelectPointsController());
  }
}