import 'package:get/get.dart';
import 'package:savarii/core/services/location_service.dart';
import 'package:savarii/routes/app_routes.dart';

class DriverLocationAccessController extends GetxController {
  final LocationService _locationService = Get.find<LocationService>();
  
  Future<void> allowLocationAccess() async {
    final position = await _locationService.checkAndRequestPermissions();
    
    if (position != null) {
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
    Get.offAllNamed(AppRoutes.driverMain);
  }
}