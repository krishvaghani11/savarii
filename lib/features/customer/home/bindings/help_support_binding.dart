import 'package:get/get.dart';
import 'package:savarii/features/customer/home/controller/help_support_controller.dart';

class HelpSupportBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HelpSupportController>(() => HelpSupportController());
  }
}
