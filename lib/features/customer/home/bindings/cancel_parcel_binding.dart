import 'package:get/get.dart';
import '../controller/cancel_parcel_controller.dart';

class CancelParcelBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CancelParcelController>(() => CancelParcelController());
  }
}
