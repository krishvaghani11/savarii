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
}
