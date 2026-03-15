import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Dummy model for the bus data
class VendorBusModel {
  final String id;
  final String name;
  final String regNumber;
  final String origin;
  final String destination;
  final String totalSeats;
  final String type;
  RxBool isActive;

  VendorBusModel({
    required this.id,
    required this.name,
    required this.regNumber,
    required this.origin,
    required this.destination,
    required this.totalSeats,
    required this.type,
    required bool isActive,
  }) : isActive = isActive.obs;
}

class VendorMyBusesController extends GetxController {
  final TextEditingController searchController = TextEditingController();

  // Tab Management (0: All, 1: Active, 2: Inactive)
  final RxInt selectedTab = 0.obs;

  // Dummy Fleet Data
  final RxList<VendorBusModel> allBuses = <VendorBusModel>[
    VendorBusModel(
      id: 'B1',
      name: 'Volvo B11R Multi-Axle',
      regNumber: 'KA-01-F-1234',
      origin: 'Bangalore',
      destination: 'Goa',
      totalSeats: '42 Sleeper',
      type: 'AC Sleeper (2+1)',
      isActive: true,
    ),
    VendorBusModel(
      id: 'B2',
      name: 'Scania Metrolink HD',
      regNumber: 'MH-04-GP-5678',
      origin: 'Mumbai',
      destination: 'Pune',
      totalSeats: '49 Seater',
      type: 'Luxury Semi-Sleeper',
      isActive: false,
    ),
    VendorBusModel(
      id: 'B3',
      name: 'Mercedes-Benz SHD',
      regNumber: 'DL-01-AX-9999',
      origin: 'Delhi',
      destination: 'Manali',
      totalSeats: '36 Sleeper',
      type: 'AC Sleeper',
      isActive: true,
    ),
  ].obs;

  // Derived list based on selected tab
  List<VendorBusModel> get filteredBuses {
    if (selectedTab.value == 1) {
      return allBuses.where((bus) => bus.isActive.value).toList();
    } else if (selectedTab.value == 2) {
      return allBuses.where((bus) => !bus.isActive.value).toList();
    }
    return allBuses;
  }

  void setTab(int index) {
    selectedTab.value = index;
  }

  void toggleBusStatus(VendorBusModel bus, bool newValue) {
    bus.isActive.value = newValue;
    // The UI will automatically react because the list and items are observable!
    Get.snackbar(
      'Status Updated',
      '${bus.name} is now ${newValue ? 'Active' : 'Inactive'}.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  void goToAddBus() {
    print("Navigating to Add Bus & Route...");
    Get.toNamed(
      '/vendor-add-travels',
    ); // Or '/add-bus' depending on your exact routing setup
  }

  void editBusDetails(String busId) {
    print("Editing details for bus $busId");
    // Get.toNamed('/vendor-edit-bus', arguments: {'id': busId});
  }

  void viewLiveRoute(String busId) {
    print("Viewing live route for bus $busId");
    Get.toNamed('/vendor-fleet-tracking');
  }

  void viewHistory(String busId) {
    print("Viewing history for bus $busId");
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
