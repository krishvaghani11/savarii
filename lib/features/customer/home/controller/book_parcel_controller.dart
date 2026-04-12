import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:savarii/core/theme/app_colors.dart';
import 'package:savarii/core/theme/app_text_styles.dart';

class BookParcelController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> sheetFormKey = GlobalKey<FormState>();

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
    // Setting up mock data based on the screenshot provided
    fullNameController.text = 'John Doe';
    mobileController.text = '98765 43210';
    emailController.text = 'john@example.com';
    
    receiverNameController.text = 'Jane Doe';
    receiverMobileController.text = '91234 56789';
    
    weightController.text = '0.5';
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

  void continueToReview() {
    if (pickupController.text.isEmpty || dropController.text.isEmpty) {
      Get.snackbar('Locations Required', 'Please enter both pickup and drop locations.', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if (weightController.text.isEmpty) {
      Get.snackbar('Weight Required', 'Please specify the weight of the parcel.', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    print("Continuing to Review step...");
    Get.toNamed('/parcel-payment');
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