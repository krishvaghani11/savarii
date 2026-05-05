import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:savarii/core/theme/app_colors.dart';
import 'package:savarii/core/theme/app_text_styles.dart';

class CustomerAddPassengerController extends GetxController {
  final GlobalKey<FormState> contactFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> sheetFormKey = GlobalKey<FormState>();

  // Passed Data
  String busId = '';
  String busName = '';
  String journeyDate = '';
  List<String> selectedSeats = [];
  String vendorId = '';
  double pricePerSeat = 0.0;

  // Dynamic Data
  String boardingPoint = '';
  String droppingPoint = '';
  String _departureTime = '';

  // Contact Details
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  // Sheet Controllers
  final TextEditingController sheetNameController = TextEditingController();
  final TextEditingController sheetMobileController = TextEditingController();
  final TextEditingController sheetAgeController = TextEditingController();
  final RxString selectedGender = 'Male'.obs;

  // Reactive State
  final RxList<Map<String, String>> addedPassengers = <Map<String, String>>[].obs;

  double get totalAmount => addedPassengers.length * pricePerSeat;

  @override
  void onInit() {
    super.onInit();
    // Retrieve arguments passed from Select Points Screen
    final args = Get.arguments ?? {};
    busId = args['busId'] ?? '';
    busName = args['busName'] ?? '';
    journeyDate = args['journeyDate'] ?? '';
    selectedSeats = List<String>.from(args['selectedSeats'] ?? []);
    vendorId = args['vendorId'] ?? '';
    pricePerSeat = args['seatPrice'] ?? 0.0;
    boardingPoint = args['boardingPoint'] ?? 'Central Mall Gate 2 - 09:30 PM';
    droppingPoint = args['droppingPoint'] ?? 'Highway Plaza - 06:45 AM';
    _departureTime = args['departureTime']?.toString() ?? '';
  }

  // --- Bottom Sheet Logic ---
  void openAddPassengerSheet(BuildContext context) {
    sheetNameController.clear();
    sheetMobileController.clear();
    sheetAgeController.clear();
    selectedGender.value = 'Male';

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24.0),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
        ),
        child: Form(
          key: sheetFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40, height: 5,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(color: AppColors.secondaryGreyBlue.withOpacity(0.3), borderRadius: BorderRadius.circular(10)),
                ),
              ),
              Text('Add Passenger', style: AppTextStyles.h2),
              const SizedBox(height: 24),

              _buildSheetInput('Full Name', 'Enter passenger name', sheetNameController),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(flex: 1, child: _buildSheetInput('Age', 'e.g., 25', sheetAgeController, isNumber: true)),
                  const SizedBox(width: 16),
                  Expanded(flex: 2, child: _buildGenderDropdown()),
                ],
              ),
              const SizedBox(height: 16),

              _buildSheetInput('Mobile Number', '+91 00000 00000', sheetMobileController, isNumber: true),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: savePassenger,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryAccent,
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Text('Save Passenger', style: AppTextStyles.buttonText),
              ),
              const SizedBox(height: 16), // Buffer for keyboard
            ],
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
        Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.primaryDark, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.secondaryGreyBlue.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextFormField(
            controller: ctrl,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            validator: (val) => val!.isEmpty ? 'Required' : null,
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

  Widget _buildGenderDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Gender', style: AppTextStyles.caption.copyWith(color: AppColors.primaryDark, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.secondaryGreyBlue.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: Obx(() => DropdownButton<String>(
                  value: selectedGender.value,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.secondaryGreyBlue),
                  items: ['Male', 'Female', 'Other'].map((String value) {
                    return DropdownMenuItem<String>(value: value, child: Text(value, style: AppTextStyles.bodyMedium));
                  }).toList(),
                  onChanged: (val) => selectedGender.value = val!,
                )),
          ),
        ),
      ],
    );
  }

  void savePassenger() {
    if (sheetFormKey.currentState!.validate()) {
      addedPassengers.add({
        'name': sheetNameController.text.trim(),
        'age': sheetAgeController.text.trim(),
        'gender': selectedGender.value,
        'mobile': sheetMobileController.text.trim(),
      });
      Get.back(); // Close Bottom Sheet
    }
  }

  void removePassenger(int index) {
    addedPassengers.removeAt(index);
  }

  void proceedToPay() {
    if (addedPassengers.isEmpty) {
      Get.snackbar('Add Passengers', 'Please add at least one passenger.', snackPosition: SnackPosition.TOP);
      return;
    }
    if (addedPassengers.length != selectedSeats.length) {
      Get.snackbar('Passengers Details', 'Please add exactly ${selectedSeats.length} passenger details to proceed.', snackPosition: SnackPosition.TOP);
      return;
    }
    if (!contactFormKey.currentState!.validate()) {
      Get.snackbar('Contact Details', 'Please provide valid contact details to receive your ticket.', snackPosition: SnackPosition.TOP);
      return;
    }
    
    // Proceed to actual payment screen
    print("Navigating to Payment...");
    Get.toNamed('/payment-details', arguments: {
      'busId': busId,
      'busName': busName,
      'journeyDate': journeyDate,
      'seatPrice': pricePerSeat,
      'selectedSeats': selectedSeats,
      'boardingPoint': boardingPoint,
      'droppingPoint': droppingPoint,
      'vendorId': vendorId,
      'passengers': addedPassengers,
      'contactEmail': emailController.text.trim(),
      'contactPhone': phoneController.text.trim(),
      'departureTime': _departureTime,
    });
  }

  @override
  void onClose() {
    emailController.dispose();
    phoneController.dispose();
    sheetNameController.dispose();
    sheetMobileController.dispose();
    sheetAgeController.dispose();
    super.onClose();
  }
}