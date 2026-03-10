import 'package:get/get.dart';
import 'package:savarii/routes/app_routes.dart';

class LocationAccessController extends GetxController {
  void requestLocationAccess() {
    // TODO: Add geolocator/permission logic later
    print("Requesting location permissions...");

    // For now, simulate success and navigate to the Customer Home Screen
    // Get.offAllNamed(AppRoutes.customerHome);
  }

  void skipForNow() {
    print("Skipping location for now...");
    Get.offAllNamed(AppRoutes.customerMainLayout);
  }
}
