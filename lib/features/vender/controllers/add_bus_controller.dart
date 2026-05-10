import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/services/city_geolocation_service.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../routes/app_routes.dart';
import '../../../models/seat_model.dart';

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
    fetchVendorDrivers();
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
        departureTime.value = route['departureTime'] ?? '--:-- --';
        arrivalTime.value   = route['arrivalTime']   ?? '--:-- --';

        // Restore canonical city selections from stored strings
        final fromStr = route['from'] as String? ?? '';
        final toStr   = route['to']   as String? ?? '';
        if (fromStr.isNotEmpty) {
          selectedFromCity.value = CitySuggestion.fromCanonicalString(fromStr);
        }
        if (toStr.isNotEmpty) {
          selectedToCity.value = CitySuggestion.fromCanonicalString(toStr);
        }

        final driver = data['driver'] as Map<String, dynamic>? ?? {};
        driverNameController.text   = driver['name']          ?? '';
        driverMobileController.text = driver['mobile']        ?? '';
        driverEmailController.text  = driver['email']         ?? '';
        licenseController.text      = driver['licenseNumber'] ?? '';

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

        if (data['layoutConfig'] != null) {
          layoutConfig.value = BusLayoutConfig.fromMap(
              data['layoutConfig'] as Map<String, dynamic>);
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
  final TextEditingController driverNameController = TextEditingController();
  final TextEditingController driverMobileController = TextEditingController();
  final TextEditingController driverEmailController = TextEditingController();
  final TextEditingController licenseController = TextEditingController();

  // --- Route Cities (canonical "City, District, State" via autocomplete) ---
  final Rxn<CitySuggestion> selectedFromCity = Rxn<CitySuggestion>();
  final Rxn<CitySuggestion> selectedToCity = Rxn<CitySuggestion>();

  // Reactive States
  final RxString selectedBusType = 'AC Sleeper'.obs;
  final RxString departureTime = '--:-- --'.obs;
  final RxString arrivalTime = '--:-- --'.obs;

  // Boarding Point Inputs
  final Rxn<CitySuggestion> selectedBpCity = Rxn<CitySuggestion>();
  final RxString bpTime = '--:-- --'.obs;
  final RxList<Map<String, String>> savedBoardingPoints = <Map<String, String>>[].obs;

  // Dropping Point Inputs
  final Rxn<CitySuggestion> selectedDpCity = Rxn<CitySuggestion>();
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

  final RxList<Map<String, dynamic>> vendorDrivers = <Map<String, dynamic>>[].obs;
  final RxString selectedDriverId = ''.obs;
  final RxBool isDriversLoading = false.obs;

  final Rx<BusLayoutConfig?> layoutConfig = Rx<BusLayoutConfig?>(null);

  StreamSubscription<List<Map<String, dynamic>>>? _driversSubscription;

  void fetchVendorDrivers() {
    final uid = _auth.uid ?? FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      print("AddBusController: Cannot fetch drivers — UID is null.");
      return;
    }

    isDriversLoading.value = true;
    print("Listening to drivers stream for Vendor: $uid...");

    // Cancel any previous subscription before starting a new one
    _driversSubscription?.cancel();

    _driversSubscription = FirebaseFirestore.instance
        .collection('drivers')
        .where('vendorId', isEqualTo: uid)
        .snapshots()
        .map((snapshot) {
          final allDocs = snapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList();
          // Filter out deleted drivers (matches driver management screen logic)
          return allDocs
              .where((d) =>
                  d['status'] != 'REMOVED' &&
                  d['status'] != 'driver deleted')
              .toList();
        })
        .listen(
          (activeDocs) {
            vendorDrivers.assignAll(activeDocs);
            isDriversLoading.value = false;
            print("AddBus driver stream updated: ${vendorDrivers.length} active drivers.");

            // If the previously selected driver was deleted, clear the selection
            if (selectedDriverId.value.isNotEmpty &&
                !vendorDrivers.any((d) => d['id'] == selectedDriverId.value)) {
              selectedDriverId.value = '';
              driverNameController.clear();
              driverMobileController.clear();
              driverEmailController.clear();
              licenseController.clear();
              print("Selected driver was removed — cleared driver fields.");
            }
          },
          onError: (e) {
            print("Error in AddBus drivers stream: $e");
            isDriversLoading.value = false;
          },
        );
  }

  void onDriverSelected(String? driverId) {
    if (driverId == null || driverId.isEmpty) return;
    
    selectedDriverId.value = driverId;
    final driver = vendorDrivers.firstWhereOrNull((d) => d['id'] == driverId);
    
    if (driver != null) {
      print("Selected driver confirmed in controller: ${driver['name']}");
      driverNameController.text = driver['name'] ?? '';
      driverMobileController.text = driver['phone'] ?? '';
      driverEmailController.text = driver['email'] ?? '';
      licenseController.text = driver['dlNumber'] ?? '';
    }
  }

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
    if (selectedBpCity.value == null || bpTime.value == '--:-- --') {
      Get.snackbar(
        'Incomplete Details',
        'Please select a boarding city from suggestions and pick a time.',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    savedBoardingPoints.add({
      'pointName': selectedBpCity.value!.fullName,
      'time': bpTime.value,
    });

    selectedBpCity.value = null;
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
    if (selectedDpCity.value == null || dpTime.value == '--:-- --') {
      Get.snackbar(
        'Incomplete Details',
        'Please select a dropping city from suggestions and pick a time.',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    savedDroppingPoints.add({
      'pointName': selectedDpCity.value!.fullName,
      'time': dpTime.value,
    });

    selectedDpCity.value = null;
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
        snackPosition: SnackPosition.TOP,
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
    // Auto-flush pending boarding / dropping point if city+time are filled
    if (selectedBpCity.value != null && bpTime.value != '--:-- --') {
      addBoardingPoint();
    }
    if (selectedDpCity.value != null && dpTime.value != '--:-- --') {
      addDroppingPoint();
    }
    if (rsNameController.text.trim().isNotEmpty &&
        rsDurationController.text.trim().isNotEmpty) {
      addRestStop();
    }

    // Validate canonical city selections
    if (selectedFromCity.value == null || selectedToCity.value == null) {
      Get.snackbar(
        'Location Required',
        'Please select valid From and To cities from the suggestions.',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    if (!formKey.currentState!.validate()) {
      Get.snackbar(
        "Incomplete Form",
        "Please fill in all required fields highlighted in red.",
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    if (departureTime.value == '--:-- --' ||
        arrivalTime.value == '--:-- --') {
      Get.snackbar(
        "Time Required",
        "Please select both departure & arrival time.",
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    if (savedBoardingPoints.isEmpty) {
      Get.snackbar(
        "Boarding Point Required",
        "Please add at least one boarding point.",
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    if (savedDroppingPoints.isEmpty) {
      Get.snackbar(
        "Dropping Point Required",
        "Please add at least one dropping point.",
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    if (layoutConfig.value == null) {
      Get.snackbar(
        "Layout Required",
        "Please configure the bus layout and set seat prices before saving.",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange.shade50,
        colorText: Colors.orange.shade900,
      );
      return;
    }

    final seats = int.tryParse(totalSeatsController.text.trim());
    if (seats == null) {
      Get.snackbar("Invalid Input", "Total seats must be a valid number.");
      return;
    }

    try {
      isLoading.value = true;

      // Use AuthController's UID with a fallback to Firebase Auth instance for robustness
      final uid = _auth.uid ?? FirebaseAuth.instance.currentUser?.uid;
      print("AddBusController: Attempting to save bus with UID: $uid");

      if (uid == null || uid.isEmpty) {
        Get.snackbar(
          "Session Missing",
          "Could not identify your vendor account. Please try logging in again.",
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 4),
        );
        isLoading.value = false;
        return;
      }

      // VALIDATE DRIVER ASSIGNMENT
      final mobileInfo = driverMobileController.text.trim();

      final QuerySnapshot driverQuery = await FirebaseFirestore.instance
          .collection('drivers')
          .where('vendorId', isEqualTo: uid)
          .where('phone', isEqualTo: mobileInfo)
          // Also optionally check license if provided, but phone is usually unique
          .get();

      String assignedDriverId = '';
      if (driverQuery.docs.isEmpty) {
         Get.snackbar(
           'Driver Not Found', 
           'No driver matched with this Mobile number in your fleet. Please add the Driver in the Management section first.',
           snackPosition: SnackPosition.TOP,
           duration: const Duration(seconds: 4),
         );
         isLoading.value = false;
         return;
      }
      assignedDriverId = driverQuery.docs.first.id;

      final busData = {
        // BUS DETAILS
        "vendorId": uid,
        "busName": busNameController.text.trim(),
        "busNumber": busNumberController.text.trim(),
        "totalSeats": seats,

        // BUS TYPE
        "busType": selectedBusType.value,

        // ROUTE — canonical "City, District, State" strings
        "route": {
          "from": selectedFromCity.value!.fullName,
          "to":   selectedToCity.value!.fullName,
          "departureTime": departureTime.value,
          "arrivalTime":   arrivalTime.value,
          "boardingPoints": savedBoardingPoints.toList(),
          "droppingPoints": savedDroppingPoints.toList(),
          "restStops": savedRestStops.toList(),
        },

        // DRIVER
        "driver": {
          "driverId": assignedDriverId,
          "name": driverNameController.text.trim(),
          "mobile": driverMobileController.text.trim(),
          "email": driverEmailController.text.trim(),
          "licenseNumber": licenseController.text.trim(),
        },

        if (layoutConfig.value != null) "layoutConfig": layoutConfig.value!.toMap(),

        // SYSTEM
        "isActive": true,
        "createdAt": DateTime.now().toIso8601String(),
      };

      if (isEditing.value && editBusId != null) {
        busData.remove('isActive');
        busData.remove('createdAt');
        await _firestore.updateBusData(editBusId!, busData);
      } else {
        await _firestore.addBusData(busData);
      }

      Get.snackbar(
        'Success',
        isEditing.value ? 'Bus updated successfully!' : 'Bus added successfully!',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      Future.delayed(const Duration(milliseconds: 500), () {
        Get.offAllNamed(AppRoutes.vendorMain);
      });
    } catch (e) {
      Get.snackbar(
        "Save Failed",
        e.toString(),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade800,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    _driversSubscription?.cancel();
    busNameController.dispose();
    busNumberController.dispose();
    totalSeatsController.dispose();
    driverNameController.dispose();
    driverMobileController.dispose();
    driverEmailController.dispose();
    licenseController.dispose();
    rsNameController.dispose();
    rsDurationController.dispose();
    super.onClose();
  }
}