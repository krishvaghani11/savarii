import 'package:get/get.dart';
import 'package:savarii/features/customer/home/controller/terms_conditions_controller.dart';

class TermsConditionsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TermsConditionsController>(() => TermsConditionsController());
  }
}
