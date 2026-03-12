import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VendorPaymentDetailsController extends GetxController {
  // Dummy Booking Data
  final String origin = "Pune";
  final String destination = "Mumbai";
  final String date = "Oct 24, 2023";
  final String seat = "Seat L1";

  final String passengerName = "John Doe";
  final String passengerPhone = "+91 9876543210";

  // Fare Details
  final double baseFare = 800.00;
  final double gst = 40.00;
  final double platformFee = 10.00;
  late final double totalAmount;

  // Payment Selection State
  final RxString selectedPaymentMethod = 'UPI'.obs;

  @override
  void onInit() {
    super.onInit();
    totalAmount = baseFare + gst + platformFee;
  }

  void selectPaymentMethod(String method) {
    selectedPaymentMethod.value = method;
  }

  void proceedToPay() {
    print(
      "Processing payment of ₹$totalAmount via ${selectedPaymentMethod.value}...",
    );

    // Route to the Success Screen
    Get.offNamed('/vendor-payment-confirmation');
  }
}
