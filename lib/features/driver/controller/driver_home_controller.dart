import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:savarii/core/services/location_service.dart';
import 'package:savarii/features/auth/controllers/auth_controller.dart';
import 'package:savarii/core/services/driver_tracking_service.dart';

class DriverHomeController extends GetxController {
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthController _authController = Get.find<AuthController>();
  final DriverTrackingService _trackingService = Get.find<DriverTrackingService>();

  // Driver Details State
  final RxString rxDriverName = "Loading...".obs;
  
  // State for Shift
  final RxBool isOnline = false.obs;

  // Reactivity checks
  final RxBool hasBusAssigned = false.obs;
  final RxBool isLoading = true.obs;

  // Bus Details State
  final RxString rxBusName = "".obs;
  final RxString rxBusNumber = "".obs;
  
  final RxString rxStartLocation = "".obs;
  final RxString rxStartTime = "".obs;
  
  final RxString rxEndLocation = "".obs;
  final RxString rxEndTime = "".obs;

  // Store the raw bus data to pass to the detail screen
  Map<String, dynamic>? activeBusData;

  // Since we don't have explicit reporting time, using departure as proxy or static mock
  final RxString rxReportingTime = "".obs;
  final RxString rxVendorName = "Savarii Verified Vendor".obs; // Can be replaced by actual vendor fetch

  // Last trip info — fetched from tickets collection
  final RxString lastTrip = "N/A".obs;

  @override
  void onInit() {
    super.onInit();
    _bindDriverAndBus();
    // Check location permission after the first frame is drawn.
    // Drivers MUST have location — dialog is non-dismissable.
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkLocationPermission());
  }

  /// Silently checks location permission status.
  /// Shows a non-dismissable compact dialog for drivers — they need GPS to work.
  Future<void> _checkLocationPermission() async {
    final locationService = Get.find<LocationService>();

    // If GPS is off, prompt to enable it.
    final gpsEnabled = await locationService.isGpsEnabled();
    if (!gpsEnabled) {
      await locationService.showLocationPermissionDialog(
        isDeniedForever: false,
        isDriverRole: true,
      );
      return;
    }

    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      await locationService.showLocationPermissionDialog(
        isDeniedForever: true,
        isDriverRole: true,
      );
    } else if (permission == LocationPermission.denied) {
      await locationService.showLocationPermissionDialog(
        isDeniedForever: false,
        isDriverRole: true,
      );
    }
    // If whileInUse or always — do nothing, location is fine.
  }

  Future<void> _bindDriverAndBus() async {
    final String? uid = _authController.uid;
    if (uid == null) {
      isLoading.value = false;
      return;
    }

    try {
      // 1. Fetch current driver document to secure mobile parameter and initial status
      final driverDoc = await _firestore.collection('drivers').doc(uid).get();
      if (!driverDoc.exists) {
        isLoading.value = false;
        return;
      }

      final driverData = driverDoc.data()!;
      rxDriverName.value = driverData['name'] ?? 'Driver';
      final String driverMobile = driverData['phone'] ?? '';
      
      // Map existing driver status dynamically to the shift toggle
      final currentStatus = driverData['status'] ?? 'ACTIVE';
      if (currentStatus == 'ON TRIP') {
        isOnline.value = true;
      }

      // 2. Stream the master buses collection matching the secure driver mobile parameter
      _firestore
          .collection('buses')
          .where('driver.mobile', isEqualTo: driverMobile)
          .snapshots()
          .listen((snapshot) {
            
        if (snapshot.docs.isNotEmpty) {
          // Bus mapping confirmed
          hasBusAssigned.value = true;
          
          final busDoc = snapshot.docs.first;
          final busData = busDoc.data();
          busData['id'] = busDoc.id; // Inject ID for tracking
          activeBusData = busData;
          rxBusName.value = busData['busName'] ?? 'Unknown Bus';
          rxBusNumber.value = busData['busNumber'] ?? 'N/A';
          
          final routeData = busData['route'] as Map<String, dynamic>? ?? {};
          rxStartLocation.value = routeData['from'] ?? 'N/A';
          rxEndLocation.value = routeData['to'] ?? 'N/A';
          rxStartTime.value = routeData['departureTime'] ?? '--:--';
          rxEndTime.value = routeData['arrivalTime'] ?? '--:--';

          rxReportingTime.value = "${rxStartTime.value} Today";
          isLoading.value = false;

          // Optionally, verify vendor name mapping
          final vendorId = busData['vendorId'];
          if (vendorId != null) {
            _fetchVendorName(vendorId);
          }

          // Fetch last trip info for this driver
          _fetchLastTrip(driverMobile);

          // If the driver is already ON TRIP from a previous session, start tracking immediately
          if (isOnline.value) {
            _trackingService.startTracking(busDoc.id);
          }
        } else {
          // No bus mapped to mobile!
           hasBusAssigned.value = false;
           isLoading.value = false;
        }
      });
    } catch (e) {
      print("Error binding driver and bus details: $e");
      isLoading.value = false;
    }
  }

  Future<void> _fetchVendorName(String vendorId) async {
    try {
      final vendorDoc = await _firestore.collection('vendors').doc(vendorId).get();
      if (vendorDoc.exists) {
        final vd = vendorDoc.data()!;
        rxVendorName.value = vd['businessName'] ?? vd['name'] ?? "Vendor";
      }
    } catch (e) {
      print("Error fetching vendor name for driver app: $e");
    }
  }

  Future<void> _fetchLastTrip(String driverMobile) async {
    try {
      // Query tickets where this driver's bus was used
      // Tickets store busId; we look up by driver mobile through the bus record
      // Strategy: get all busIds for this driver's mobile, then find latest ticket
      final busSnapshot = await _firestore
          .collection('buses')
          .where('driver.mobile', isEqualTo: driverMobile)
          .get();

      if (busSnapshot.docs.isEmpty) return;

      final busIds = busSnapshot.docs.map((d) => d.id).toList();

      // Fetch recent tickets for any of these buses
      final ticketSnapshot = await _firestore
          .collection('tickets')
          .where('busId', whereIn: busIds)
          .get();

      if (ticketSnapshot.docs.isEmpty) {
        lastTrip.value = 'No trips yet';
        return;
      }

      // Sort by createdAt descending client-side to find the latest
      final tickets = ticketSnapshot.docs.map((d) => d.data()).toList();
      tickets.sort((a, b) {
        final aDate = DateTime.tryParse(a['createdAt']?.toString() ?? '') ?? DateTime(2000);
        final bDate = DateTime.tryParse(b['createdAt']?.toString() ?? '') ?? DateTime(2000);
        return bDate.compareTo(aDate);
      });

      final latest = tickets.first;
      final from = latest['from'] ?? latest['boardingPoint'] ?? '';
      final to = latest['to'] ?? latest['droppingPoint'] ?? '';
      final date = latest['journeyDate'] ?? latest['travelDate'] ?? '';

      if (from.isNotEmpty && to.isNotEmpty) {
        lastTrip.value = date.isNotEmpty ? '$from → $to ($date)' : '$from → $to';
      } else {
        lastTrip.value = 'No trips yet';
      }
    } catch (e) {
      print('Error fetching last trip: $e');
      lastTrip.value = 'N/A';
    }
  }

  Future<void> toggleStatus() async {
    final String? uid = _authController.uid;
    if (uid == null) return;

    if (!hasBusAssigned.value && !isOnline.value) {
      Get.snackbar(
        'Action Required',
        'You cannot activate your shift because no bus has been assigned to you yet.',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    try {
      isOnline.value = !isOnline.value;
      
      final String targetStatus = isOnline.value ? 'ON TRIP' : 'ACTIVE';

      await _firestore.collection('drivers').doc(uid).update({'status': targetStatus});

      if (isOnline.value) {
        if (activeBusData != null && activeBusData!['id'] != null) {
          _trackingService.startTracking(activeBusData!['id']);
        }
        Get.snackbar(
          'Shift Started',
          'You are now online and your bus is active.',
          snackPosition: SnackPosition.TOP,
        );
      } else {
        _trackingService.stopTracking();
        Get.snackbar(
          'Shift Ended',
          'You are now offline.',
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch(e) {
      // Revert if error occurs gracefully
      isOnline.value = !isOnline.value;
      Get.snackbar('Network Error', 'Failed to change shift status: $e');
    }
  }

  void goToBusDetails() {
    if (activeBusData != null) {
      Get.toNamed('/driver-bus-details', arguments: activeBusData);
    }
  }

  void goToProfile() {
    // Deprecated explicitly running routing to Profile directly now that
    // it functions via an Indexed Stack via main_layout navigation!
  }
}