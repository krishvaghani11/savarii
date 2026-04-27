import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:savarii/core/services/auth_services.dart';
import 'package:savarii/core/services/firestore_service.dart';
import 'package:savarii/core/services/ticket_pdf_service.dart';

class ParcelPaymentController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final FirestoreService _firestoreService = Get.find<FirestoreService>();

  late Razorpay _razorpay;

  // Dynamic Data
  late final String orderId;
  late final String trackingId;
  late final String pickupLocation;
  late final String dropoffLocation;
  late final String estimatedPickupTime;
  late final String estimatedDropoffTime;

  late final double weight;
  late final String parcelType;
  late final String senderName;
  late final String receiverName;

  late final String busId;
  late final String busName;
  late final String busNumber;
  late final String vendorId;
  late final String driverName;
  late final String driverPhone;

  // Pricing Data
  late final double baseFare;
  late final double weightSurcharge;
  late final double serviceFee;
  late final double tax;

  // Reactive States
  late RxDouble totalAmount;
  final RxBool isLoading = false.obs;

  // ── Wallet payment ──────────────────────────────────────────────────────────
  final RxString selectedPaymentMethod = 'Razorpay'.obs;
  final RxDouble walletBalance = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>? ?? {};

    // Generate random identifiers
    final String timestampStr = DateTime.now().millisecondsSinceEpoch.toString();
    final int randomPart = 1000 + (DateTime.now().microsecond % 9000);
    orderId = '#SAV-${timestampStr.substring(timestampStr.length - 6)}';
    trackingId = 'SAV-P${timestampStr.substring(timestampStr.length - 4)}$randomPart';

    pickupLocation = args['pickupCity'] ?? '';
    dropoffLocation = args['dropCity'] ?? '';
    estimatedPickupTime = args['estimatedPickupTime'] ?? '--:--';
    estimatedDropoffTime = args['estimatedDropoffTime'] ?? '--:--';

    weight = args['weight'] ?? 1.0;
    parcelType = args['parcelType'] ?? 'Other';
    senderName = args['senderName'] ?? '';
    receiverName = args['receiverName'] ?? '';

    busId = args['busId'] ?? '';
    busName = args['busName'] ?? 'Unknown Bus';
    busNumber = args['busNumber'] ?? 'Unknown Number';
    vendorId = args['vendorId'] ?? '';
    driverName = args['driverName'] ?? 'Unknown Driver';
    driverPhone = args['driverPhone'] ?? 'Unknown Phone';

    baseFare = args['baseFare'] ?? 0.0;
    weightSurcharge = 0.0;
    serviceFee = args['serviceFee'] ?? 0.0;
    tax = args['tax'] ?? 0.0;
    totalAmount = (baseFare + serviceFee + tax).obs;

    // Stream live wallet balance for display in payment method selector
    final userId = _authService.currentUser?.uid;
    if (userId != null) {
      _firestoreService.streamWalletBalance(userId).listen((bal) {
        walletBalance.value = bal;
      });
    }

    _setupRazorpay();
  }

  void _setupRazorpay() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onPaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onPaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _onExternalWallet);
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────
  bool get hasInsufficientBalance =>
      selectedPaymentMethod.value == 'Wallet' &&
      walletBalance.value < totalAmount.value;

  void helpAction() {
    print("Opening Help & Support...");
  }

  void callDriver() {
    print("Calling driver at $driverPhone...");
    Get.snackbar(
      'Calling Driver',
      'Initiating call to $driverName...',
      snackPosition: SnackPosition.TOP,
    );
  }

  void payNow() {
    if (isLoading.value) return;

    if (selectedPaymentMethod.value == 'Wallet') {
      _payWithWallet();
    } else {
      _openRazorpayCheckout();
    }
  }

  // ── Shared Parcel Payload Builder ─────────────────────────────────────────────
  Map<String, dynamic> _buildParcelPayload(String payMethod, String razorpayId) {
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final customerId = _authService.currentUser?.uid ?? '';
    return {
      'customerId': customerId,
      'vendorId': vendorId,
      'trackingId': trackingId,
      'orderId': orderId,
      'busId': busId,
      'busName': busName,
      'busNumber': busNumber,
      'driverName': driverName,
      'driverPhone': driverPhone,
      'pickupCity': pickupLocation,
      'dropCity': dropoffLocation,
      'estimatedPickupTime': estimatedPickupTime,
      'estimatedDropoffTime': estimatedDropoffTime,
      'weight': weight,
      'parcelType': parcelType,
      'senderName': senderName,
      'senderPhone': args['senderPhone'] ?? '',
      'receiverName': receiverName,
      'receiverPhone': args['receiverPhone'] ?? '',
      'pickupResident': args['pickupResident'],
      'dropResident': args['dropResident'],
      'notes': args['notes'] ?? '',
      'baseFare': baseFare,
      'serviceFee': serviceFee,
      'tax': tax,
      'totalPaid': totalAmount.value,
      'paymentMethod': payMethod,
      'razorpayPaymentId': razorpayId,
      'status': 'Booked',
      'createdAt': DateTime.now().toIso8601String(),
    };
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
    final customerId = _authService.currentUser?.uid ?? '';
    final parcelPayload = _buildParcelPayload('Savarii Wallet', '');

    try {
      // 1. Generate & upload PDF
      final args = Get.arguments as Map<String, dynamic>? ?? {};
      final pdfData = ParcelDownloadData(
        trackingId: trackingId,
        senderName: senderName,
        senderPhone: args['senderPhone'] ?? '',
        receiverName: receiverName,
        receiverPhone: args['receiverPhone'] ?? '',
        pickupLocation: pickupLocation,
        dropLocation: dropoffLocation,
        estimatedPickupTime: estimatedPickupTime,
        estimatedDropTime: estimatedDropoffTime,
        busAndDriver: '$busName | $busNumber | Driver: $driverName',
        weight: weight,
        paymentMethod: 'Savarii Wallet',
        baseFare: baseFare,
        serviceFee: serviceFee,
        gst: tax,
        totalPaid: totalAmount.value,
      );

      final pdfBytes = await TicketPdfService().generateParcelPdfBytes(pdfData);
      final pdfUrl = await _firestoreService.uploadParcelPdf(trackingId, pdfBytes);
      parcelPayload['ticketUrl'] = pdfUrl;

      // 2. Atomically deduct wallet + log transaction
      await _firestoreService.debitWalletBalance(
        userId: customerId,
        amount: totalAmount.value,
        walletTransactionData: {
          'transactionId': 'T${DateTime.now().millisecondsSinceEpoch}',
          'razorpayPaymentId': 'N/A',
          'title': 'Parcel Booking (TRK: $trackingId)',
          'amount': totalAmount.value,
          'isCredit': false,
          'iconType': 'parcel',
          'status': 'Completed',
          'paymentMethod': 'Wallet',
          'name': senderName,
          'mobile': args['senderPhone'] ?? '',
          'remarks': '$pickupLocation → $dropoffLocation | $parcelType',
          'createdAt': DateTime.now().toIso8601String(),
        },
      );

      // 3. Save parcel
      await _firestoreService.addParcel(parcelPayload);

      Get.snackbar(
        '✅ Payment Successful',
        '₹${totalAmount.value.toStringAsFixed(2)} deducted from your Savarii Wallet',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade800,
      );

      Get.offNamed('/parcel-confirmation', arguments: parcelPayload);
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
  void _openRazorpayCheckout() {
    final amountInPaise = (totalAmount.value * 100).toInt();
    final customerPhone = _authService.currentUser?.phoneNumber ?? '9876543210';

    final options = {
      'key': dotenv.env['RAZORPAY_KEY'],
      'amount': amountInPaise,
      'name': 'Savarii Parcel Booking',
      'description': 'Tracking: $trackingId',
      'prefill': {'contact': customerPhone, 'name': senderName},
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

  Future<void> _onPaymentSuccess(PaymentSuccessResponse response) async {
    isLoading.value = true;
    final parcelPayload = _buildParcelPayload('Razorpay', response.paymentId ?? '');

    try {
      final args = Get.arguments as Map<String, dynamic>? ?? {};
      final pdfData = ParcelDownloadData(
        trackingId: trackingId,
        senderName: senderName,
        senderPhone: args['senderPhone'] ?? '',
        receiverName: receiverName,
        receiverPhone: args['receiverPhone'] ?? '',
        pickupLocation: pickupLocation,
        dropLocation: dropoffLocation,
        estimatedPickupTime: estimatedPickupTime,
        estimatedDropTime: estimatedDropoffTime,
        busAndDriver: '$busName | $busNumber | Driver: $driverName',
        weight: weight,
        paymentMethod: 'Razorpay',
        baseFare: baseFare,
        serviceFee: serviceFee,
        gst: tax,
        totalPaid: totalAmount.value,
      );

      final pdfBytes = await TicketPdfService().generateParcelPdfBytes(pdfData);
      final ticketUrl = await _firestoreService.uploadParcelPdf(trackingId, pdfBytes);
      parcelPayload['ticketUrl'] = ticketUrl;

      await _firestoreService.addParcel(parcelPayload);
      Get.offNamed('/parcel-confirmation', arguments: parcelPayload);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Payment succeeded but failed to save parcel: $e',
        snackPosition: SnackPosition.TOP,
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
    super.onClose();
  }
}
