import 'package:get/get.dart';
import 'package:savarii/features/driver/controller/driver_documents_controller.dart';

class DriverDocumentsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DriverDocumentsController>(() => DriverDocumentsController());
  }
}