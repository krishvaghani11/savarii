import 'package:get/get.dart';
import 'package:savarii/features/customer/home/controller/parcel_payment_controller.dart';

class ParcelPaymentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ParcelPaymentController>(() => ParcelPaymentController());
  }
}