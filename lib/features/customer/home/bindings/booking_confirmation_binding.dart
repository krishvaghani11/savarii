import 'package:get/get.dart';
import 'package:savarii/features/customer/home/controller/booking_confirmation_controller.dart';

class BookingConfirmationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BookingConfirmationController>(
      () => BookingConfirmationController(),
    );
  }
}
