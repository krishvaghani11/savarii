import 'package:get/get.dart';
import '../controllers/edit_driver_controller.dart';

class EditDriverBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EditDriverController>(() => EditDriverController());
  }
}
