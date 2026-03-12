import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VendorBookTicketController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // 1. Bus & Journey
  final RxString selectedRoute = 'Express 402 - Delhi to Jaipur (10:00 PM)'.obs;
  final RxString journeyDate = '10/05/2023'.obs;

  final List<String> availableRoutes = [
    'Express 402 - Delhi to Jaipur (10:00 PM)',
    'Volvo 901 - Delhi to Manali (08:30 PM)',
    'Standard 105 - Delhi to Agra (06:00 AM)',
  ];

  // 2. Seat Selection State
  final RxString selectedDeck = 'LOWER DECK'.obs;
  final RxList<String> selectedSeats = <String>[].obs;

  // Dummy data for already booked seats
  final List<String> bookedSeats = ['R1', 'L4', 'L5'];

  final double pricePerSeat = 850.00;

  // 3. Passenger Details
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final RxString selectedGender = 'Male'.obs;

  // --- Methods ---

  void setDeck(String deck) {
    selectedDeck.value = deck;
    selectedSeats
        .clear(); // Usually, changing decks clears selection for safety
  }

  void toggleSeat(String seatId) {
    if (bookedSeats.contains(seatId)) return; // Do nothing if booked

    if (selectedSeats.contains(seatId)) {
      selectedSeats.remove(seatId);
    } else {
      selectedSeats.add(seatId);
    }
  }

  Future<void> pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFE82E59),
            ), // Brand Red
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      // Format as DD/MM/YYYY
      journeyDate.value =
          "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
    }
  }

  void confirmBooking() {
    if (selectedSeats.isEmpty) {
      Get.snackbar(
        'Select a Seat',
        'Please select at least one seat to continue.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (formKey.currentState!.validate()) {
      print("Proceeding to payment for ${nameController.text}");
      // Route to Payment Details
      Get.toNamed('/vendor-payment-details');
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    super.onClose();
  }
}
