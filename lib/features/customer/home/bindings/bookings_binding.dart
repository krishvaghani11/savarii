import 'package:get/get.dart';
import 'package:savarii/features/customer/home/controller/bookings_controller.dart';

class BookingsBinding extends Bindings {
  @override
  void dependencies() {
    // Injects the BookingsController into memory when the Bookings route is called directly
    Get.lazyPut<BookingsController>(() => BookingsController());
  }
}