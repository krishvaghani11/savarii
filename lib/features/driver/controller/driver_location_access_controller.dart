import 'package:get/get.dart';
import 'package:savarii/core/services/location_service.dart';
import 'package:savarii/routes/app_routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DriverLocationAccessController extends GetxController {
  final LocationService _locationService = Get.find<LocationService>();
  
  Future<void> allowLocationAccess() async {
    final position = await _locationService.checkAndRequestPermissions();
    
    if (position != null) {
      // Permission granted — record it so we never show this screen again.
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('loc_granted_driver', true);

      Get.snackbar(
        'Permission Granted',
        'Location tracking is now enabled.',
        snackPosition: SnackPosition.TOP,
      );

      // Route to the Driver Dashboard/Home
      Get.offAllNamed(AppRoutes.driverMain);
    }
  }

  void skipForNow() {
    print("Skipping Location Access...");
    // Do NOT save the granted flag — next login will show the screen again.
    Get.offAllNamed(AppRoutes.driverMain);
  }
}