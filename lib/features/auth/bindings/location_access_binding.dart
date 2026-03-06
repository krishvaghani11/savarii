import 'package:get/get.dart';
import '../controllers/location_access_controller.dart';

class LocationAccessBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LocationAccessController>(() => LocationAccessController());
  }
}
