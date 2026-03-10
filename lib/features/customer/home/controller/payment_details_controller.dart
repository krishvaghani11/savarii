import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PaymentDetailsController extends GetxController {
  // Dummy Trip Data
  final String boardingPoint = "Central Station";
  final String droppingPoint = "MG Road";
  final String rideType = "Standard Ride";
  final String rideTime = "Today, 2:30 PM";

  // Pricing Data (Scaled for realistic INR values)
  final double baseFare = 500.00;
  final double distanceCharge = 1250.00;
  final double taxAndFees = 250.00;

  // Reactive Total (Updates if promo is applied)
  late RxDouble totalAmount;

  final TextEditingController promoController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    totalAmount = (baseFare + distanceCharge + taxAndFees).obs;
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
