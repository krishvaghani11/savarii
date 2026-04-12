import 'dart:async';
import 'package:get/get.dart';
import 'package:savarii/core/services/auth_services.dart';
import 'package:savarii/core/services/firestore_service.dart';
import 'package:savarii/features/auth/controllers/auth_controller.dart';
import 'package:savarii/features/customer/home/controller/main_layout_controller.dart';

class ProfileController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final FirestoreService _firestoreService = Get.find<FirestoreService>();

  // Global user data
  final RxString userName = 'Savarii User'.obs;
  final RxString phoneNumber = ''.obs;
  final RxString profileImageUrl = ''.obs;

  StreamSubscription? _profileSubscription;

  @override
  void onInit() {
    super.onInit();
    final uid = _authService.currentUser?.uid;
    if (uid != null) {
      _profileSubscription = _firestoreService.getCustomerProfileStream(uid).listen((data) {
        if (data != null) {
          userName.value = data['name'] ?? 'Savarii User';
          phoneNumber.value = data['phone'] ?? '';
          profileImageUrl.value = data['profileImageUrl'] ?? '';
        }
      });
    }
  }

  @override
  void onClose() {
    _profileSubscription?.cancel();
    super.onClose();
  }

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
