import 'package:get/get.dart';

class AboutUsController extends GetxController {
  void openTermsAndConditions() {
    print("Opening Terms & Conditions...");
    // TODO: Navigate to Terms screen or open web URL
  }

  void openPrivacyPolicy() {
    print("Opening Privacy Policy...");
    // TODO: Navigate to Privacy Policy screen or open web URL
  }

  void openSocial(String platform) {
    print("Opening $platform profile...");
    // TODO: Use url_launcher to open social media links
  }
}
