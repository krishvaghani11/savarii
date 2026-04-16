import 'package:get/get.dart';

class DriverHomeController extends GetxController {
  
  // Driver Details
  final String driverName = "Rajesh";
  
  // State for Shift
  final RxBool isOnline = false.obs;

  // Mock Bus Data
  final String busName = "Bharat Benz A/C\nSleeper";
  final String busNumber = "GJ 01 AA 1234";
  
  final String startLocation = "Ahmedabad";
  final String startTime = "08:00 PM";
  
  final String endLocation = "Palitana";
  final String endTime = "04:30 AM";

  final String reportingTime = "07:30 PM Today";
  final String vendorName = "Royal Travels\nCo.";

  // Mock Driver Stats
  final String lastTrip = "Surat to Ahmedabad";
  final String driverScore = "4.9 / 5.0";

  void toggleStatus() {
    isOnline.value = !isOnline.value;
    if (isOnline.value) {
      Get.snackbar(
        'Shift Started',
        'You are now online and your bus is active.',
        snackPosition: SnackPosition.TOP,
      );
    } else {
      Get.snackbar(
        'Shift Ended',
        'You are now offline.',
        snackPosition: SnackPosition.TOP,
      );
    }
  }
}