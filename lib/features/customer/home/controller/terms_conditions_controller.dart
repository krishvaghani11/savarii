import 'package:get/get.dart';

class TermsConditionsController extends GetxController {
  void contactSupport() {
    print("Navigating to Support...");
    Get.toNamed('/help-support'); // Routes to your Help Center
  }
}
