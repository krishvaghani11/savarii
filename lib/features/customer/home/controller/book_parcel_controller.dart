import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:savarii/core/theme/app_colors.dart';
import 'package:savarii/core/theme/app_text_styles.dart';
import 'package:savarii/core/services/firestore_service.dart';
import 'package:savarii/core/services/city_geolocation_service.dart';
import 'package:savarii/models/bus_model.dart';

class BookParcelController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> sheetFormKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = Get.find<FirestoreService>();

  // Location Controllers
  final TextEditingController pickupController = TextEditingController();
  final TextEditingController dropController = TextEditingController();

  // Parcel Details Controllers
  final TextEditingController weightController = TextEditingController();

  // Sender Contact Information Controllers
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  // Receiver Contact Information Controllers
  final TextEditingController receiverNameController = TextEditingController();
  final TextEditingController receiverMobileController = TextEditingController();

  // Extra Details
  final TextEditingController notesController = TextEditingController();

  // Bottom Sheet Resident Controllers
  final TextEditingController flatNoController = TextEditingController();
  final TextEditingController societyController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController districtController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();
  final TextEditingController stateController = TextEditingController();

  // States to track saved residents
  final Rxn<Map<String, String>> pickupResidentDetails = Rxn();
  final Rxn<Map<String, String>> dropResidentDetails = Rxn();
  bool isEditingPickupResident = true; // Tracks which location the sheet is for

  // Loading state
  final RxBool isLoading = false.obs;

  // Autocomplete suggestion logic
  Future<List<CitySuggestion>> getCitySuggestions(String query) async {
    return await CityGeolocationService.fetchCitySuggestions(query);
  }

  // Dropdown Data
  final List<String> parcelTypes = [
    'Documents',
    'Electronics',
    'Clothing',
    'Fragile',
    'Other',
  ];
  final RxString selectedParcelType = 'Documents'.obs;

  @override
  void onInit() {
    super.onInit();
    // Fields are now empty by default for production use.
  }

  void selectParcelType(String? type) {
    if (type != null) {
      selectedParcelType.value = type;
    }
  }

  // --- Bottom Sheet Logic ---
  void openResidentSheet({required bool isPickup, required BuildContext context}) {
    isEditingPickupResident = isPickup;
    
    // Clear the form fields before opening
    flatNoController.clear();
    societyController.clear();
    cityController.clear();
    districtController.clear();
    pincodeController.clear();
    stateController.clear();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24.0),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
        ),
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: SingleChildScrollView(
            child: Form(
              key: sheetFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40, height: 5, margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(color: AppColors.secondaryGreyBlue.withOpacity(0.3), borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  Text(
                    isPickup ? 'Add Pickup Resident' : 'Add Drop Resident',
                    style: AppTextStyles.h2
                  ),
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(child: _buildSheetInput('Flat / House No.', 'e.g., A-102', flatNoController)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildSheetInput('Pincode', '000000', pincodeController, isNumber: true)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  _buildSheetInput('Society / Apartment / Village', 'Enter society or village name', societyController),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(child: _buildSheetInput('City', 'Enter city', cityController)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildSheetInput('District', 'Enter district', districtController)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  _buildSheetInput('State', 'Enter state', stateController),
                  const SizedBox(height: 32),

                  ElevatedButton(
                    onPressed: saveResidentDetails,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryAccent,
                      minimumSize: const Size(double.infinity, 54),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: Text('Confirm Resident Details', style: AppTextStyles.buttonText),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildSheetInput(String label, String hint, TextEditingController ctrl, {bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.primaryDark, fontWeight: FontWeight.bold, fontSize: 10)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.secondaryGreyBlue.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextFormField(
            controller: ctrl,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            validator: (val) => val == null || val.isEmpty ? 'Required' : null,
            style: AppTextStyles.bodyMedium,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.secondaryGreyBlue.withOpacity(0.6)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  void saveResidentDetails() {
    if (sheetFormKey.currentState!.validate()) {
      final detailsMap = {
        'flat': flatNoController.text.trim(),
        'society': societyController.text.trim(),
        'city': cityController.text.trim(),
        'district': districtController.text.trim(),
        'pincode': pincodeController.text.trim(),
        'state': stateController.text.trim(),
      };

      if (isEditingPickupResident) {
        pickupResidentDetails.value = detailsMap;
      } else {
        dropResidentDetails.value = detailsMap;
      }
      
      Get.back(); // Close the bottom sheet
      Get.snackbar(
        'Success', 
        'Resident details added successfully.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void clearResidentDetails({required bool isPickup}) {
    if (isPickup) {
      pickupResidentDetails.value = null;
    } else {
      dropResidentDetails.value = null;
    }
  }

  Future<void> continueToReview() async {
    final pickupCity = pickupController.text.trim();
    final dropCity = dropController.text.trim();

    if (pickupCity.isEmpty || dropCity.isEmpty) {
      Get.snackbar('Locations Required', 'Please enter both pickup and drop locations.', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final weightText = weightController.text.trim();
    if (weightText.isEmpty) {
      Get.snackbar('Weight Required', 'Please specify the weight of the parcel.', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final double weight = double.tryParse(weightText) ?? -1;
    if (weight <= 0) {
      Get.snackbar('Invalid Weight', 'Please enter a valid weight in kg.', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      final buses = await _firestoreService.getActiveBuses();
      
      BusModel? matchedBus;
      String estimatedPickupTime = '--:--';
      String estimatedDropoffTime = '--:--';

      for (final bus in buses) {
        String pickupLower = pickupCity.toLowerCase();
        String dropLower = dropCity.toLowerCase();
        
        // Find boarding point match
        final boardingMatch = bus.boardingPoints.firstWhere((p) => p.toLowerCase().contains(pickupLower), orElse: () => '');
        // Find dropping point match
        final droppingMatch = bus.droppingPoints.firstWhere((p) => p.toLowerCase().contains(dropLower), orElse: () => '');

        if (boardingMatch.isNotEmpty && droppingMatch.isNotEmpty) {
          matchedBus = bus;
          
          // Improved time extraction logic
          if (boardingMatch.contains('-')) {
            estimatedPickupTime = boardingMatch.split('-').last.trim();
          }
          // Fallback to main bus departure time if point extraction is weak
          if (estimatedPickupTime == '--:--' || estimatedPickupTime.isEmpty) {
            estimatedPickupTime = bus.departureTime;
          }

          if (droppingMatch.contains('-')) {
            estimatedDropoffTime = droppingMatch.split('-').last.trim();
          }
          // Fallback to main bus arrival time
          if (estimatedDropoffTime == '--:--' || estimatedDropoffTime.isEmpty) {
            estimatedDropoffTime = bus.arrivalTime;
          }
          
          break; // Use first matching bus
        }
      }

      if (matchedBus == null) {
        Get.snackbar(
          'No Bus Found', 
          'We currently have no buses running between $pickupCity and $dropCity capable of handling parcels.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Calculate pricing logic (1kg = 100rs, service fee = 45)
      final double baseFare = weight * 100.0;
      final double serviceFee = 45.0;
      final double tax = (baseFare + serviceFee) * 0.05;

      // Ensure bus number is populated (if unavailable, fallback)
      String busNumber = matchedBus.busNumber;
      if (busNumber.isEmpty) busNumber = 'Unknown Register';

      final routePayload = {
        'pickupCity': pickupCity,
        'dropCity': dropCity,
        'weight': weight,
        'parcelType': selectedParcelType.value,
        'senderName': fullNameController.text.trim(),
        'senderPhone': mobileController.text.trim(),
        'receiverName': receiverNameController.text.trim(),
        'receiverPhone': receiverMobileController.text.trim(),
        'pickupResident': pickupResidentDetails.value,
        'dropResident': dropResidentDetails.value,
        'notes': notesController.text.trim(),
        'busId': matchedBus.id,
        'busName': matchedBus.busName,
        'busNumber': busNumber,
        'vendorId': matchedBus.vendorId, // Needs to be captured for Vendor rendering
        'driverName': matchedBus.driverName,
        'driverPhone': matchedBus.driverPhone,
        'estimatedPickupTime': estimatedPickupTime,
        'estimatedDropoffTime': estimatedDropoffTime,
        'baseFare': baseFare,
        'serviceFee': serviceFee,
        'tax': tax,
      };

      print("Continuing to Review step...");
      Get.toNamed('/parcel-payment', arguments: routePayload);

    } catch (e) {
      Get.snackbar('Error', 'Failed to search for available routes. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    pickupController.dispose();
    dropController.dispose();
    weightController.dispose();
    fullNameController.dispose();
    mobileController.dispose();
    emailController.dispose();
    receiverNameController.dispose();
    receiverMobileController.dispose();
    notesController.dispose();
    
    // Bottom sheet controllers
    flatNoController.dispose();
    societyController.dispose();
    cityController.dispose();
    districtController.dispose();
    pincodeController.dispose();
    stateController.dispose();
    
    super.onClose();
  }
}