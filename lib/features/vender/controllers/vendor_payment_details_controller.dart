import 'package:get/get.dart';

class VendorPaymentDetailsController extends GetxController {
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
    print("Navigating to Razorpay for ₹$totalAmount...");

    final payload = {
      'busId': busId,
      'busName': busName,
      'busImage': busImage,
      'boardingPoint': origin,
      'droppingPoint': destination,
      'journeyDate': date,
      'departureTime': departureTime,
      'selectedSeats': seat,
      'passengerName': passengerName,
      'passengerPhone': passengerPhone,
      'totalBaseFare': baseFare,
    };

    // Navigate to the Razorpay gateway screen
    Get.toNamed('/vendor-razorpay', arguments: payload);
  }
}
