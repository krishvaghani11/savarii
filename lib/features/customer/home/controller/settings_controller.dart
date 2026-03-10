import 'package:get/get.dart';

class SettingsController extends GetxController {
  // Reactive state for Dark Mode switch
  final RxBool isDarkMode = false.obs;

  void toggleDarkMode(bool value) {
    isDarkMode.value = value;
    print("Dark Mode toggled: $value");
    // TODO: Implement actual theme switching using Get.changeThemeMode()
  }

  // --- Account Settings Actions ---
  void goToNotifications() {
    print("Navigating to Notification Preferences...");
    Get.toNamed('/notification-settings');
  }

  void goToPrivacy() {
    print("Navigating to Privacy Settings...");
    Get.toNamed('/privacy-settings');
  }

  void goToSecurity() {
    print("Navigating to Security Settings...");
    Get.toNamed('/security-settings');
  }

  // --- App Preferences Actions ---
  void goToLanguage() {
    print("Navigating to Language Selection...");
    Get.toNamed('/language'); // Reusing the language screen we built earlier!
  }

  void clearCache() {
    print("Clearing App Cache...");
    Get.snackbar(
      'Cache Cleared',
      'App cache has been successfully freed up.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // --- Support Actions ---
  void goToHelpCenter() {
    print("Opening Help Center...");
    Get.toNamed('/help-support'); // Reusing the help screen we built earlier!
  }

  void goToTerms() {
    print("Opening Terms & Conditions...");
    Get.toNamed('/terms-conditions');
  }

  void goToPrivacyPolicy() {
    print("Opening Privacy Policy...");
    Get.toNamed('/privacy-policy');
  }

  void logout() {
    print("Initiating Logout...");

    // TODO: Add logout confirmation dialog and clear auth tokens
  }
}
