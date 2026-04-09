import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/firestore_service.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../routes/app_routes.dart';

class AddBusController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// SERVICES
  FirestoreService get _firestore => Get.find<FirestoreService>();
  AuthController get _auth => Get.find<AuthController>();

  /// LOADING STATE
  final RxBool isLoading = false.obs;

  String? editBusId;
  final RxBool isEditing = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null && Get.arguments['busId'] != null) {
      editBusId = Get.arguments['busId'];
      isEditing.value = true;
      _loadBusData(editBusId!);
    }
  }

  Future<void> _loadBusData(String busId) async {
    isLoading.value = true;
    try {
      final data = await _firestore.getBusById(busId);
      if (data != null) {
        busNameController.text = data['busName'] ?? '';
        busNumberController.text = data['busNumber'] ?? '';
        totalSeatsController.text = (data['totalSeats'] ?? '').toString();
        selectedBusType.value = data['busType'] ?? 'AC Sleeper';
        
        final route = data['route'] as Map<String, dynamic>? ?? {};
        fromController.text = route['from'] ?? '';
        toController.text = route['to'] ?? '';
        departureTime.value = route['departureTime'] ?? '--:-- --';
        arrivalTime.value = route['arrivalTime'] ?? '--:-- --';
        priceController.text = (route['ticketPrice'] ?? '').toString();

        final driver = data['driver'] as Map<String, dynamic>? ?? {};
        driverNameController.text = driver['name'] ?? '';
        driverMobileController.text = driver['mobile'] ?? '';
        licenseController.text = driver['licenseNumber'] ?? '';

        if (route['boardingPoints'] != null) {
          final List<dynamic> bps = route['boardingPoints'];
          savedBoardingPoints.assignAll(bps.map((e) {
            final map = e as Map<dynamic, dynamic>;
            return {
              'pointName': map['pointName']?.toString() ?? '',
              'time': map['time']?.toString() ?? '',
            };
          }).toList());
        }
        
        // Load dropping points if they exist
        if (route['droppingPoints'] != null) {
          final List<dynamic> dps = route['droppingPoints'];
          savedDroppingPoints.assignAll(dps.map((e) {
            final map = e as Map<dynamic, dynamic>;
            return {
              'pointName': map['pointName']?.toString() ?? '',
              'time': map['time']?.toString() ?? '',
            };
          }).toList());
        }
        
        if (route['restStops'] != null) {
          final List<dynamic> rss = route['restStops'];
          savedRestStops.assignAll(rss.map((e) {
            final map = e as Map<dynamic, dynamic>;
            return {
              'stopName': map['stopName']?.toString() ?? '',
              'duration': map['duration']?.toString() ?? '',
            };
          }).toList());
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load bus details');
    } finally {
      isLoading.value = false;
    }
  }

  // Text Controllers
  final TextEditingController busNameController = TextEditingController();
  final TextEditingController busNumberController = TextEditingController();
  final TextEditingController totalSeatsController = TextEditingController();
  final TextEditingController fromController = TextEditingController();
  final TextEditingController toController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController driverNameController = TextEditingController();
  final TextEditingController driverMobileController = TextEditingController();
  final TextEditingController licenseController = TextEditingController();

  // Reactive States
  final RxString selectedBusType = 'AC Sleeper'.obs;
  final RxString departureTime = '--:-- --'.obs;
  final RxString arrivalTime = '--:-- --'.obs;

  // Boarding Point Inputs
  final TextEditingController bpNameController = TextEditingController();
  final RxString bpTime = '--:-- --'.obs;
  final RxList<Map<String, String>> savedBoardingPoints = <Map<String, String>>[].obs;

  // NEW: Dropping Point Inputs
  final TextEditingController dpNameController = TextEditingController();
  final RxString dpTime = '--:-- --'.obs;
  final RxList<Map<String, String>> savedDroppingPoints = <Map<String, String>>[].obs;

  // Rest Stop Inputs
  final TextEditingController rsNameController = TextEditingController();
  final TextEditingController rsDurationController = TextEditingController();
  final RxList<Map<String, String>> savedRestStops = <Map<String, String>>[].obs;

  final List<String> busTypes = [
    'AC Sleeper',
    'Non-AC Sleeper',
    'AC Seater',
    'Non-AC Seater',
    'Luxury',
  ];

  // ─── Validators ────────────────────────────────────────────────────────

  String? validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) return 'This field is required';
    return null;
  }

  String? validateNumber(String? value) {
    if (value == null || value.trim().isEmpty) return 'This field is required';
    if (int.tryParse(value.trim()) == null) return 'Enter a valid number';
    return null;
  }

  void selectBusType(String type) {
    selectedBusType.value = type;
  }

  /// BOARDING POINT LOGIC
  void addBoardingPoint() {
    if (bpNameController.text.trim().isEmpty || bpTime.value == '--:-- --') {
      Get.snackbar(
        'Incomplete Details',
        'Please enter both the boarding point name and time before adding.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    savedBoardingPoints.add({
      'pointName': bpNameController.text.trim(),
      'time': bpTime.value,
    });

    bpNameController.clear();
    bpTime.value = '--:-- --';
  }

  void removeBoardingPoint(int index) {
    savedBoardingPoints.removeAt(index);
  }

  Future<void> pickBpTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFFE82E59)),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final localizations = MaterialLocalizations.of(context);
      bpTime.value = localizations.formatTimeOfDay(
        picked,
        alwaysUse24HourFormat: false,
      );
    }
  }

  /// DROPPING POINT LOGIC
  void addDroppingPoint() {
    if (dpNameController.text.trim().isEmpty || dpTime.value == '--:-- --') {
      Get.snackbar(
        'Incomplete Details',
        'Please enter both the dropping point name and time before adding.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    savedDroppingPoints.add({
      'pointName': dpNameController.text.trim(),
      'time': dpTime.value,
    });

    dpNameController.clear();
    dpTime.value = '--:-- --';
  }

  void removeDroppingPoint(int index) {
    savedDroppingPoints.removeAt(index);
  }

  Future<void> pickDpTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFFE82E59)),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final localizations = MaterialLocalizations.of(context);
      dpTime.value = localizations.formatTimeOfDay(
        picked,
        alwaysUse24HourFormat: false,
      );
    }
  }

  /// REST STOP LOGIC
  void addRestStop() {
    if (rsNameController.text.trim().isEmpty ||
        rsDurationController.text.trim().isEmpty) {
      Get.snackbar(
        'Incomplete Details',
        'Please enter the rest stop name and duration before adding.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    savedRestStops.add({
      'stopName': rsNameController.text.trim(),
      'duration': rsDurationController.text.trim(),
    });

    rsNameController.clear();
    rsDurationController.clear();
  }

  void removeRestStop(int index) {
    savedRestStops.removeAt(index);
  }

  /// TIME PICKER (MAIN ROUTE)
  Future<void> pickTime(BuildContext context, bool isDeparture) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFFE82E59)),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final localizations = MaterialLocalizations.of(context);
      final formattedTime = localizations.formatTimeOfDay(
        picked,
        alwaysUse24HourFormat: false,
      );

      if (isDeparture) {
        departureTime.value = formattedTime;
      } else {
        arrivalTime.value = formattedTime;
      }
    }
  }

  /// SAVE BUS + ROUTE
  Future<void> saveBusAndRoute() async {
    // Auto-flush ghost text into arrays
    if (bpNameController.text.trim().isNotEmpty && bpTime.value != '--:-- --') {
      addBoardingPoint();
    }
    if (dpNameController.text.trim().isNotEmpty && dpTime.value != '--:-- --') {
      addDroppingPoint();
    }
    if (rsNameController.text.trim().isNotEmpty && rsDurationController.text.trim().isNotEmpty) {
      addRestStop();
    }

    if (!formKey.currentState!.validate()) {
      Get.snackbar(
        "Incomplete Form",
        "Please fill in all required fields highlighted in red.",
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    if (departureTime.value == '--:-- --' ||
        arrivalTime.value == '--:-- --') {
      Get.snackbar(
        "Time Required",
        "Please select both departure & arrival time.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (savedBoardingPoints.isEmpty) {
      Get.snackbar(
        "Boarding Point Required",
        "Please add at least one boarding point.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (savedDroppingPoints.isEmpty) {
      Get.snackbar(
        "Dropping Point Required",
        "Please add at least one dropping point.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final seats = int.tryParse(totalSeatsController.text.trim());
    if (seats == null) {
      Get.snackbar("Invalid Input", "Total seats must be a valid number.");
      return;
    }

    final price = int.tryParse(priceController.text.trim());
    if (price == null) {
      Get.snackbar("Invalid Input", "Ticket price must be a valid number.");
      return;
    }

    try {
      isLoading.value = true;

      final uid = _auth.uid;

      if (uid == null || uid.isEmpty) {
        Get.snackbar(
          "Session Expired",
          "Please login again to add a bus.",
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 4),
        );
        return;
      }

      final busData = {
        // BUS DETAILS
        "vendorId": uid,
        "busName": busNameController.text.trim(),
        "busNumber": busNumberController.text.trim(),
        "totalSeats": seats,

        // BUS TYPE
        "busType": selectedBusType.value,

        // ROUTE
        "route": {
          "from": fromController.text.trim(),
          "to": toController.text.trim(),
          "departureTime": departureTime.value,
          "arrivalTime": arrivalTime.value,
          "ticketPrice": price,
          "boardingPoints": savedBoardingPoints.toList(),
          "droppingPoints": savedDroppingPoints.toList(), // ADDED HERE
          "restStops": savedRestStops.toList(),
        },

        // DRIVER
        "driver": {
          "name": driverNameController.text.trim(),
          "mobile": driverMobileController.text.trim(),
          "licenseNumber": licenseController.text.trim(),
        },

        // SYSTEM
        "isActive": true,
        "createdAt": DateTime.now().toIso8601String(),
      };

      if (isEditing.value && editBusId != null) {
        busData.remove('isActive');
        busData.remove('createdAt');
        
        await _firestore.updateBusData(editBusId!, busData);
        Get.snackbar(
          'Success',
          'Bus updated successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade50,
          colorText: Colors.green.shade800,
        );
      } else {
        await _firestore.addBusData(busData);
        Get.snackbar(
          'Success',
          'Bus added successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade50,
          colorText: Colors.green.shade800,
        );
      }

      Get.offAllNamed(AppRoutes.vendorMain);
    } catch (e) {
      Get.snackbar(
        "Save Failed",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade800,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    busNameController.dispose();
    busNumberController.dispose();
    totalSeatsController.dispose();
    fromController.dispose();
    toController.dispose();
    priceController.dispose();
    driverNameController.dispose();
    driverMobileController.dispose();
    licenseController.dispose();
    
    bpNameController.dispose();
    dpNameController.dispose(); // NEW
    rsNameController.dispose();
    rsDurationController.dispose();
    super.onClose();
  }
}