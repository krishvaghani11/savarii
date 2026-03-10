import 'package:get/get.dart';
import 'package:savarii/features/customer/home/controller/notification_settings_controller.dart';

class NotificationSettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NotificationSettingsController>(
      () => NotificationSettingsController(),
    );
  }
}
