import 'package:get/get.dart';
import '../controllers/vendor_language_controller.dart';

class VendorLanguageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VendorLanguageController>(() => VendorLanguageController());
  }
}
