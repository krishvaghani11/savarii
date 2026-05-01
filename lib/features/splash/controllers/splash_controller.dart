import 'package:flutter/foundation.dart';
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
    // 0. Logo appears statically for 5 seconds
    await Future.delayed(const Duration(milliseconds: 5000));

    // 1. Smoothly fill the progress bar over 1 second (Quickly)
    for (int i = 0; i <= 100; i++) {
      await Future.delayed(const Duration(milliseconds: 25));
      progress.value = i / 100;
    }

    // 2. Extra buffer for final check (0.5 sec)
    await Future.delayed(const Duration(milliseconds: 200));

    if (!Get.isRegistered<AuthController>()) {
      Get.offAllNamed(AppRoutes.roleSelection);
      return;
    }

    final auth = Get.find<AuthController>();

    // 3. Logic-based Navigation
    // If not logged in -> Role Selection
    if (!auth.isLoggedIn.value) {
      debugPrint('SplashController: Not logged in, going to Role Selection.');
      Get.offAllNamed(AppRoutes.roleSelection);
      return;
    }

    // 4. If logged in, wait until the profile is fetched (if not already)
    // We give it a max timeout of 5 seconds to avoid hanging forever.
    int timeoutCount = 0;
    while (auth.currentUserProfile.value == null && timeoutCount < 10) {
      debugPrint('SplashController: Waiting for user profile to load...');
      await Future.delayed(const Duration(milliseconds: 500));
      timeoutCount++;
    }

    if (auth.currentUserProfile.value != null) {
      final role = auth.currentUserProfile.value!.role;
      debugPrint(
        'SplashController: Profile loaded ($role). Checking permissions...',
      );

      // Navigate based on role (mirrors AuthController logic but executed here)
      if (role == 'customer') {
        Get.offAllNamed(AppRoutes.customerMainLayout);
      } else if (role == 'vendor') {
        Get.offAllNamed(AppRoutes.vendorMain);
      } else if (role == 'driver') {
        Get.offAllNamed(AppRoutes.driverMain);
      } else {
        Get.offAllNamed(AppRoutes.roleSelection);
      }
    } else {
      debugPrint(
        'SplashController: Timeout fetching profile, falling back to Role Selection.',
      );
      Get.offAllNamed(AppRoutes.roleSelection);
    }
  }
}
