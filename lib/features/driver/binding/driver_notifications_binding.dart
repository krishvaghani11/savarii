import 'package:get/get.dart';
import 'package:savarii/features/driver/controller/driver_notifications_controller.dart';

class DriverNotificationsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DriverNotificationsController>(() => DriverNotificationsController());
  }
}
