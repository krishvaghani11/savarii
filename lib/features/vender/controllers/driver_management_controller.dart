import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:savarii/core/services/firestore_service.dart';
import 'package:savarii/features/auth/controllers/auth_controller.dart';
import 'package:savarii/routes/app_routes.dart';

class DriverManagementController extends GetxController {
  final FirestoreService _firestoreService = Get.find<FirestoreService>();
  final AuthController _authController = Get.find<AuthController>();
  
  final RxList<Map<String, dynamic>> drivers = <Map<String, dynamic>>[].obs;
  
  final RxInt totalDrivers = 0.obs;
  final RxInt activeDrivers = 0.obs;
  final RxInt onTripDrivers = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _bindDrivers();
  }

  void _bindDrivers() {
    final String vendorId = _authController.uid ?? '';
    print("Binding drivers for Vendor ID: $vendorId");
    
    if (vendorId.isNotEmpty) {
      // Clear before binding to ensure no stale data
      drivers.clear();
      
      drivers.bindStream(_firestoreService.getVendorDriversStream(vendorId));
      
      // Calculate stats whenever drivers list changes
      ever(drivers, (List<Map<String, dynamic>> driverList) {
        print("Driver stream updated. Total drivers found: ${driverList.length}");
        
        totalDrivers.value = driverList.length;
        activeDrivers.value = driverList.where((d) => d['status'] == 'ACTIVE' || d['status'] == 'AVAILABLE').length;
        onTripDrivers.value = driverList.where((d) => d['status'] == 'ON TRIP').length;
        
        // Debug: Log names to help user find "Piyush"
        for (var d in driverList) {
           print("Driver: ${d['name']} (ID: ${d['id']}, Status: ${d['status']})");
        }
      });
    } else {
      print("Error: Vendor ID is empty. Cannot bind drivers.");
    }
  }

  void addDriver() {
    print("Navigating to Add Driver Screen...");
    Get.toNamed('/vendor-add-driver');
  }

  void viewDriverDetails(Map<String, dynamic> driver) {
    print("Viewing details for driver ID: ${driver['id']}");
    Get.toNamed(AppRoutes.driverDetails, arguments: driver);
  }

  void showDriverOptions(Map<String, dynamic> driver) {
    final String id = driver['id'];
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.blue),
              title: const Text('Edit Driver'),
              onTap: () {
                Get.back();
                Get.toNamed(AppRoutes.editDriver, arguments: driver);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Remove Driver'),
              onTap: () async {
                Get.back();
                try {
                  // Perform soft delete by updating status
                  await _firestoreService.updateDriverStatus(id, 'driver deleted');
                  Get.snackbar(
                    'Success', 
                    'Driver removed successfully',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red.shade50,
                    colorText: Colors.red.shade900,
                  );
                } catch (e) {
                  Get.snackbar('Error', 'Failed to remove driver: $e');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
