import 'package:get/get.dart';
import 'package:savarii/features/customer/home/controller/payment_details_controller.dart';

class PaymentDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PaymentDetailsController>(() => PaymentDetailsController());
  }
}
