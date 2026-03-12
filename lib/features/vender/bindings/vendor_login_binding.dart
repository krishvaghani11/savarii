import 'package:get/get.dart';
import '../controllers/vendor_login_controller.dart';

class VendorLoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VendorLoginController>(() => VendorLoginController());
  }
}
