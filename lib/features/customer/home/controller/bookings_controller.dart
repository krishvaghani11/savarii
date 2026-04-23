import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:savarii/core/services/auth_services.dart';
import 'package:savarii/core/services/firestore_service.dart';
import 'package:savarii/core/services/ticket_pdf_service.dart';
import 'package:savarii/routes/app_routes.dart';

class BookingsController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final FirestoreService _firestoreService = Get.find<FirestoreService>();

  // --- Date Selector State ---
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxList<DateTime> dateList = <DateTime>[].obs;

  // Master list from Firestore
  final RxList<Map<String, dynamic>> allTickets = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> allParcels = <Map<String, dynamic>>[].obs;
  StreamSubscription? _ticketsSubscription;
  StreamSubscription? _parcelsSubscription;

  // Filtered lists per status
  final RxList<Map<String, dynamic>> activeTickets = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> completedTickets = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> cancelledTickets = <Map<String, dynamic>>[].obs;

  final RxList<Map<String, dynamic>> activeParcels = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> completedParcels = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> cancelledParcels = <Map<String, dynamic>>[].obs;

  // Top level tab manager (Tickets or Parcels)
  final RxInt currentMainTab = 0.obs; // 0 = Tickets, 1 = Parcels

  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _generateDateList(DateTime.now());
    _subscribeToTickets();
  }

  @override
  void onClose() {
    _ticketsSubscription?.cancel();
    _parcelsSubscription?.cancel();
    super.onClose();
  }

  void switchMainTab(int index) {
    currentMainTab.value = index;
    // Re-trigger visual layout if needed, though GetX will handle it automatically based on RxInt
  }

  // -------------------------------------------------------
  // Date Selector
  // -------------------------------------------------------

  void _generateDateList(DateTime startDate) {
    dateList.clear();
    for (int i = 0; i < 5; i++) {
      dateList.add(startDate.add(Duration(days: i)));
    }
    selectedDate.value = dateList.first;
  }

  void selectDate(DateTime date) {
    selectedDate.value = date;
    _applyFilters();
  }

  Future<void> pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
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
      _generateDateList(picked);
      selectDate(picked);
    }
  }

  // -------------------------------------------------------
  // Firestore
  // -------------------------------------------------------

  void _subscribeToTickets() {
    final customerId = _authService.currentUser?.uid;
    if (customerId == null) {
      isLoading.value = false;
      return;
    }

    _ticketsSubscription =
        _firestoreService.getCustomerTicketsStream(customerId).listen((tickets) {
      allTickets.assignAll(tickets);
      isLoading.value = false;
      _applyFilters();
    });

    _parcelsSubscription = 
        _firestoreService.getCustomerParcelsStream(customerId).listen((parcels) {
      allParcels.assignAll(parcels);
      _applyFilters();
    });
  }

  void _applyFilters() {
    final selected = DateTime(
      selectedDate.value.year,
      selectedDate.value.month,
      selectedDate.value.day,
    );
    final today = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day);

    _filterTicketsSublist(allTickets, activeTickets, completedTickets, cancelledTickets, selected, today, true);
    _filterTicketsSublist(allParcels, activeParcels, completedParcels, cancelledParcels, selected, today, false);
  }

  void _filterTicketsSublist(
    List<Map<String, dynamic>> source, 
    RxList<Map<String, dynamic>> activeList,
    RxList<Map<String, dynamic>> completedList,
    RxList<Map<String, dynamic>> cancelledList,
    DateTime selected,
    DateTime today,
    bool isTicket
  ) {
    final List<Map<String, dynamic>> active = [];
    final List<Map<String, dynamic>> completed = [];
    final List<Map<String, dynamic>> cancelled = [];

    for (final ticket in source) {
      final status = (ticket['status'] ?? '').toString().toLowerCase();
      
      // For tickets, journeyDate. For Parcels, createdAt or estimatedPickupTime
      String journeyDateStr = '';
      if (isTicket) {
        journeyDateStr = ticket['journeyDate']?.toString() ?? '';
      } else {
        // Parcels might not have a formal 'journeyDate', fall back to createdAt for filtering
        journeyDateStr = ticket['createdAt']?.toString() ?? ''; 
        if (journeyDateStr.contains('T')) {
          journeyDateStr = journeyDateStr.split('T').first;
        }
      }

      final journeyDate = _parseDate(journeyDateStr);
      if (journeyDate == null) continue;

      if (status == 'cancelled') {
        if (_isSameDay(journeyDate, selected)) cancelled.add(ticket);
        continue;
      }

      if (!_isSameDay(journeyDate, selected)) continue;

      if (!journeyDate.isBefore(today)) {
        active.add(ticket);
      } else {
        completed.add(ticket);
      }
    }

    for (final list in [active, completed, cancelled]) {
      list.sort((a, b) {
        final dateAStr = isTicket ? (a['journeyDate']?.toString() ?? '') : (a['createdAt']?.toString() ?? '');
        final dateBStr = isTicket ? (b['journeyDate']?.toString() ?? '') : (b['createdAt']?.toString() ?? '');
        final dateA = _parseDate(dateAStr.contains('T') ? dateAStr.split('T').first : dateAStr);
        final dateB = _parseDate(dateBStr.contains('T') ? dateBStr.split('T').first : dateBStr);
        if (dateA != null && dateB != null) return dateA.compareTo(dateB);
        return 0;
      });
    }

    activeList.assignAll(active);
    completedList.assignAll(completed);
    cancelledList.assignAll(cancelled);
  }

  // -------------------------------------------------------
  // Actions
  // -------------------------------------------------------

  Future<void> cancelTicket(String ticketId) async {
    try {
      await _firestoreService.updateTicketStatus(ticketId, 'cancelled');
      Get.snackbar(
        'Booking Cancelled',
        'Your booking has been cancelled successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE82E59),
        colorText: Colors.white,
      );
    } catch (e) {
      print('Error cancelling ticket: $e');
      Get.snackbar(
        'Error',
        'Failed to cancel booking. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void cancelBooking(Map<String, dynamic> ticket) {
    Get.toNamed(AppRoutes.cancelBooking, arguments: {
      'bookingId': ticket['bookingId'] ?? '',
      'passengerPhone': ticket['passengerPhone'] ?? '',
      'customerEmail': ticket['customerEmail'] ?? '',
    });
  }

  /// Navigate to the live bus tracking screen.
  /// Uses busId if trip_id is not explicitly assigned.
  void trackBus(Map<String, dynamic> ticket) {
    final rawTripId = ticket['trip_id']?.toString() ?? '';
    final tripId = rawTripId.isNotEmpty ? rawTripId : (ticket['busId']?.toString() ?? '');
    if (tripId.isEmpty) {
      Get.snackbar(
        'Tracking Unavailable',
        'Live tracking will be available once the vendor assigns your bus to a trip.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFFF3CD),
        colorText: const Color(0xFF856404),
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }
    Get.toNamed(AppRoutes.trackBus, arguments: {'trip_id': tripId});
  }

  void trackParcelBus(Map<String, dynamic> parcel) {
    final rawTripId = parcel['trip_id']?.toString() ?? '';
    final tripId = rawTripId.isNotEmpty ? rawTripId : (parcel['busId']?.toString() ?? '');
    if (tripId.isEmpty) {
      Get.snackbar(
        'Tracking Unavailable',
        'Live tracking will be available once your parcel is assigned to a trip/bus.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFFF3CD),
        colorText: const Color(0xFF856404),
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }
    Get.toNamed(AppRoutes.trackBus, arguments: {'trip_id': tripId});
  }

  void goToCancelParcel(Map<String, dynamic> parcel) {
    Get.toNamed(AppRoutes.cancelParcel, arguments: {
      'parcelId': parcel['id'] ?? '',
      'trackingId': parcel['trackingId'] ?? '',
      'senderPhone': parcel['senderPhone'] ?? '',
    });
  }

  Future<void> downloadTicket(Map<String, dynamic> ticket) async {
    try {
      final pdfData = TicketDownloadData.fromMap(ticket);
      await TicketPdfService().downloadTicket(pdfData);
    } catch (e) {
      Get.snackbar('Error', 'Failed to generate ticket PDF: $e');
    }
  }

  Future<void> downloadParcel(Map<String, dynamic> parcel) async {
    try {
      final pdfData = ParcelDownloadData(
        trackingId: parcel['trackingId'] ?? '',
        senderName: parcel['senderName'] ?? '',
        senderPhone: parcel['senderPhone'] ?? '',
        receiverName: parcel['receiverName'] ?? '',
        receiverPhone: parcel['receiverPhone'] ?? '',
        pickupLocation: parcel['pickupCity'] ?? '',
        dropLocation: parcel['dropCity'] ?? '',
        estimatedPickupTime: parcel['estimatedPickupTime'] ?? '',
        estimatedDropTime: parcel['estimatedDropoffTime'] ?? '',
        busAndDriver: '${parcel['busName'] ?? ''} | ${parcel['busNumber'] ?? ''}',
        weight: (parcel['weight'] as num?)?.toDouble() ?? 0.0,
        paymentMethod: parcel['paymentMethod'] ?? 'Razorpay',
        baseFare: (parcel['baseFare'] as num?)?.toDouble() ?? 0.0,
        serviceFee: (parcel['serviceFee'] as num?)?.toDouble() ?? 0.0,
        gst: (parcel['tax'] as num?)?.toDouble() ?? 0.0,
        totalPaid: (parcel['totalAmount'] as num?)?.toDouble() ?? (parcel['totalPaid'] as num?)?.toDouble() ?? 0.0,
      );
      await TicketPdfService().downloadParcel(pdfData);
    } catch (e) {
      Get.snackbar('Error', 'Failed to generate invoice PDF: $e');
    }
  }

  void bookAgain(String type) {
    if (type == 'bus') {
      Get.toNamed('/book-ticket');
    } else if (type == 'parcel') {
      Get.toNamed('/book-parcel');
    }
  }

  void rateTrip(String id) {
    Get.toNamed('/review-trip', arguments: {'bookingId': id});
  }

  void reportIssue(String id) {
    Get.toNamed('/report-issue', arguments: {'bookingId': id});
  }

  // -------------------------------------------------------
  // Helpers
  // -------------------------------------------------------

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  DateTime? _parseDate(String dateStr) {
    try {
      if (dateStr.isEmpty) return null;
      if (dateStr.contains('-')) {
        return DateTime.parse(dateStr);
      }
      final parts = dateStr.split('/');
      if (parts.length == 3) {
        return DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      }
    } catch (e) {
      print('Error parsing date "$dateStr": $e');
    }
    return null;
  }
}