import 'package:get/get.dart';

class PrivacyPolicyController extends GetxController {
  void emailSupport() {
    print("Opening email client for privacy support...");
    Get.snackbar(
      'Email Support',
      'Redirecting to your email client...',
      snackPosition: SnackPosition.BOTTOM,
    );
    // TODO: Implement url_launcher to open mailto:privacy@savarii.com
  }
}
