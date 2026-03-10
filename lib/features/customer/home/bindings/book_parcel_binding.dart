import 'package:get/get.dart';
import 'package:savarii/features/customer/home/controller/book_parcel_controller.dart';

class BookParcelBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BookParcelController>(() => BookParcelController());
  }
}
