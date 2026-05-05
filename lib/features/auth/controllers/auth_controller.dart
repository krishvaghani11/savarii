import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/services/auth_services.dart';
import '../../../core/services/driver_tracking_service.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/notification_service.dart';
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

  /// Set to true by registration controllers BEFORE creating the Firebase Auth
  /// account. This prevents [_handleAuthChanged] from running the profile-fetch
  /// auto-route while Firestore writes are still in progress.
  var isRegistering = false.obs;

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
    debugPrint('AuthController: Auth state changed. User: ${user?.uid}');
    if (user == null) {
      uid = null;
      isLoggedIn.value = false;
      currentUserProfile.value = null;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        final route = Get.currentRoute;
        debugPrint('AuthController: No user, current route: $route');
        // ONLY navigate if we are NOT on the splash screen. 
        // SplashController will handle the initial routing from splash.
        if (route != AppRoutes.splash &&
            route != AppRoutes.roleSelection &&
            !route.contains('login') &&
            !route.contains('registration') &&
            !route.contains('register')) {
          _safeNavigate(AppRoutes.roleSelection);
        }
      });
    } else {
      uid = user.uid;
      isLoggedIn.value = true;

      // Skip auto-routing if a registration flow is managing navigation itself.
      if (isRegistering.value) {
        debugPrint(
            'AuthController: Skipping auto-route — registration in progress.');
        return;
      }

      debugPrint('AuthController: User logged in, fetching role...');
      await _fetchRoleAndNavigate(user.uid);
    }
  }

  Future<void> _fetchRoleAndNavigate(String userId) async {
    try {
      debugPrint('AuthController: Fetching profile for $userId');
      final userModel = await _firestoreService.getUserProfile(userId);

      if (userModel != null) {
        debugPrint('AuthController: Profile found. Role: ${userModel.role}');
        currentUserProfile.value = userModel;
        selectedRole.value = userModel.role;

        NotificationService.to.saveFcmToken(userId, userModel.role);
        NotificationService.to.showMissedNotifications(userId, userModel.role);

        final locationService = Get.find<LocationService>();
        final alreadyGranted = await locationService.hasPermission();
        debugPrint(
            'AuthController: Location permission granted: $alreadyGranted');

        WidgetsBinding.instance.addPostFrameCallback((_) async {
          final currentRoute = Get.currentRoute;
          debugPrint(
              'AuthController: Profile ready. Current route: $currentRoute');

          // 1. If we are on login/registration, move them forward immediately.
          if (currentRoute.contains('login') ||
              currentRoute.contains('registration')) {
            if (alreadyGranted) {
              _navigateToHome(userModel.role);
            } else {
              _navigateToLocationScreen(userModel.role);
            }
          }
          // 2. If we are on Splash, DO NOTHING. 
          // SplashController is watching our 'isLoggedIn' and 'currentUserProfile' 
          // and will navigate when its timer is done.

        });
      } else {
        debugPrint(
            'AuthController: Error - User document does not exist for uid: $userId');
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
      debugPrint('AuthController: Exception in _fetchRoleAndNavigate: $e');
      // If we are stuck on splash and an error occurs, fallback to role selection
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Get.currentRoute == AppRoutes.splash) {
          _safeNavigate(AppRoutes.roleSelection);
        }
      });
    }
  }

  /// Safely navigate by ensuring the GetX navigator is ready.
  /// If not ready, it retries in the next frame.
  void _safeNavigate(String route,
      {Map<String, dynamic>? arguments, bool offAll = true}) {
    if (Get.key.currentState == null) {
      debugPrint(
          'AuthController: Navigator not ready yet, retrying navigation to $route in next frame...');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _safeNavigate(route, arguments: arguments, offAll: offAll);
      });
      return;
    }

    if (offAll) {
      Get.offAllNamed(route, arguments: arguments);
    } else {
      Get.toNamed(route, arguments: arguments);
    }
  }

  /// Navigate to the appropriate Home screen based on role.
  void _navigateToHome(String role) {
    String route;
    if (role == 'customer') {
      route = AppRoutes.customerMainLayout;
    } else if (role == 'vendor') {
      route = AppRoutes.vendorMain;
    } else if (role == 'driver') {
      route = AppRoutes.driverMain;
    } else {
      return;
    }
    _safeNavigate(route);
  }

  /// Navigate to the full Location Access onboarding screen based on role.
  void _navigateToLocationScreen(String role) {
    String route;
    if (role == 'customer') {
      route = AppRoutes.locationAccess;
    } else if (role == 'vendor') {
      route = AppRoutes.vendorLocationAccess;
    } else if (role == 'driver') {
      route = AppRoutes.driverLocationAccess;
    } else {
      return;
    }
    _safeNavigate(route);
  }

  /// Called by registration controllers after ALL Firestore writes are done.
  /// Sets the in-memory profile so the app can route without an extra read.
  Future<void> navigateAfterRegistration(String newUid, String role) async {
    isRegistering.value = false;

    // Populate in-memory profile so downstream code (FCM, routing) works
    // immediately without waiting for another Firestore fetch.
    currentUserProfile.value = UserModel(
      uid: newUid,
      email: FirebaseAuth.instance.currentUser?.email ?? '',
      role: role,
      createdAt: DateTime.now(),
    );
    selectedRole.value = role;
    isLoggedIn.value = true;

    NotificationService.to.saveFcmToken(newUid, role);

    final locationService = Get.find<LocationService>();
    final alreadyGranted = await locationService.hasPermission();
    debugPrint(
        'AuthController: navigateAfterRegistration — location granted: $alreadyGranted');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (alreadyGranted) {
        _navigateToHome(role);
      } else {
        _navigateToLocationScreen(role);
      }
    });
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
    final oldUid = uid;
    final role = selectedRole.value;

    // Clear all in-memory session state BEFORE signing out so that any
    // listener (e.g. ever(firebaseUser, ...)) that fires during sign-out
    // sees a fully-cleared controller and never re-routes to a dashboard.
    uid = null;
    isLoggedIn.value = false;
    selectedRole.value = '';
    currentUserProfile.value = null;

    // 1. Remove FCM token from Firestore so the user doesn't receive
    //    notifications on this device after logging out.
    if (oldUid != null && role.isNotEmpty) {
      await NotificationService.to.removeFcmToken(oldUid, role);
    }

    // Run driver-specific cleanup (non-blocking — errors are swallowed inside).
    if (role == 'driver' && oldUid != null) {
      await _cleanupDriverSession(oldUid);
    }

    await _authService.signOut();

    // Navigate only after sign-out is complete so the auth-state stream
    // change doesn't race with this explicit navigation.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _safeNavigate(AppRoutes.roleSelection);
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
