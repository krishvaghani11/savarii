import 'package:get/get.dart';
import 'package:savarii/core/services/auth_services.dart';
import 'package:savarii/core/services/firestore_service.dart';

class VendorPaymentDetailsController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final FirestoreService _firestoreService = Get.find<FirestoreService>();
  // Dynamic Booking Data
  late final String busId;
  late final String busName;
  late final String busImage;
  late final String origin;
  late final String destination;
  late final String date;
  late final String seat;
  late final String departureTime;

  late final String passengerName;
  late final String passengerPhone;

  // Fare Details
  late final double baseFare;
  late final double gst;
  final double platformFee = 10.00;
  late final double totalAmount;

  // Payment Selection State
  final RxString selectedPaymentMethod = 'UPI'.obs;

  @override
  void onInit() {
    super.onInit();
    
    // Parse the dynamically injected payload from the Ticket Booking screen
    final args = Get.arguments as Map<String, dynamic>? ?? {};

    busId = args['busId'] ?? '';
    busName = args['busName'] ?? 'Unknown Bus';
    busImage = args['busImage'] ?? '';
    origin = args['boardingPoint'] ?? 'Unknown Origin';
    destination = args['droppingPoint'] ?? 'Unknown Destination';
    date = args['journeyDate'] ?? 'Unknown Date';
    departureTime = args['departureTime'] ?? '--:--';
    seat = args['selectedSeats'] ?? 'N/A';
    
    passengerName = args['passengerName'] ?? 'Unknown Name';
    passengerPhone = args['passengerPhone'] ?? 'Unknown Phone';

    // Parse baseFare safely
    final tf = args['totalBaseFare'] ?? 0.0;
    baseFare = (tf is int) ? tf.toDouble() : (tf is double ? tf : double.tryParse(tf.toString()) ?? 0.0);

    // Calculate simulated realistic 5% GST on backend math
    gst = baseFare * 0.05; 
    
    // Sum final mathematical payment model
    totalAmount = baseFare + gst + platformFee;
  }

  void selectPaymentMethod(String method) {
    selectedPaymentMethod.value = method;
  }

  Future<void> proceedToPay() async {
    print(
      "Processing payment of ₹$totalAmount via ${selectedPaymentMethod.value}...",
    );

    // Generate Mock PNR id
    final pnr = 'PNR${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

    final payload = {
      'vendorId': _authService.currentUser?.uid ?? '',
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
      'busImage': busImage,
      'paymentMethod': selectedPaymentMethod.value,
      'ticketPrice': baseFare,
      'gst': gst,
      'platformFee': platformFee,
      'totalPaid': totalAmount
    };

    try {
      // Save permanently to Firestore
      await _firestoreService.addTicket(payload);
      print("Ticket $pnr successfully saved to Firestore");

      // Route to the Success Screen
      Get.offNamed('/vendor-payment-confirmation', arguments: payload);
    } catch (e) {
      Get.snackbar('Error', 'Failed to save ticket: $e');
    }
  }
}
