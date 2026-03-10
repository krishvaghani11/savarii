import 'package:get/get.dart';
import 'package:savarii/features/customer/home/controller/security_settings_controller.dart';

class SecuritySettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SecuritySettingsController>(() => SecuritySettingsController());
  }
}
