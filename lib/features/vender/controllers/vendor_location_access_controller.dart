import 'package:get/get.dart';
import 'package:savarii/core/services/location_service.dart';

class VendorLocationAccessController extends GetxController {
  final LocationService _locationService = Get.find<LocationService>();

  Future<void> enableLocationServices() async {
    final position = await _locationService.checkAndRequestPermissions();

    if (position != null) {
      // After permission is handled (granted), go to the dashboard
      Get.offAllNamed('/vendor-main');
    }
  }

  void skipForNow() {
    print("Skipping location access...");
    Get.offAllNamed('/vendor-main');
  }
}
