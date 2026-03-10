import 'package:get/get.dart';
import 'package:savarii/features/customer/home/controller/profile_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    // Injects the ProfileController into memory when the Profile route is called
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}
