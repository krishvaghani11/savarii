import 'package:get/get.dart';
import 'package:savarii/features/auth/controllers/auth_controller.dart';
import 'package:savarii/features/customer/home/controller/main_layout_controller.dart';

class ProfileController extends GetxController {
  // Dummy user data
  final RxString userName = 'John Doe'.obs;
  final RxString phoneNumber = '+1(555) 012-3456'.obs;

  void editProfilePicture() {
    print("Opening image picker for profile picture...");
  }

  void goToEditProfile() {
    print("Navigating to Edit Profile...");
    Get.toNamed('/edit-profile');
  }

  void goToTicketHistory() {
    print("Navigating to Ticket History...");
    if (Get.isRegistered<MainLayoutController>()) {
      Get.find<MainLayoutController>().changeTab(1);
    } else {
      Get.toNamed('/bookings');
    }
  }

  void goToSavedRoutes() {
    print("Navigating to Saved Routes...");
    // Get.toNamed('/saved-routes');
  }

  void goToMyRewards() {
    print("Navigating to My Rewards...");
    // Get.toNamed('/my-rewards');
  }

  void goToSettings() {
    print("Navigating to Settings...");
    Get.toNamed('/settings');
  }

  void logOut() {
    print("Logging out...");
    if (Get.isRegistered<AuthController>()) {
      Get.find<AuthController>().logout();
    } else {
      Get.offAllNamed('/role-selection');
    }
  }
}
