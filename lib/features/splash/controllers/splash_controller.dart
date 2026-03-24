import 'package:get/get.dart';
import 'package:savarii/routes/app_routes.dart';

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

    // Always start from Role Selection — user must choose Customer or Vendor
    await Future.delayed(const Duration(milliseconds: 200));
    Get.offNamed(AppRoutes.roleSelection);
  }
}
