import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../../core/services/auth_services.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/services/ticket_pdf_service.dart';

class VendorRazorpayController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final FirestoreService _firestoreService = Get.find<FirestoreService>();

  late Razorpay _razorpay;

  // Parsed payload from Payment Details screen
  late final String busId;
  late final String busName;
  late final String busImage;
  late final String origin;
  late final String destination;
  late final String date;
  late final String departureTime;
  late final String seat;
  late final String passengerName;
  late final String passengerPhone;
  late final double baseFare;
  late final double gst;
  late final double platformFee;
  late final double totalAmount;

  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();

    // Parse payload from previous screen
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    busId = args['busId'] ?? '';
    busName = args['busName'] ?? 'Unknown Bus';
    busImage = args['busImage'] ?? '';
    origin = args['boardingPoint'] ?? args['origin'] ?? 'Unknown Origin';
    destination = args['droppingPoint'] ?? args['destination'] ?? 'Unknown Destination';
    date = args['journeyDate'] ?? 'Unknown Date';
    departureTime = args['departureTime'] ?? '--:--';
    seat = args['selectedSeats'] ?? 'N/A';
    passengerName = args['passengerName'] ?? 'Unknown Passenger';
    passengerPhone = args['passengerPhone'] ?? 'N/A';

    final tf = args['totalBaseFare'] ?? args['ticketPrice'] ?? 0.0;
    baseFare = (tf is int) ? tf.toDouble() : (tf is double ? tf : double.tryParse(tf.toString()) ?? 0.0);
    gst = baseFare * 0.05;
    platformFee = 10.00;
    totalAmount = baseFare + gst + platformFee;

    // Setup Razorpay
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onPaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onPaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _onExternalWallet);

    // Launch payment after brief delay so screen can render
    WidgetsBinding.instance.addPostFrameCallback((_) {
      openRazorpayCheckout();
    });
  }

  void openRazorpayCheckout() {
    // Amount must be in paise (multiply by 100)
    final amountInPaise = (totalAmount * 100).toInt();

    final options = {
      'key': 'rzp_test_SYcIlV5G19FLqH', 
      'amount': amountInPaise,
      'name': 'Savarii Bus Booking',
      'description': '$origin → $destination | $seat',
      'prefill': {
        'contact': passengerPhone,
        'name': passengerName,
      },
      'theme': {'color': '#E82E59'},
      'modal': {
        'confirm_close': true,
        'ondismiss': 'dismiss',
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Razorpay Error: $e');
      Get.snackbar(
        'Error',
        'Unable to open payment gateway. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    }
  }

  void _onPaymentSuccess(PaymentSuccessResponse response) async {
    isLoading.value = true;

    // Generate random PNR
    final pnr = 'PNR${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
    final vendorId = _authService.currentUser?.uid ?? '';

    // Parse list of seats
    final seatList = seat.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();

    final ticketPayload = {
      'vendorId': vendorId,
      'busId': busId,
      'busName': busName,
      'busImage': busImage,
      'createdAt': DateTime.now().toIso8601String(),
      'bookingId': pnr,
      'passengerName': passengerName,
      'passengerPhone': passengerPhone,
      'origin': origin,
      'destination': destination,
      'journeyDate': date,
      'departureTime': departureTime,
      'route': '$origin to $destination',
      'busAndSeat': '$busName | $seat',
      'paymentMethod': 'Razorpay',
      'razorpayPaymentId': response.paymentId ?? '',
      'ticketPrice': baseFare,
      'gst': gst,
      'platformFee': platformFee,
      'totalPaid': totalAmount,
    };

    try {
      // 0. Generate and Upload PDF Ticket
      final pdfData = TicketDownloadData(
        bookingId: pnr,
        passengerName: passengerName,
        passengerPhone: passengerPhone,
        journeyDate: date,
        route: '$origin to $destination',
        busAndSeat: '$busName | $seat',
        paymentMethod: 'Razorpay',
        ticketPrice: baseFare,
        gst: gst,
        platformFee: platformFee,
        totalPaid: totalAmount,
      );
      final pdfBytes = await TicketPdfService().generatePdfBytes(pdfData);
      final ticketUrl = await _firestoreService.uploadTicketPdf(pnr, pdfBytes);
      ticketPayload['ticketUrl'] = ticketUrl;

      // 1. Save ticket to Firestore
      await _firestoreService.addTicket(ticketPayload);

      // 2. Block the booked seats on the bus document
      if (busId.isNotEmpty && seatList.isNotEmpty) {
        await _firestoreService.addBookedSeatsToBus(busId, seatList);
      }

      debugPrint('Ticket $pnr saved. Seats blocked: $seatList');

      // 3. Navigate to confirmation screen
      Get.offNamed('/vendor-payment-confirmation', arguments: ticketPayload);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Payment succeeded but failed to save ticket: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade900,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _onPaymentError(PaymentFailureResponse response) {
    Get.snackbar(
      'Payment Failed',
      response.message ?? 'Something went wrong. Please try again.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade100,
      colorText: Colors.red.shade800,
    );
    // Go back to the payment details screen
    Get.back();
  }

  void _onExternalWallet(ExternalWalletResponse response) {
    Get.snackbar(
      'External Wallet',
      'Payment via ${response.walletName}. Please complete the payment.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  void onClose() {
    _razorpay.clear();
    super.onClose();
  }
}
