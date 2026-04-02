import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/firestore_service.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../routes/app_routes.dart';

// Dynamic model for the bus data
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

  factory VendorBusModel.fromMap(Map<String, dynamic> map, String docId) {
    final route = map['route'] as Map<String, dynamic>? ?? {};
    return VendorBusModel(
      id: docId,
      name: map['busName'] ?? '',
      regNumber: map['busNumber'] ?? '',
      origin: route['from'] ?? '',
      destination: route['to'] ?? '',
      totalSeats: '${map['totalSeats'] ?? '0'} Seats',
      type: map['busType'] ?? '',
      isActive: map['isActive'] ?? true,
    );
  }
}

class VendorMyBusesController extends GetxController {
  final TextEditingController searchController = TextEditingController();

  final FirestoreService _firestore = Get.find<FirestoreService>();
  final AuthController _auth = Get.find<AuthController>();

  // Tab Management (0: All, 1: Active, 2: Inactive)
  final RxInt selectedTab = 0.obs;

  // Real Fleet Data
  final RxList<VendorBusModel> allBuses = <VendorBusModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchBuses();
  }

  void fetchBuses() {
    final uid = _auth.uid;
    if (uid == null) return;
    
    _firestore.getVendorBusesStream(uid).listen((busList) {
      allBuses.assignAll(busList.map((data) => VendorBusModel.fromMap(data, data['id'])).toList());
    });
  }

  // Derived list based on selected tab and search query
  List<VendorBusModel> get filteredBuses {
    var buses = allBuses.toList();
    
    // Apply Tab Filter
    if (selectedTab.value == 1) {
      buses = buses.where((bus) => bus.isActive.value).toList();
    } else if (selectedTab.value == 2) {
      buses = buses.where((bus) => !bus.isActive.value).toList();
    }

    // Apply Search Filter
    final query = searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      buses = buses.where((bus) => 
        bus.name.toLowerCase().contains(query) || 
        bus.regNumber.toLowerCase().contains(query)).toList();
    }

    return buses;
  }

  void setTab(int index) {
    selectedTab.value = index;
  }

  Future<void> toggleBusStatus(VendorBusModel bus, bool newValue) async {
    final originalValue = bus.isActive.value;
    bus.isActive.value = newValue; // Optimistic update
    
    try {
      await _firestore.updateBusStatus(bus.id, newValue);
      Get.snackbar(
        'Status Updated',
        '${bus.name} is now ${newValue ? 'Active' : 'Inactive'}.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade50,
        colorText: Colors.green.shade800,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      bus.isActive.value = originalValue; // Revert
      Get.snackbar(
        'Update Failed',
        'Could not update status. Try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade800,
      );
    }
  }

  void goToAddBus() {
    Get.toNamed(AppRoutes.addBus); // Navigate to create mode
  }

  void editBusDetails(String busId) {
    // Navigate to add-bus passing the busId in arguments to trigger Edit Mode
    Get.toNamed(AppRoutes.addBus, arguments: {'busId': busId});
  }

  void viewLiveRoute(String busId) {
    Get.toNamed(AppRoutes.vendorFleetTracking);
  }

  void viewHistory(String busId) {
    print("Viewing history for bus $busId");
  }

  @override
  void onClose() {
    // searchController.dispose(); // Commented to prevent hot-reload and animation transition crashes
    super.onClose();
  }
}
