import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

/// A centralized service to handle location permissions and fetching coordinates.
class LocationService extends GetxService {
  
  /// Checks if location services are enabled and requests permissions if necessary.
  /// Returns the current [Position] if successful, or null/error if not.
  Future<Position?> checkAndRequestPermissions() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. Check if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Get.snackbar(
        'Location Services Disabled',
        'Please enable location services in your device settings.',
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade900,
        snackPosition: SnackPosition.TOP,
      );
      return null;
    }

    // 2. Check current permission status.
    permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      // Request permission.
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Get.snackbar(
          'Permission Denied',
          'Location permissions are required to provide this feature.',
          backgroundColor: Colors.orange.shade50,
          colorText: Colors.orange.shade900,
          snackPosition: SnackPosition.TOP,
        );
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are permanently denied, handle appropriately.
      Get.snackbar(
        'Permissions Permanently Denied',
        'Location permissions are permanently denied. Please enable them in your app settings.',
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade900,
        snackPosition: SnackPosition.TOP,
        mainButton: TextButton(
          onPressed: () => Geolocator.openAppSettings(),
          child: const Text('Settings'),
        ),
      );
      return null;
    }

    // 3. If we reached here, permissions are granted. Fetch current position.
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print("Error fetching location: $e");
      Get.snackbar(
        'Location Error',
        'Could not fetch your current location. Please try again.',
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade900,
        snackPosition: SnackPosition.TOP,
      );
      return null;
    }
  }

  /// One-time fetch of the current position without showing UI/snackbars.
  Future<Position?> getCurrentLocationSilently() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
        return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      }
    } catch (e) {
      debugPrint("Silent location fetch failed: $e");
    }
    return null;
  }

  /// Returns true if the user has already granted location permission
  /// (whileInUse or always). Does NOT trigger any UI or system dialog.
  Future<bool> hasPermission() async {
    try {
      final permission = await Geolocator.checkPermission();
      return permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;
    } catch (_) {
      return false;
    }
  }

  /// Returns true if the device's location service (GPS) is switched on.
  Future<bool> isGpsEnabled() => Geolocator.isLocationServiceEnabled();

  /// Shows a compact, non-full-screen dialog asking the user to enable
  /// location. Call this from home-screen controllers after a frame delay.
  ///
  /// [isDeniedForever] – when true the primary action opens App Settings
  ///                     instead of requesting runtime permission.
  /// [isDriverRole]    – when true the dialog cannot be dismissed by tapping
  ///                     outside (drivers need location to work).
  Future<void> showLocationPermissionDialog({
    bool isDeniedForever = false,
    bool isDriverRole = false,
  }) async {
    await Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: EdgeInsets.zero,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header bar
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: const BoxDecoration(
                color: Color(0xFFE53935),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: const Column(
                children: [
                  Icon(Icons.location_on, color: Colors.white, size: 40),
                  SizedBox(height: 8),
                  Text(
                    'Location Access Needed',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // Body
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Text(
                isDeniedForever
                    ? 'Location permission was permanently denied. Please open App Settings and enable it to get the best experience.'
                    : 'Enable location so we can show nearby routes, accurate fares, and real-time tracking.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF555555),
                  height: 1.5,
                ),
              ),
            ),
            // Buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        Get.back();
                        if (isDeniedForever) {
                          await Geolocator.openAppSettings();
                        } else {
                          await checkAndRequestPermissions();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE53935),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        isDeniedForever ? 'Open Settings' : 'Enable Now',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  if (!isDriverRole) ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () => Get.back(),
                        child: const Text(
                          'Later',
                          style: TextStyle(color: Color(0xFF888888)),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: !isDriverRole,
    );
  }
}
