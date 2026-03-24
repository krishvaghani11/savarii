import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/firestore_service.dart';
import '../../auth/controllers/auth_controller.dart';

class AddBusController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// SERVICES — resolved lazily to always get the live permanent singleton
  FirestoreService get _firestore => Get.find<FirestoreService>();
  AuthController get _auth => Get.find<AuthController>();

  /// LOADING STATE
  final RxBool isLoading = false.obs;

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

  // --- Controllers and Lists for dynamic form inputs ---

  // Boarding Point Inputs
  final TextEditingController bpNameController = TextEditingController();
  final RxString bpTime = '--:-- --'.obs;
  final RxList<Map<String, String>> savedBoardingPoints =
      <Map<String, String>>[].obs;

  // Rest Stop Inputs
  final TextEditingController rsNameController = TextEditingController();
  final TextEditingController rsDurationController = TextEditingController();
  final RxList<Map<String, String>> savedRestStops =
      <Map<String, String>>[].obs;

  final List<String> busTypes = [
    'AC Sleeper',
    'Non-AC Sleeper',
    'AC Seater',
    'Non-AC Seater',
    'Luxury',
  ];

  // ─── Validators (used by the Form) ───────────────────────────────────────

  String? validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) return 'This field is required';
    return null;
  }

  String? validateNumber(String? value) {
    if (value == null || value.trim().isEmpty) return 'This field is required';
    if (int.tryParse(value.trim()) == null) return 'Enter a valid number';
    return null;
  }

  // ─── Bus Type ────────────────────────────────────────────────────────────

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

  /// ===============================
  /// SAVE BUS + ROUTE (MAIN LOGIC)
  /// ===============================
  Future<void> saveBusAndRoute() async {
    // 1️⃣ Form validation (all required fields must pass their validators)
    if (!formKey.currentState!.validate()) {
      Get.snackbar(
        "Incomplete Form",
        "Please fill in all required fields highlighted in red.",
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    // 2️⃣ Time validation — these are NOT in the Form so check separately
    if (departureTime.value == '--:-- --' ||
        arrivalTime.value == '--:-- --') {
      Get.snackbar(
        "Time Required",
        "Please select both departure & arrival time.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // 3️⃣ Safe parse of numeric fields
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

      // 4️⃣ Auth check — uid is persisted to SharedPreferences so survives cold starts
      final uid = _auth.uid;
      debugPrint('🚌 [AddBus] uid at save time: $uid');

      if (uid == null || uid.isEmpty) {
        Get.snackbar(
          "Session Expired",
          "Please login again to add a bus.",
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 4),
        );
        return;
      }

      // 5️⃣ Build the Firestore document
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

      debugPrint('🚌 [AddBus] Saving to Firestore: $busData');

      // 6️⃣ Write to Firestore
      await _firestore.addBusData(busData);

      debugPrint('✅ [AddBus] Bus saved successfully!');

      Get.snackbar(
        'Success',
        'Bus added successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade50,
        colorText: Colors.green.shade800,
        duration: const Duration(seconds: 3),
      );

      Get.back();
    } catch (e, stack) {
      debugPrint('❌ [AddBus] Error saving bus: $e');
      debugPrint('❌ [AddBus] Stack: $stack');
      Get.snackbar(
        "Save Failed",
        e.toString().length > 100 ? e.toString().substring(0, 100) : e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
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
    rsNameController.dispose();
    rsDurationController.dispose();
    super.onClose();
  }
}
