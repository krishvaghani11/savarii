import 'package:get/get.dart';

class CustomerSelectPointsController extends GetxController {
  
  // Passed Arguments
  String busId = '';
  String busName = '';
  String journeyDate = '';
  double seatPrice = 0.0;
  List<String> selectedSeats = [];
  String vendorId = '';

  // Reactive states for the selected points
  final RxString selectedBoardingPoint = 'Choose location'.obs;
  final RxString selectedDroppingPoint = 'Choose location'.obs;

  // Dynamic dropdown lists
  final RxList<String> boardingPoints = <String>['Choose location'].obs;
  final RxList<String> droppingPoints = <String>['Choose location'].obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      final args = Get.arguments as Map<String, dynamic>;
      busId = args['busId'] ?? '';
      busName = args['busName'] ?? '';
      journeyDate = args['journeyDate'] ?? '';
      seatPrice = args['seatPrice'] ?? 0.0;
      selectedSeats = List<String>.from(args['selectedSeats'] ?? []);
      vendorId = args['vendorId'] ?? '';
      
      final bpData = args['boardingPointsData'] as List<dynamic>? ?? [];
      final dpData = args['droppingPointsData'] as List<dynamic>? ?? [];

      for (var bp in bpData) {
        if (bp is Map) {
          final pt = bp['pointName']?.toString() ?? '';
          final tm = bp['time']?.toString() ?? '';
          if (pt.isNotEmpty) {
            boardingPoints.add('$pt - $tm');
          }
        }
      }

      for (var dp in dpData) {
        if (dp is Map) {
          final pt = dp['pointName']?.toString() ?? '';
          final tm = dp['time']?.toString() ?? '';
          if (pt.isNotEmpty) {
            droppingPoints.add('$pt - $tm');
          }
        }
      }
    }
  }

  /// Extracts the time portion from a boarding point string.
  /// Format: "City Name - HH:MM AM/PM"  →  "HH:MM AM/PM"
  String _extractTimeFromPoint(String point) {
    final parts = point.split(' - ');
    if (parts.length >= 2) return parts.last.trim();
    return '';
  }

  void confirmPoints() {
    if (selectedBoardingPoint.value == 'Choose location') {
      Get.snackbar(
        'Missing Boarding Point',
        'Please select a boarding location to continue.',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    if (selectedDroppingPoint.value == 'Choose location') {
      Get.snackbar(
        'Missing Dropping Point',
        'Please select a dropping location to continue.',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    print("Navigating to Payment Details with Boarding: ${selectedBoardingPoint.value} and Dropping: ${selectedDroppingPoint.value}");
    
    Get.toNamed('/customer-add-passenger', arguments: {
      'busId': busId,
      'busName': busName,
      'journeyDate': journeyDate,
      'seatPrice': seatPrice,
      'selectedSeats': selectedSeats,
      'boardingPoint': selectedBoardingPoint.value,
      'droppingPoint': selectedDroppingPoint.value,
      'vendorId': vendorId,
      // Extract "HH:MM AM/PM" from "City - HH:MM AM/PM"
      'departureTime': _extractTimeFromPoint(selectedBoardingPoint.value),
    });
  }
}