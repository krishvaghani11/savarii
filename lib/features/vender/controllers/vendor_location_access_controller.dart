import 'package:get/get.dart';
import 'package:savarii/core/services/location_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VendorLocationAccessController extends GetxController {
  final LocationService _locationService = Get.find<LocationService>();

  Future<void> enableLocationServices() async {
    final position = await _locationService.checkAndRequestPermissions();

    if (position != null) {
      // Permission granted — record it so we never show this screen again.
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('loc_granted_vendor', true);

      // After permission is handled (granted), go to the dashboard
      Get.offAllNamed('/vendor-main');
    }
  }

  void skipForNow() {
    print("Skipping location access...");
    // Do NOT save the granted flag — next login will show the screen again.
    Get.offAllNamed('/vendor-main');
  }
}

