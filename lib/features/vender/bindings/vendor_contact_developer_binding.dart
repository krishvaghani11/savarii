import 'package:get/get.dart';
import '../controllers/vendor_contact_developer_controller.dart';

class VendorContactDeveloperBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VendorContactDeveloperController>(
      () => VendorContactDeveloperController(),
    );
  }
}
