import 'package:get/get.dart';

class PrivacySettingsController extends GetxController {
  // Toggle States
  final RxBool profileVisibility = true.obs;
  final RxBool contactsSync = false.obs;

  void toggleProfileVisibility(bool value) {
    profileVisibility.value = value;
  }

  void toggleContactsSync(bool value) {
    contactsSync.value = value;
  }

  // Navigation Actions
  void goToRideHistory() => print("Navigating to Ride History Privacy...");

  void goToTwoStepVerification() =>
      print("Navigating to Two-Step Verification...");

  void goToBlockedUsers() => print("Navigating to Blocked Users...");

  void manageLocationAccess() {
    print("Opening Location Access settings...");
    // Typically, this might open the device's native app settings
  }

  void downloadMyData() {
    print("Requesting Data Download...");
    Get.snackbar(
      'Request Sent',
      'A copy of your data will be emailed to you shortly.',
      snackPosition: SnackPosition.TOP,
    );
  }

  void deleteAccount() {
    print("Initiating Account Deletion...");
    // TODO: Show a serious confirmation dialog here before actually deleting
  }
}
