import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/services/auth_services.dart';
import '../../../core/services/driver_tracking_service.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/services/location_service.dart';
import '../../../models/user_model.dart';
import '../../../routes/app_routes.dart';

class AuthController extends GetxController {
  final AuthService _authService = Get.put(AuthService(), permanent: true);
  final FirestoreService _firestoreService = Get.put(
    FirestoreService(),
    permanent: true,
  );

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
      // Navigate to role selection if they are on a protected route.
      // Wrapped in addPostFrameCallback so this is safe even on the very first
      // auth-state emission that fires before GetMaterialApp builds its navigator.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final route = Get.currentRoute;
        if (route != AppRoutes.splash &&
            route != AppRoutes.roleSelection &&
            !route.contains('login') &&
            !route.contains('registration') &&
            !route.contains('register')) {
          Get.offAllNamed(AppRoutes.roleSelection);
        }
      });
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

        // Check location permission BEFORE deciding navigation target.
        // This runs async here (outside postFrameCallback) so the result
        // is available when we decide which route to push.
        final locationService = Get.find<LocationService>();
        final alreadyGranted = await locationService.hasPermission();

        // All navigation wrapped in addPostFrameCallback so it is safe even
        // when this runs before GetMaterialApp finishes building its navigator.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final currentRoute = Get.currentRoute;

          // 1. Coming from login / registration → smart routing
          if (currentRoute.contains('login') ||
              currentRoute.contains('registration')) {
            if (alreadyGranted) {
              // Permission already granted — go straight to Home, no screen.
              _navigateToHome(userModel.role);
            } else {
              // First time or revoked — show the full location onboarding screen.
              _navigateToLocationScreen(userModel.role);
            }
          }
          // 2. Cold start (Splash / Role Selection / empty route) → Main Dashboard
          else if (currentRoute == AppRoutes.splash ||
              currentRoute == '' ||
              currentRoute == AppRoutes.roleSelection) {
            _navigateToHome(userModel.role);
          }
        });
      } else {
        // User is authenticated in Firebase but missing Firestore profile
        debugPrint(
          'Error: User document does not exist in Firestore for uid: $userId',
        );
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.snackbar(
            'Profile Not Found',
            'Your account data is missing. Please register again or contact support.',
            snackPosition: SnackPosition.TOP,
          );
        });
        await logout();
      }
    } catch (e) {
      debugPrint('Error fetching role: $e');
    }
  }

  /// Navigate to the appropriate Home screen based on role.
  void _navigateToHome(String role) {
    if (role == 'customer') {
      Get.offAllNamed(AppRoutes.customerMainLayout);
    } else if (role == 'vendor') {
      Get.offAllNamed(AppRoutes.vendorMain);
    } else if (role == 'driver') {
      Get.offAllNamed(AppRoutes.driverMain);
    }
  }

  /// Navigate to the full Location Access onboarding screen based on role.
  void _navigateToLocationScreen(String role) {
    if (role == 'customer') {
      Get.offAllNamed(AppRoutes.locationAccess);
    } else if (role == 'vendor') {
      Get.offAllNamed(AppRoutes.vendorLocationAccess);
    } else if (role == 'driver') {
      Get.offAllNamed(AppRoutes.driverLocationAccess);
    }
  }

  /// Ends an active driver trip before signing out:
  /// - Resets the driver Firestore status to 'ACTIVE'
  /// - Stops the background GPS service and clears the RTDB live-location node
  Future<void> _cleanupDriverSession(String driverId) async {
    try {
      // 1. Stop background tracking + clear RTDB live_tracking node
      if (Get.isRegistered<DriverTrackingService>()) {
        Get.find<DriverTrackingService>().stopTracking();
      }

      // 2. Reset driver status in Firestore so Vendor/Customer side
      //    sees the bus as offline immediately.
      await FirebaseFirestore.instance
          .collection('drivers')
          .doc(driverId)
          .update({'status': 'ACTIVE'});

      debugPrint('AuthController: Driver session cleaned up for $driverId');
    } catch (e) {
      debugPrint('AuthController: Error cleaning up driver session: $e');
    }
  }

  Future<void> logout() async {
    // If the logged-out user is a driver, end their trip cleanly first.
    final driverId = uid;
    final role = selectedRole.value;

    // Clear all in-memory session state BEFORE signing out so that any
    // listener (e.g. ever(firebaseUser, ...)) that fires during sign-out
    // sees a fully-cleared controller and never re-routes to a dashboard.
    uid = null;
    isLoggedIn.value = false;
    selectedRole.value = '';
    currentUserProfile.value = null;

    // Run driver-specific cleanup (non-blocking — errors are swallowed inside).
    if (role == 'driver' && driverId != null) {
      await _cleanupDriverSession(driverId);
    }

    await _authService.signOut();

    // Navigate only after sign-out is complete so the auth-state stream
    // change doesn't race with this explicit navigation.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.offAllNamed(AppRoutes.roleSelection);
    });
  }

  // legacy methods kept for compatibility with UI that hasn't been migrated yet
  Future<void> saveVendorSession({
    required String vendorUid,
    required String vendorPhone,
  }) async {
    uid = vendorUid;
    phone.value = vendorPhone;
    selectedRole.value = 'vendor';
    isLoggedIn.value = true;
  }
}
