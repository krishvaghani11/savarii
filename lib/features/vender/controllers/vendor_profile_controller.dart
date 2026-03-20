import 'package:get/get.dart';
import 'package:savarii/routes/app_routes.dart';

class VendorProfileController extends GetxController {
  // Vendor Dummy Data
  final String vendorName = "Vikram Malhotra";
  final String phone = "+91 98765 43210";
  final String trips = "1,248";
  final String rating = "4.8";
  final String vehicles = "12";

  final String email = "v.malhotra@savarii.com";
  final String travelsName = "Malhotra Express Travels";

  // Actions
  void editProfileImage() {}

  void openMenu() => print("Opening top right menu...");

  void editProfileInfo() {
    print("Navigating to Edit Profile...");
    Get.toNamed(AppRoutes.vendorEditProfile);
  }

  void addTravels() {
    print("Navigating to Add Travels...");
    Get.toNamed('/vendor-add-travels');
  }

  void goToTravelsDetail() {
    print("Navigating to Travels Detail...");
    Get.toNamed('/vendor-travels-detail');
  }

  void goToSettings() {
    print("Navigating to Settings...");
    // Assuming you have a settings route you want to reuse or build later
    Get.toNamed('/vendor-settings');
  }

  void logout() {
    print("Logging out...");
    Get.snackbar(
      'Logged Out',
      'You have been successfully logged out.',
      snackPosition: SnackPosition.BOTTOM,
    );
    Get.offAllNamed(
      AppRoutes.roleSelection,
    ); // Route back to the very beginning
  }
}
