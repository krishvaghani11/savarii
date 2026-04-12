import 'package:get/get.dart';
import 'package:savarii/features/customer/home/controller/cancel_booking_controller.dart';


class CancelBookingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CancelBookingController>(() => CancelBookingController());
  }
}