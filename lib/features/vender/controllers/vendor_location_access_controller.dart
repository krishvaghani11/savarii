import 'package:get/get.dart';

class VendorLocationAccessController extends GetxController {
  void enableLocationServices() {
    print("Requesting location permissions...");
    // TODO: Implement actual geolocator/permission_handler logic here

    // After permission is handled (granted or denied), go to the dashboard
    Get.offAllNamed('/vendor-main');
  }

  void skipForNow() {
    print("Skipping location access...");
    Get.offAllNamed('/vendor-main');
  }
}
