import 'package:get/get.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../routes/app_routes.dart';

class RoleSelectionController extends GetxController {
  final AuthController _authController = Get.find();

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

    // 2. Store role in AuthController so the OTP flow knows the selected role
    _authController.selectedRole.value = selectedRole.value;

    // 3. Route based on selection
    if (selectedRole.value == 'customer') {
      // Customer → Phone login (OTP flow)
      Get.toNamed(AppRoutes.customerLogin);
    } else if (selectedRole.value == 'vendor') {
      // Vendor → Vendor login (OTP + registration flow)
      Get.toNamed(AppRoutes.vendorLogin);
    }
  }
}
