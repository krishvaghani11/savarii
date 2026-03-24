import 'package:get/get.dart';
import '../controllers/add_bus_controller.dart';

class AddBusBinding extends Bindings {
  @override
  void dependencies() {
    // AuthApiService, FirestoreService, and AuthController are permanent
    // singletons registered in main.dart — always available via Get.find().
    Get.lazyPut<AddBusController>(() => AddBusController());
  }
}