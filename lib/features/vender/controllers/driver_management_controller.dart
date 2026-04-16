import 'package:get/get.dart';
import 'package:flutter/material.dart';

class DriverManagementController extends GetxController {
  
  // Mock Data matching your UI screenshot
  final int totalDrivers = 42;
  final int activeDrivers = 28;
  final int onTripDrivers = 14;

  final RxList<Map<String, dynamic>> drivers = [
    {
      'id': 'd1',
      'name': 'Rajesh Kumar',
      'status': 'ACTIVE',
      'phone': '+91 98765 43210',
      'dl': '1420110012345',
      // Placeholder image URL - replace with real assets/network images
      'image': 'https://i.pravatar.cc/150?img=11', 
    },
    {
      'id': 'd2',
      'name': 'Arun Sharma',
      'status': 'ON TRIP',
      'phone': '+91 98765 43211',
      'dl': '1420110015678',
      'image': 'https://i.pravatar.cc/150?img=12',
    },
    {
      'id': 'd3',
      'name': 'Vikram Singh',
      'status': 'ACTIVE',
      'phone': '+91 98765 43212',
      'dl': '1420110019900',
      'image': 'https://i.pravatar.cc/150?img=13',
    },
  ].obs;

  void addDriver() {
    print("Navigating to Add Driver Screen...");
    // TODO: Create the Add Driver Screen and route to it
     Get.toNamed('/vendor-add-driver');
  }

  void viewDriverDetails(String id) {
    print("Viewing details for driver ID: $id");
    // Get.toNamed('/vendor-driver-details', arguments: {'driverId': id});
  }

  void showDriverOptions(String id) {
    // Action for the 3-dot menu
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
              onTap: () => Get.back(),
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Remove Driver'),
              onTap: () => Get.back(),
            ),
          ],
        ),
      ),
    );
  }
}