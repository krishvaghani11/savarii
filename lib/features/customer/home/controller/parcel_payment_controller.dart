import 'package:get/get.dart';

class ParcelPaymentController extends GetxController {
  // Dummy Delivery Data (Matches the screenshot)
  final String orderId = '#SAV-89203';
  final String pickupLocation = 'Downtown Bus Terminal';
  final String pickupTime = 'Today, 10:00 AM';
  final String dropoffLocation = 'Sector 42, Gurgaon';
  final String dropoffTime = 'Today, 02:30 PM';
  
  final String estimatedPickupTime = 'Today, 10:30 AM';
  final String estimatedDropoffTime = 'Today, 03:00 PM';

  // Dummy Bus & Driver Data
  final String busName = 'Savarii Express';
  final String busNumber = 'GJ 01 SV 1234';
  final String driverName = 'Rajesh Kumar';
  final String driverPhone = '+91 98765 43210';

  // Pricing Data
  final double baseFare = 450.00;
  final double weightSurcharge = 120.00;
  final double serviceFee = 45.00;
  final double tax = 32.50;

  // Reactive Total
  late RxDouble totalAmount;

  @override
  void onInit() {
    super.onInit();
    totalAmount = (baseFare + weightSurcharge + serviceFee + tax).obs;
  }

  void helpAction() {
    print("Opening Help & Support...");
  }

  void callDriver() {
    // Implement launchUrl logic to open phone dialer
    print("Calling driver at $driverPhone...");
    Get.snackbar('Calling Driver', 'Initiating call to $driverName...', snackPosition: SnackPosition.BOTTOM);
  }

  void payNow() {
    print("Processing Payment of ₹${totalAmount.value}...");
    // Navigate to confirmation or payment gateway
    Get.toNamed('/parcel-confirmation'); 
  }
}