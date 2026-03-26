import 'package:get/get.dart';
import 'package:savarii/routes/app_routes.dart';
import 'package:savarii/features/auth/controllers/auth_controller.dart';

class SplashController extends GetxController {
  final progress = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    _simulateLoadingAndNavigate();
  }

  void _simulateLoadingAndNavigate() async {
    // Smoothly fill the progress bar over 2.5 seconds
    for (int i = 0; i <= 100; i++) {
      await Future.delayed(const Duration(milliseconds: 25));
      progress.value = i / 100;
    }

    // Always start from Role Selection — if not already logged in
    await Future.delayed(const Duration(milliseconds: 200));
    
    // Check if AuthController is already handling a logged-in session
    // If true, AuthController will automatically route them to the correct dashboard.
    // If false, send them to Role Selection.
    if (!Get.isRegistered<AuthController>()) return;
    final authController = Get.find<AuthController>();
    
    if (!authController.isLoggedIn.value) {
      Get.offNamed(AppRoutes.roleSelection);
    }
  }
}
