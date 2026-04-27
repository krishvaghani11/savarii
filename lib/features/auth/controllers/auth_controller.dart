import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/services/auth_services.dart';
import '../../../core/services/firestore_service.dart';
import '../../../models/user_model.dart';
import '../../../routes/app_routes.dart';

class AuthController extends GetxController {
  final AuthService _authService = Get.put(AuthService(), permanent: true);
  final FirestoreService _firestoreService = Get.put(FirestoreService(), permanent: true);

  var selectedRole = ''.obs;
  var phone = ''.obs;
  var isLoading = false.obs;
  var isLoggedIn = false.obs;

  String? uid;
  final Rx<User?> firebaseUser = Rx<User?>(null);
  final Rx<UserModel?> currentUserProfile = Rx<UserModel?>(null);

  @override
  void onInit() {
    super.onInit();
    firebaseUser.bindStream(_authService.authStateChanges);
    ever(firebaseUser, _handleAuthChanged);
  }

  Future<void> _handleAuthChanged(User? user) async {
    if (user == null) {
      uid = null;
      isLoggedIn.value = false;
      currentUserProfile.value = null;
      // Navigate to role selection if they are on a protected route
      final route = Get.currentRoute;
      if (route != AppRoutes.splash && 
          route != AppRoutes.roleSelection && 
          !route.contains('login') && 
          !route.contains('registration') &&
          !route.contains('register')) {
        Get.offAllNamed(AppRoutes.roleSelection);
      }
    } else {
      uid = user.uid;
      isLoggedIn.value = true;
      await _fetchRoleAndNavigate(user.uid);
    }
  }

  Future<void> _fetchRoleAndNavigate(String userId) async {
    try {
      final userModel = await _firestoreService.getUserProfile(userId);
      if (userModel != null) {
        currentUserProfile.value = userModel;
        selectedRole.value = userModel.role;
        
        // Route dynamically based on user role
        final currentRoute = Get.currentRoute;
        
        // 1. If coming from login or registration, show the Location Access onboarding screen
        if (currentRoute.contains('login') || currentRoute.contains('registration')) {
          if (userModel.role == 'customer') {
             Get.offAllNamed(AppRoutes.locationAccess); 
          } else if (userModel.role == 'vendor') {
             Get.offAllNamed(AppRoutes.vendorLocationAccess); 
          } else if (userModel.role == 'driver') {
             Get.offAllNamed(AppRoutes.driverLocationAccess);
          }
        } 
        // 2. If app is starting up (cold start from Splash or Role Selection), go directly to the Main Dashboard
        else if (currentRoute == AppRoutes.splash || currentRoute == '' || currentRoute == AppRoutes.roleSelection) {
          if (userModel.role == 'customer') {
             Get.offAllNamed(AppRoutes.customerMainLayout); 
          } else if (userModel.role == 'vendor') {
             Get.offAllNamed(AppRoutes.vendorMain); 
          } else if (userModel.role == 'driver') {
             Get.offAllNamed(AppRoutes.driverMain);
          }
        }
      } else {
        // User is authenticated in Firebase but missing Firestore profile
        debugPrint('Error: User document does not exist in Firestore for uid: $userId');
        Get.snackbar(
          'Profile Not Found',
          'Your account data is missing. Please register again or contact support.',
          snackPosition: SnackPosition.TOP,
        );
        await logout(); // Sign out to prevent getting stuck
      }
    } catch (e) {
      debugPrint('Error fetching role: $e');
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
    uid = null;
    isLoggedIn.value = false;
    Get.offAllNamed(AppRoutes.roleSelection);
  }

  // legacy methods kept for compatibility with UI that hasn't been migrated yet
  Future<void> saveVendorSession({required String vendorUid, required String vendorPhone}) async {
    uid = vendorUid;
    phone.value = vendorPhone;
    selectedRole.value = 'vendor';
    isLoggedIn.value = true;
  }
}


