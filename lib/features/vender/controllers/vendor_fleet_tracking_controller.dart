import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FleetBusModel {
  final String id;
  final String status;
  final String nextStop;
  final String speed;
  final String condition;
  final bool isDelayed;

  FleetBusModel({
    required this.id,
    required this.status,
    required this.nextStop,
    required this.speed,
    required this.condition,
    this.isDelayed = false,
  });
}

class VendorFleetTrackingController extends GetxController {
  final TextEditingController searchController = TextEditingController();
  final RxString selectedFilter = 'All Active'.obs;

  final List<FleetBusModel> fleet = [
    FleetBusModel(
      id: 'Bus SV-402',
      status: 'ON TIME',
      nextStop: 'Terminal 3 Central',
      speed: '48',
      condition: 'CURRENT SPEED',
    ),
    FleetBusModel(
      id: 'Bus SV-108',
      status: 'DELAYED 12M',
      nextStop: 'East Plaza Blvd',
      speed: '12',
      condition: 'HEAVY TRAFFIC',
      isDelayed: true,
    ),
    FleetBusModel(
      id: 'Bus SV-922',
      status: 'ON TIME',
      nextStop: 'North Harbor',
      speed: '52',
      condition: 'CRUISING',
    ),
  ];

  void setFilter(String filter) => selectedFilter.value = filter;

  void openOptions() => print("Opening tracking options...");

  // Map Controls
  void zoomIn() => print("Zooming in map...");

  void zoomOut() => print("Zooming out map...");

  void recenterMap() => print("Recentering map...");

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
