import 'package:get/get.dart';
import '../controllers/vendor_my_buses_controller.dart';

class VendorMyBusesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VendorMyBusesController>(() => VendorMyBusesController());
  }
}
