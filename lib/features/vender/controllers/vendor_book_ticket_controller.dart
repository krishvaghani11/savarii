import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/firestore_service.dart';
import '../../auth/controllers/auth_controller.dart';

class VendorBookTicketController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  FirestoreService get _firestore => Get.find<FirestoreService>();
  AuthController get _auth => Get.find<AuthController>();

  final RxList<Map<String, dynamic>> availableBuses = <Map<String, dynamic>>[].obs;
  final RxnString selectedBusId = RxnString(null);

  // 1. Journey Details
  final RxList<Map<String, dynamic>> currentBoardingPoints = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> currentDroppingPoints = <Map<String, dynamic>>[].obs;
  
  final Rxn<Map<String, dynamic>> selectedBoardingPoint = Rxn<Map<String, dynamic>>();
  final Rxn<Map<String, dynamic>> selectedDroppingPoint = Rxn<Map<String, dynamic>>();

  final RxString journeyDate = ''.obs;

  final RxString departureTime = '--:--'.obs;
  final RxString arrivalTime = '--:--'.obs;
  final RxString journeyDuration = '--'.obs;

  // 2. Seat Selection State
  final RxString selectedDeck = 'LOWER DECK'.obs;
  final RxList<String> selectedSeats = <String>[].obs;
  final RxInt passengerCount = 0.obs; // Tracks the - / + counter

  // Array to hold already booked seats (fetched dynamically in the future, empty for now)
  final RxList<String> bookedSeats = <String>[].obs;

  final RxDouble pricePerSeat = 0.0.obs;

  // 3. Passenger Details
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final RxString selectedGender = 'Male'.obs;

  StreamSubscription? _busesSubscription;

  @override
  void onInit() {
    super.onInit();
    final now = DateTime.now();
    journeyDate.value = "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}";
    _fetchVendorBuses();
  }

  void _fetchVendorBuses() {
    final uid = _auth.uid;
    if (uid != null) {
      _busesSubscription = _firestore.getVendorBusesStream(uid).listen((buses) {
        final activeBuses = buses.where((b) => b['isActive'] == true).toList();
        availableBuses.assignAll(activeBuses);
        if (selectedBusId.value != null && !availableBuses.any((b) => b['id'] == selectedBusId.value)) {
          selectedBusId.value = null;
        }
      });
    }
  }

  void selectBus(String busId) {
    selectedBusId.value = busId;
    final bus = availableBuses.firstWhere((b) => b['id'] == busId, orElse: () => {});
    if (bus.isEmpty) return;

    // Load booked seats for the selected journey date from the date-keyed map
    _loadBookedSeatsForDate(bus);

    final Map<String, dynamic> route = bus['route'] ?? {};
    
    // Setup dynamic Boarding Points
    currentBoardingPoints.clear();
    final String mainFrom = route['from'] ?? 'Unknown Origin';
    final String mainDep = route['departureTime'] ?? '--:--';
    currentBoardingPoints.add({'pointName': '$mainFrom (Base)', 'time': mainDep, 'isMain': true});
    
    if (route['boardingPoints'] != null) {
      for (var point in route['boardingPoints']) {
        currentBoardingPoints.add({'pointName': point['pointName'] ?? 'Unknown', 'time': point['time'] ?? '--:--'});
      }
    }
    
    // Setup dynamic Dropping Points
    currentDroppingPoints.clear();
    final String mainTo = route['to'] ?? 'Unknown Destination';
    final String mainArr = route['arrivalTime'] ?? '--:--';
    currentDroppingPoints.add({'pointName': '$mainTo (Base)', 'time': mainArr, 'isMain': true});
    
    if (route['droppingPoints'] != null) {
      for (var point in route['droppingPoints']) {
        currentDroppingPoints.add({'pointName': point['pointName'] ?? 'Unknown', 'time': point['time'] ?? '--:--'});
      }
    }

    // Auto-select the base locations directly off jump
    selectBoardingPoint(currentBoardingPoints.first);
    selectDroppingPoint(currentDroppingPoints.first);
    
    // Parse price
    final pt = route['ticketPrice'] ?? 0;
    pricePerSeat.value = (pt is int) ? pt.toDouble() : (pt is double ? pt : double.tryParse(pt.toString()) ?? 0.0);

    // Clear seat selection if bus changes
    selectedSeats.clear();
    passengerCount.value = 0;
  }

  /// Reads booked seats for the current journeyDate from the date-keyed Firestore map.
  /// If the journeyDate is in the past, all seats are naturally unlocked (returns empty).
  void _loadBookedSeatsForDate(Map<String, dynamic> bus) {
    // Format date from dd/MM/yyyy -> dd-MM-yyyy (Firestore map key format)
    final formattedDate = journeyDate.value.replaceAll('/', '-');

    // Parse journeyDate to check if it's in the past
    try {
      final parts = journeyDate.value.split('/');
      if (parts.length == 3) {
        final jDate = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
        final today = DateTime.now();
        final todayMidnight = DateTime(today.year, today.month, today.day);
        if (jDate.isBefore(todayMidnight)) {
          // Journey is over — all seats unlocked
          bookedSeats.clear();
          return;
        }
      }
    } catch (_) {}

    final bookedSeatsByDate = bus['bookedSeatsByDate'] as Map<String, dynamic>? ?? {};
    final rawBooked = bookedSeatsByDate[formattedDate] as List<dynamic>? ?? [];
    bookedSeats.assignAll(rawBooked.map((s) => s.toString()).toList());
  }

  void selectBoardingPoint(Map<String, dynamic>? point) {
    if (point == null) return;
    selectedBoardingPoint.value = point;
    departureTime.value = point['time'] ?? '--:--';
    _calculateJourneyDuration(departureTime.value, arrivalTime.value);
  }

  void selectDroppingPoint(Map<String, dynamic>? point) {
    if (point == null) return;
    selectedDroppingPoint.value = point;
    arrivalTime.value = point['time'] ?? '--:--';
    _calculateJourneyDuration(departureTime.value, arrivalTime.value);
  }

  int _parseTimeStr(String timeStr) {
    bool isPM = timeStr.toLowerCase().contains('pm');
    bool isAM = timeStr.toLowerCase().contains('am');
    
    String cleanTime = timeStr.replaceAll(RegExp(r'[a-zA-Z\s]'), '');
    List<String> parts = cleanTime.split(':');
    if (parts.length != 2) return 0;
    
    int hours = int.tryParse(parts[0]) ?? 0;
    int minutes = int.tryParse(parts[1]) ?? 0;
    
    if (isPM && hours < 12) hours += 12;
    if (isAM && hours == 12) hours = 0;
    
    return (hours * 60) + minutes;
  }

  void _calculateJourneyDuration(String? depTime, String? arrTime) {
    if (depTime == null || arrTime == null || depTime == '--:--' || arrTime == '--:--') {
      journeyDuration.value = '--';
      return;
    }

    try {
      int startMins = _parseTimeStr(depTime);
      int endMins = _parseTimeStr(arrTime);

      if (endMins < startMins) {
        endMins += 24 * 60; // Next day arrival
      }

      int duration = endMins - startMins;
      int h = duration ~/ 60;
      int m = duration % 60;
      journeyDuration.value = "${h}h ${m}m";
    } catch (e) {
      print("Error parsing time: $e");
      journeyDuration.value = '--';
    }
  }

  // --- Methods ---

  void incrementPassenger() {
    passengerCount.value++;
  }

  void decrementPassenger() {
    if (passengerCount.value > 1) {
      passengerCount.value--;
    } else if (passengerCount.value == 1 && selectedSeats.isNotEmpty) {
      passengerCount.value--;
    } else if (passengerCount.value == 1) {
        passengerCount.value--;
    }
  }

  void setDeck(String deck) {
    selectedDeck.value = deck;
    selectedSeats.clear(); // Clear selections when switching decks to avoid confusion
  }

  void toggleSeat(String seatId) {
    if (bookedSeats.contains(seatId)) return; // Do nothing if booked

    if (selectedSeats.contains(seatId)) {
      selectedSeats.remove(seatId);
    } else {
      selectedSeats.add(seatId);
      if(passengerCount.value < selectedSeats.length){
          passengerCount.value = selectedSeats.length;
      }
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
            colorScheme: const ColorScheme.light(primary: Color(0xFFE82E59)), // Brand Red
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      journeyDate.value = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";

      // Refresh booked seats for the newly selected date
      if (selectedBusId.value != null) {
        final bus = availableBuses.firstWhere((b) => b['id'] == selectedBusId.value, orElse: () => {});
        if (bus.isNotEmpty) _loadBookedSeatsForDate(bus);
      }
      // Clear previously selected seats since the date changed
      selectedSeats.clear();
      passengerCount.value = 0;
    }
  }

  void confirmBooking() {
    if (selectedSeats.isEmpty) {
      Get.snackbar(
        'Select a Seat',
        'Please select at least one seat to continue.',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }
    
    if (selectedBusId.value == null) {
      Get.snackbar(
        'Select Route',
        'Please select a bus/route before continuing.',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    if (formKey.currentState!.validate()) {
      final bus = availableBuses.firstWhere((b) => b['id'] == selectedBusId.value, orElse: () => {});
      final busName = bus['busName'] ?? 'Unknown Bus';
      String busImage = '';
      if (bus['imageUrls'] != null && bus['imageUrls'] is List && bus['imageUrls'].isNotEmpty) {
        busImage = bus['imageUrls'][0]?.toString() ?? '';
      }

      final payload = {
        'busId': selectedBusId.value ?? '',
        'busName': busName,
        'busImage': busImage,
        'boardingPoint': selectedBoardingPoint.value?['pointName'] ?? 'Unknown Origin',
        'droppingPoint': selectedDroppingPoint.value?['pointName'] ?? 'Unknown Destination',
        'journeyDate': journeyDate.value,
        'departureTime': departureTime.value,
        'passengerName': nameController.text.trim(),
        'passengerPhone': phoneController.text.trim(),
        'selectedSeats': selectedSeats.join(', '),
        'totalBaseFare': selectedSeats.length * pricePerSeat.value,
      };

      print("Proceeding to payment for ${nameController.text} with payload: $payload");
      Get.toNamed('/vendor-payment-details', arguments: payload);
    }
  }

  @override
  void onClose() {
    _busesSubscription?.cancel();
    nameController.dispose();
    phoneController.dispose();
    super.onClose();
  }
}