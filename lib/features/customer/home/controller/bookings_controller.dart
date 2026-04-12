import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:savarii/core/services/auth_services.dart';
import 'package:savarii/core/services/firestore_service.dart';
import 'package:savarii/routes/app_routes.dart';

class BookingsController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final FirestoreService _firestoreService = Get.find<FirestoreService>();

  // --- Date Selector State ---
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxList<DateTime> dateList = <DateTime>[].obs;

  // Master list from Firestore
  final RxList<Map<String, dynamic>> allTickets = <Map<String, dynamic>>[].obs;
  StreamSubscription? _ticketsSubscription;

  // Filtered lists per tab
  final RxList<Map<String, dynamic>> activeTickets = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> completedTickets = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> cancelledTickets = <Map<String, dynamic>>[].obs;

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
    super.onClose();
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
  }

  void _applyFilters() {
    final selected = DateTime(
      selectedDate.value.year,
      selectedDate.value.month,
      selectedDate.value.day,
    );
    final today = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day);

    final List<Map<String, dynamic>> active = [];
    final List<Map<String, dynamic>> completed = [];
    final List<Map<String, dynamic>> cancelled = [];

    for (final ticket in allTickets) {
      final status = (ticket['status'] ?? '').toString().toLowerCase();
      final journeyDateStr = ticket['journeyDate']?.toString() ?? '';
      final journeyDate = _parseDate(journeyDateStr);

      if (journeyDate == null) continue;

      // Cancelled — show if journeyDate matches selected date
      if (status == 'cancelled') {
        if (_isSameDay(journeyDate, selected)) {
          cancelled.add(ticket);
        }
        continue;
      }

      // Only show tickets whose journeyDate matches the selected date
      if (!_isSameDay(journeyDate, selected)) continue;

      // Active = selected date >= today
      if (!journeyDate.isBefore(today)) {
        active.add(ticket);
      } else {
        // Completed = journeyDate is in the past
        completed.add(ticket);
      }
    }

    // Sort each list by departureTime (earliest first)
    for (final list in [active, completed, cancelled]) {
      list.sort((a, b) {
        final dateA = _parseDate(a['journeyDate']?.toString() ?? '');
        final dateB = _parseDate(b['journeyDate']?.toString() ?? '');
        if (dateA != null && dateB != null) return dateA.compareTo(dateB);
        return 0;
      });
    }

    activeTickets.assignAll(active);
    completedTickets.assignAll(completed);
    cancelledTickets.assignAll(cancelled);
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