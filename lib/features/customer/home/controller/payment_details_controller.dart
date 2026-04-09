import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PaymentDetailsController extends GetxController {
  // Navigation Payload Parameters
  String busId = '';
  String busName = '';
  String journeyDate = '';
  double seatPrice = 0.0;
  List<String> selectedSeats = [];

  // Reactive String Fields mapping straight to the View Elements
  final RxString boardingPoint = ''.obs;
  final RxString droppingPoint = ''.obs;
  
  // Tax calculations
  final double taxAndFees = 250.00;

  // Reactively track the real Base Fare
  late RxDouble baseFare;
  late RxDouble totalAmount;

  final TextEditingController promoController = TextEditingController();

  @override
  void onInit() {
    super.onInit();

    if (Get.arguments != null) {
      final args = Get.arguments as Map<String, dynamic>;
      busId = args['busId'] ?? '';
      busName = args['busName'] ?? 'Standard Ride';
      journeyDate = args['journeyDate'] ?? 'Unknown Date';
      seatPrice = args['seatPrice'] ?? 0.0;
      selectedSeats = List<String>.from(args['selectedSeats'] ?? []);
      
      boardingPoint.value = args['boardingPoint']?.toString() ?? 'Not Selected';
      droppingPoint.value = args['droppingPoint']?.toString() ?? 'Not Selected';
    }

    baseFare = (seatPrice * selectedSeats.length).obs;
    totalAmount = (baseFare.value + taxAndFees).obs;
  }

  void applyPromo() {
    if (promoController.text.isNotEmpty) {
      print("Applying Promo Code: ${promoController.text}");
      // Example: deduct ₹150 discount
      totalAmount.value -= 150.00;
      Get.snackbar(
        'Promo Applied',
        'Discount has been applied to your total.',
        snackPosition: SnackPosition.BOTTOM,
      );
      promoController.clear();
    }
  }

  void confirmPayment() {
    print("Processing Ticket Payment of ₹${totalAmount.value}...");
    Get.toNamed('/booking-confirmation');
  }

  @override
  void onClose() {
    promoController.dispose();
    super.onClose();
  }
}
