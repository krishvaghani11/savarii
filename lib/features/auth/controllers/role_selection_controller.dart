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

    // 2. Route based on the selection (Temporary change as requested)
    if (selectedRole.value == 'customer') {
      print("Temporary Navigation: Customer -> Location Access");
      Get.toNamed('/location-access'); // Direct to customer location access
    } else if (selectedRole.value == 'vendor') {
      print("Temporary Navigation: Vendor -> Vendor Location Access");
      Get.toNamed('/vendor-location-access'); // Direct to vendor location access
    }
  }
}
