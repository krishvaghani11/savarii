import 'package:get/get.dart';
import 'package:savarii/features/customer/home/controller/customer_notifications_controller.dart';

class CustomerNotificationsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CustomerNotificationsController>(() => CustomerNotificationsController());
  }
}
