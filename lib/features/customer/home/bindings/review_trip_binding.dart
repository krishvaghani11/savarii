import 'package:get/get.dart';
import 'package:savarii/features/customer/home/controller/review_trip_controller.dart';

class ReviewTripBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReviewTripController>(() => ReviewTripController());
  }
}
