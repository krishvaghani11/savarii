import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ParcelPaymentController extends GetxController {
  // Dummy Data for the UI
  final String orderId = '#SAV-89203';
  final String pickupLocation = 'Downtown Bus Terminal';
  final String pickupTime = 'Today, 10:00 AM';
  final String dropoffLocation = 'Sector 42, Gurgaon';
  final String dropoffTime = 'Today, 02:30 PM';

  // Pricing Data
  final double baseFare = 150.00;
  final double weightSurcharge = 50.00;
  final double serviceFee = 20.00;
  final double tax = 18.00;

  // Reactive Total (in case we apply a promo code)
  late RxDouble totalAmount;

  final TextEditingController promoController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    totalAmount = (baseFare + weightSurcharge + serviceFee + tax).obs;
  }

  void helpAction() {
    print("Opening Help & Support...");
  }

  void applyPromo() {
    if (promoController.text.isNotEmpty) {
      print("Applying Promo Code: ${promoController.text}");
      // Example: deduct $2
      totalAmount.value -= 2.00;
      Get.snackbar(
        'Promo Applied',
        'Discount has been applied to your total.',
        snackPosition: SnackPosition.BOTTOM,
      );
      promoController.clear();
    }
  }

  void payNow() {
    print("Processing Payment of \$${totalAmount.value}...");
    Get.toNamed('/parcel-confirmation');
  }

  @override
  void onClose() {
    promoController.dispose();
    super.onClose();
  }
}
