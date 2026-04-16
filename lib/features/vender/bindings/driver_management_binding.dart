import 'package:get/get.dart';
import '../controllers/driver_management_controller.dart';

class DriverManagementBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DriverManagementController>(() => DriverManagementController());
  }
}