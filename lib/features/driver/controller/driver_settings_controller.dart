import 'package:get/get.dart';

class DriverSettingsController extends GetxController {
  var isNotificationsEnabled = true.obs;
  var isDarkThemeEnabled = false.obs;

  void toggleNotifications(bool value) {
    isNotificationsEnabled.value = value;
  }

  void toggleDarkTheme(bool value) {
    isDarkThemeEnabled.value = value;
  }

  void openPrivacyPolicy() {
    print("Opening Privacy Policy...");
  }

  void openTermsAndConditions() {
    print("Opening Terms and Conditions...");
  }
}
