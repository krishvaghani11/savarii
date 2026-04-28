import 'package:get/get.dart';
import 'package:savarii/core/services/location_service.dart';
import 'package:savarii/routes/app_routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationAccessController extends GetxController {
  final LocationService _locationService = Get.find<LocationService>();

  Future<void> requestLocationAccess() async {
    final position = await _locationService.checkAndRequestPermissions();

    if (position != null) {
      // Permission granted — record it so we never show this screen again.
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('loc_granted_customer', true);

      print("Location fetched: ${position.latitude}, ${position.longitude}");
      // Proceed to the main layout for Customer
      Get.offAllNamed(AppRoutes.customerMainLayout);
    }
  }

  void skipForNow() {
    print("Skipping location for now...");
    // Do NOT save the granted flag — next login will show the screen again
    // so the user gets another chance to allow it.
    Get.offAllNamed(AppRoutes.customerMainLayout);
  }
}

