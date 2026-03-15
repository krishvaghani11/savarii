import 'package:get/get.dart';
import '../controllers/vendor_terms_controller.dart';

class VendorTermsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VendorTermsController>(() => VendorTermsController());
  }
}
