import 'package:get/get.dart';
import 'package:savarii/features/customer/home/controller/parcel_confirmation_controller.dart';

class ParcelConfirmationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ParcelConfirmationController>(
      () => ParcelConfirmationController(),
    );
  }
}
