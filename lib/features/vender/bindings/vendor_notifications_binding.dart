import 'package:get/get.dart';
import 'package:savarii/features/vender/controllers/vendor_notifications_controller.dart';

class VendorNotificationsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VendorNotificationsController>(() => VendorNotificationsController());
  }
}
