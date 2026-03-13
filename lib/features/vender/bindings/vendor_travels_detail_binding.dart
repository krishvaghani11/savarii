import 'package:get/get.dart';
import '../controllers/vendor_travels_detail_controller.dart';

class VendorTravelsDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VendorTravelsDetailController>(
      () => VendorTravelsDetailController(),
    );
  }
}
