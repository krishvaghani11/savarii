import 'package:get/get.dart';
import '../controllers/vendor_login_controller.dart';

class VendorLoginBinding extends Bindings {
  @override
  void dependencies() {
    // AuthApiService, FirestoreService, and AuthController are permanent
    // singletons registered in main.dart — always available via Get.find().
    Get.lazyPut<VendorLoginController>(() => VendorLoginController());
  }
}
