import 'package:get/get.dart';
import '../controllers/vendor_add_travels_controller.dart';

class VendorAddTravelsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VendorAddTravelsController>(() => VendorAddTravelsController());
  }
}
