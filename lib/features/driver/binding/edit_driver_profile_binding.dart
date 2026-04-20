import 'package:get/get.dart';
import 'package:savarii/features/driver/controller/edit_driver_profile_controller.dart';


class EditDriverProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EditDriverProfileController>(
      () => EditDriverProfileController(),
    );
  }
}