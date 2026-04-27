import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:savarii/core/services/auth_services.dart';
import 'package:savarii/core/services/firestore_service.dart';
import 'package:savarii/core/services/ticket_pdf_service.dart';

class PaymentDetailsController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final FirestoreService _firestoreService = Get.find<FirestoreService>();

  late Razorpay _razorpay;

  // Navigation Payload Parameters
  String busId = '';
  String busName = '';
  String journeyDate = '';
  double seatPrice = 0.0;
  List<String> selectedSeats = [];
  String vendorId = '';
  List<Map<String, String>> passengers = [];
  String contactEmail = '';
  String contactPhone = '';

  // Reactive String Fields mapping straight to the View Elements
  final RxString boardingPoint = ''.obs;
  final RxString droppingPoint = ''.obs;

  // Tax calculations (Using 5% dynamic GST + 10 Fixed Platform Fee like vendor side)
  final RxDouble gst = 0.0.obs;
  final double platformFee = 10.00;

  // Reactively track the real Base Fare
  late RxDouble baseFare;
  late RxDouble totalAmount;

  // ── Wallet payment ──────────────────────────────────────────────────────────
  final RxString selectedPaymentMethod = 'Razorpay'.obs;
  final RxDouble walletBalance = 0.0.obs;

  final RxBool isLoading = false.obs;
  final TextEditingController promoController = TextEditingController();

  @override
  void onInit() {
    super.onInit();

    if (Get.arguments != null) {
      final args = Get.arguments as Map<String, dynamic>;
      busId = args['busId'] ?? '';
      busName = args['busName'] ?? 'Standard Ride';
      journeyDate = args['journeyDate'] ?? 'Unknown Date';
      seatPrice = args['seatPrice'] ?? 0.0;
      selectedSeats = List<String>.from(args['selectedSeats'] ?? []);
      vendorId = args['vendorId'] ?? '';

      boardingPoint.value = args['boardingPoint']?.toString() ?? 'Not Selected';
      droppingPoint.value = args['droppingPoint']?.toString() ?? 'Not Selected';

      passengers =
          (args['passengers'] as List?)
              ?.map((e) => Map<String, String>.from(e as Map))
              .toList() ??
          [];
      contactEmail = args['contactEmail']?.toString() ?? '';
      contactPhone = args['contactPhone']?.toString() ?? '';
    }

    baseFare = (seatPrice * selectedSeats.length).obs;
    gst.value = baseFare.value * 0.05;
    totalAmount = (baseFare.value + gst.value + platformFee).obs;

    // Stream live wallet balance for display in payment method selector
    final userId = _authService.currentUser?.uid;
    if (userId != null) {
      _firestoreService.streamWalletBalance(userId).listen((bal) {
        walletBalance.value = bal;
      });
    }

    // Setup Razorpay
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onPaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onPaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _onExternalWallet);
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────
  bool get hasInsufficientBalance =>
      selectedPaymentMethod.value == 'Wallet' &&
      walletBalance.value < totalAmount.value;

  void applyPromo() {
    if (promoController.text.isNotEmpty) {
      print("Applying Promo Code: ${promoController.text}");
      totalAmount.value -= 150.00;
      Get.snackbar(
        'Promo Applied',
        'Discount has been applied to your total.',
        snackPosition: SnackPosition.TOP,
      );
      promoController.clear();
    }
  }

  void confirmPayment() {
    if (selectedPaymentMethod.value == 'Wallet') {
      _payWithWallet();
    } else {
      openRazorpayCheckout();
    }
  }

  // ── Wallet Payment Flow ───────────────────────────────────────────────────────
  Future<void> _payWithWallet() async {
    if (hasInsufficientBalance) {
      Get.snackbar(
        'Insufficient Balance',
        'Insufficient balance in wallet, please top up wallet, and try again',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        duration: const Duration(seconds: 4),
      );
      return;
    }

    isLoading.value = true;
    final pnr = 'PNR${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
    final customerId = _authService.currentUser?.uid ?? '';
    final ticketPayload = _buildTicketPayload(pnr, 'Savarii Wallet', '');

    try {
      // 1. Generate & upload PDF
      final pdfData = TicketDownloadData(
        bookingId: pnr,
        passengerName: ticketPayload['passengerName'] as String,
        passengerPhone: ticketPayload['passengerPhone'] as String,
        journeyDate: journeyDate,
        route: ticketPayload['route'] as String,
        busAndSeat: ticketPayload['busAndSeat'] as String,
        paymentMethod: 'Savarii Wallet',
        ticketPrice: baseFare.value,
        gst: gst.value,
        platformFee: platformFee,
        totalPaid: totalAmount.value,
      );
      final pdfBytes = await TicketPdfService().generatePdfBytes(pdfData);
      final ticketUrl = await _firestoreService.uploadTicketPdf(pnr, pdfBytes);
      ticketPayload['ticketUrl'] = ticketUrl;

      // 2. Atomically deduct wallet + log transaction
      await _firestoreService.debitWalletBalance(
        userId: customerId,
        amount: totalAmount.value,
        walletTransactionData: {
          'transactionId': 'T${DateTime.now().millisecondsSinceEpoch}',
          'razorpayPaymentId': 'N/A',
          'title': 'Ticket Booking (PNR: $pnr)',
          'amount': totalAmount.value,
          'isCredit': false,
          'iconType': 'ticket',
          'status': 'Completed',
          'paymentMethod': 'Wallet',
          'name': ticketPayload['passengerName'],
          'mobile': contactPhone,
          'remarks': 'Bus: $busName | Seats: ${selectedSeats.join(", ")}',
          'createdAt': DateTime.now().toIso8601String(),
        },
      );

      // 3. Save ticket
      await _firestoreService.addTicket(ticketPayload);

      // 4. Block seats on bus document
      if (busId.isNotEmpty && selectedSeats.isNotEmpty) {
        await _firestoreService.addBookedSeatsToBus(busId, journeyDate, selectedSeats);
      }

      Get.snackbar(
        '✅ Payment Successful',
        '₹${totalAmount.value.toStringAsFixed(2)} deducted from your Savarii Wallet',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade800,
      );

      Get.offNamed('/booking-confirmation', arguments: ticketPayload);
    } catch (e) {
      final msg = e.toString().contains('Insufficient')
          ? 'Insufficient balance in wallet, please top up wallet, and try again'
          : 'Payment failed: $e';
      Get.snackbar(
        'Error',
        msg,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ── Razorpay Flow ─────────────────────────────────────────────────────────────
  void openRazorpayCheckout() {
    final amountInPaise = (totalAmount.value * 100).toInt();

    final options = {
      'key': dotenv.env['RAZORPAY_KEY'],
      'amount': amountInPaise,
      'name': 'Savarii Bus Booking',
      'description':
          '${boardingPoint.value} → ${droppingPoint.value} | ${selectedSeats.join(", ")}',
      'prefill': {
        'contact': _authService.currentUser?.phoneNumber ?? '',
        'name': _authService.currentUser?.displayName ?? '',
      },
      'theme': {'color': '#E82E59'},
      'modal': {'confirm_close': true, 'ondismiss': 'dismiss'},
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Razorpay Error: $e');
      Get.snackbar(
        'Error',
        'Unable to open payment gateway. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    }
  }

  void _onPaymentSuccess(PaymentSuccessResponse response) async {
    isLoading.value = true;
    final pnr = 'PNR${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
    final ticketPayload = _buildTicketPayload(pnr, 'Razorpay', response.paymentId ?? '');

    try {
      final pdfData = TicketDownloadData(
        bookingId: pnr,
        passengerName: ticketPayload['passengerName'] as String,
        passengerPhone: ticketPayload['passengerPhone'] as String,
        journeyDate: journeyDate,
        route: ticketPayload['route'] as String,
        busAndSeat: ticketPayload['busAndSeat'] as String,
        paymentMethod: 'Razorpay',
        ticketPrice: baseFare.value,
        gst: gst.value,
        platformFee: platformFee,
        totalPaid: totalAmount.value,
      );
      final pdfBytes = await TicketPdfService().generatePdfBytes(pdfData);
      final ticketUrl = await _firestoreService.uploadTicketPdf(pnr, pdfBytes);
      ticketPayload['ticketUrl'] = ticketUrl;

      await _firestoreService.addTicket(ticketPayload);

      if (busId.isNotEmpty && selectedSeats.isNotEmpty) {
        await _firestoreService.addBookedSeatsToBus(busId, journeyDate, selectedSeats);
      }

      debugPrint('Customer Ticket $pnr saved. Seats blocked: $selectedSeats');
      Get.offNamed('/booking-confirmation', arguments: ticketPayload);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Payment succeeded but failed to save ticket: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade900,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ── Shared Payload Builder ────────────────────────────────────────────────────
  Map<String, dynamic> _buildTicketPayload(
      String pnr, String paymentMethod, String razorpayId) {
    final customerId = _authService.currentUser?.uid ?? '';
    return {
      'customerId': customerId,
      'vendorId': vendorId,
      'busId': busId,
      'busName': busName,
      'createdAt': DateTime.now().toIso8601String(),
      'bookingId': pnr,
      // trip_id is set to empty string at booking time.
      // The vendor/driver side will update this field when a trip is created
      // and assign the bus to a trip. The customer uses this to track the bus.
      'trip_id': '',
      // status field: 'active' until the trip is completed or cancelled
      'status': 'active',
      'passengerName': passengers.isNotEmpty
          ? passengers.first['name']
          : _authService.currentUser?.displayName ?? 'Customer',
      'passengerPhone': contactPhone.isNotEmpty
          ? contactPhone
          : _authService.currentUser?.phoneNumber ?? 'N/A',
      'passengers': passengers,
      'contactEmail': contactEmail,
      'origin': boardingPoint.value,
      'destination': droppingPoint.value,
      'journeyDate': journeyDate,
      'route': '${boardingPoint.value} to ${droppingPoint.value}',
      'busAndSeat': '$busName | ${selectedSeats.join(", ")}',
      'paymentMethod': paymentMethod,
      'razorpayPaymentId': razorpayId,
      'ticketPrice': baseFare.value,
      'gst': gst.value,
      'platformFee': platformFee,
      'totalPaid': totalAmount.value,
    };
  }

  void _onPaymentError(PaymentFailureResponse response) {
    Get.snackbar(
      'Payment Failed',
      response.message ?? 'Something went wrong. Please try again.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red.shade100,
      colorText: Colors.red.shade800,
    );
  }

  void _onExternalWallet(ExternalWalletResponse response) {
    Get.snackbar(
      'External Wallet',
      'Payment via ${response.walletName}. Please complete the payment.',
      snackPosition: SnackPosition.TOP,
    );
  }

  @override
  void onClose() {
    _razorpay.clear();
    promoController.dispose();
    super.onClose();
  }
}
