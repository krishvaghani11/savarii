import 'package:get/get.dart';
import '../controllers/add_bus_controller.dart';

class AddBusBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddBusController>(() => AddBusController());
  }
}