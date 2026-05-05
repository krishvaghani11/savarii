import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:savarii/core/services/firestore_service.dart';
import 'package:savarii/routes/app_routes.dart';

class CancelBookingController extends GetxController {
  final FirestoreService _firestoreService = Get.find<FirestoreService>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController mobileController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController pnrController = TextEditingController();

  final RxBool isLoading = false.obs;
  String? targetBookingId;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>? ?? {};

    // Pre-fill PNR if passed from the bookings view
    if (args['bookingId'] != null && args['bookingId'].toString().isNotEmpty) {
      targetBookingId = args['bookingId'];
      pnrController.text = targetBookingId!;
    }

    // Pre-fill mobile number from the ticket record
    final phone = args['passengerPhone']?.toString() ?? '';
    if (phone.isNotEmpty) {
      mobileController.text = phone;
    }

    // Pre-fill email: prefer argument, fall back to Firebase Auth
    final argEmail = args['customerEmail']?.toString() ?? '';
    final authEmail = FirebaseAuth.instance.currentUser?.email ?? '';
    emailController.text = argEmail.isNotEmpty ? argEmail : authEmail;
  }

  Future<void> submitCancellation() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;

    try {
      // Step 1: Look up ticket by PNR
      final ticket = await _firestoreService.getTicketByPnr(pnrController.text.trim());

      if (ticket == null) {
        _showError('No booking found with this PNR. Please check and try again.');
        return;
      }

      // Step 2: Validate Mobile Number
      final storedPhone = (ticket['passengerPhone'] ?? '').toString().trim();
      final enteredPhone = mobileController.text.trim();
      if (storedPhone != enteredPhone) {
        _showError("Mobile number doesn't match the booking record.");
        return;
      }

      // Step 3: Validate Email
      final storedEmail = (ticket['customerEmail'] ??
              FirebaseAuth.instance.currentUser?.email ??
              '')
          .toString()
          .trim()
          .toLowerCase();
      final enteredEmail = emailController.text.trim().toLowerCase();
      if (storedEmail != enteredEmail) {
        _showError("Email address doesn't match the booking record.");
        return;
      }

      // Step 4: Check it's not already cancelled
      final currentStatus = (ticket['status'] ?? '').toString().toLowerCase();
      if (currentStatus == 'cancelled') {
        _showError('This booking has already been cancelled.');
        return;
      }

      // Step 5: All checks passed — cancel the ticket
      await _firestoreService.updateTicketStatus(ticket['id'], 'cancelled');

      // Step 6: Unlock seats
      final busId = ticket['busId'] as String?;
      final journeyDate = ticket['journeyDate'] as String?;
      List<String> seatsToUnlock = [];

      if (ticket.containsKey('selectedSeats') && ticket['selectedSeats'] is List) {
        seatsToUnlock = List<String>.from(ticket['selectedSeats']);
      } else {
        final busAndSeat = ticket['busAndSeat'] as String? ?? '';
        if (busAndSeat.contains('|')) {
          final seatPart = busAndSeat.split('|').last;
          seatsToUnlock = seatPart.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
        }
      }

      if (busId != null && busId.isNotEmpty && journeyDate != null && journeyDate.isNotEmpty && seatsToUnlock.isNotEmpty) {
        await _firestoreService.removeBookedSeatsFromBus(busId, journeyDate, seatsToUnlock);
      }

      // Show success snackbar
      Get.snackbar(
        '✅ Booking Cancelled',
        'Your booking has been successfully cancelled.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
        borderRadius: 16,
        margin: const EdgeInsets.all(16),
        icon: const Icon(Icons.check_circle, color: Colors.white),
        duration: const Duration(seconds: 3),
      );

      // Navigate to bookings screen after short delay so snackbar is visible
      await Future.delayed(const Duration(milliseconds: 400));
      Get.offNamed(AppRoutes.myBookings);

    } catch (e) {
      _showError('Failed to process cancellation. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  void _showError(String message) {
    Get.snackbar(
      'Cancellation Failed',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red.shade50,
      colorText: Colors.red.shade800,
      duration: const Duration(seconds: 4),
    );
  }

  @override
  void onClose() {
    mobileController.dispose();
    emailController.dispose();
    pnrController.dispose();
    super.onClose();
  }
}