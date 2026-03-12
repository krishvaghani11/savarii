import 'package:get/get.dart';

class RoleSelectionController extends GetxController {
  // Reactive variable to keep track of what the user tapped
  final RxString selectedRole = ''.obs;

  void selectRole(String role) {
    selectedRole.value = role;
  }

  void continueToNextScreen() {
    // 1. Check if they actually selected something
    if (selectedRole.value.isEmpty) {
      Get.snackbar(
        'Select a Role',
        'Please select whether you are a Customer or a Vendor to continue.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // 2. Route based on the selection
    if (selectedRole.value == 'customer') {
      print("Navigating to Customer Login...");
      Get.toNamed('/phone-login'); // Navigates to your phone_login_view.dart
    } else if (selectedRole.value == 'vendor') {
      print("Navigating to Vendor Registration...");
      Get.toNamed('/vendor-login'); // Navigates to the vendor flow
    }
  }
}
