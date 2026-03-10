import 'package:get/get.dart';
import 'package:savarii/features/customer/home/controller/seat_selection_controller.dart';

class SeatSelectionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SeatSelectionController>(() => SeatSelectionController());
  }
}
