import 'package:get/get.dart';
import 'package:savarii/core/services/location_service.dart';
import 'package:savarii/routes/app_routes.dart';

class LocationAccessController extends GetxController {
  final LocationService _locationService = Get.find<LocationService>();

  Future<void> requestLocationAccess() async {
    final position = await _locationService.checkAndRequestPermissions();

    if (position != null) {
      // Permission granted and location fetched.
      print("Location fetched: ${position.latitude}, ${position.longitude}");
      // Proceed to the main layout for Customer
      Get.offAllNamed(AppRoutes.customerMainLayout);
    }
  }

  void skipForNow() {
    print("Skipping location for now...");
    Get.offAllNamed(AppRoutes.customerMainLayout);
  }
}
