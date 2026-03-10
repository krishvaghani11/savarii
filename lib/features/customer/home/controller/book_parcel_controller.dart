import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BookParcelController extends GetxController {
  // Text Controllers
  final TextEditingController pickupController = TextEditingController(
    text: '123 Main St, New York, NY',
  ); // Pre-filled for UI
  final TextEditingController dropController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  // Dropdown Data
  final List<String> parcelTypes = [
    'Documents',
    'Electronics',
    'Clothing',
    'Fragile',
    'Other',
  ];
  final RxnString selectedParcelType = RxnString();

  void selectParcelType(String? type) {
    selectedParcelType.value = type;
  }

  void useCurrentLocation() {
    print("Fetching GPS for pickup location...");
  }

  void viewRouteOnMap() {
    print("Opening full map view...");
  }

  void continueToReview() {
    print("Continuing to Review step...");
    // TODO: Navigate to Review Parcel Screen
    // Get.toNamed('/review-parcel');
  }

  @override
  void onClose() {
    pickupController.dispose();
    dropController.dispose();
    weightController.dispose();
    notesController.dispose();
    super.onClose();
  }
}
