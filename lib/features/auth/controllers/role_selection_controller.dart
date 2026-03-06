import 'package:get/get.dart';

class RoleSelectionController extends GetxController {
  // Reactive variable to hold the selected role ('customer' or 'vendor')
  // Defaulting to 'customer' as shown in your design
  final RxString selectedRole = 'customer'.obs;

  void selectRole(String role) {
    selectedRole.value = role;
  }

  void continueToNextScreen() {
    // We will navigate to the Phone Login screen later, passing the selected role
    // Get.toNamed(AppRoutes.phoneLogin, arguments: {'role': selectedRole.value});
    print("User is continuing as: ${selectedRole.value}");
    Get.toNamed('/phone-login', arguments: {'role': selectedRole.value});
  }
}
