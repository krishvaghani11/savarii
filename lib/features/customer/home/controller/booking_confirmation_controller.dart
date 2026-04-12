import 'package:get/get.dart';
import 'package:savarii/core/services/ticket_pdf_service.dart';

class BookingConfirmationController extends GetxController {
  // Trip Details
  final RxString bookingId = ''.obs;
  final RxString fromCity = "".obs;
  final RxString toCity = "".obs;
  final RxString departureTime = "".obs;
  final RxString arrivalTime = "".obs;
  final RxString duration = "".obs;
  final RxString date = "".obs;
  final RxString seat = "".obs;
  final RxString passengers = "".obs;
  final RxString travelClass = "".obs;
  final RxString passengerName = "".obs;
  final RxString passengerPhone = "".obs;

  // Full ticket data for PDF download
  Map<String, dynamic>? ticketData;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      final args = Get.arguments as Map<String, dynamic>;
      ticketData = args;

      bookingId.value = args['bookingId'] ?? 'N/A';
      passengerName.value = args['passengerName']?.toString() ?? 'N/A';
      passengerPhone.value = args['passengerPhone']?.toString() ?? 'N/A';
      final bp = args['origin']?.toString() ?? 'N/A';
      final partsBp = bp.split(' - ');
      fromCity.value = partsBp[0].trim();
      departureTime.value = partsBp.length > 1 ? partsBp[1].trim() : '--:--';
      
      final dp = args['destination']?.toString() ?? 'N/A';
      final partsDp = dp.split(' - ');
      toCity.value = partsDp[0].trim();
      arrivalTime.value = partsDp.length > 1 ? partsDp[1].trim() : '--:--';

      // Attempt to split busAndSeat for cleaner display
      final busAndSeat = args['busAndSeat']?.toString() ?? '| N/A';
      final parts = busAndSeat.split('|');
      travelClass.value = parts[0].trim();
      seat.value = parts.length > 1 ? parts[1].trim() : 'N/A';

      duration.value = args['duration'] ?? 'N/A';
      date.value = args['journeyDate'] ?? 'N/A';

      final pList = args['passengers'] as List?;
      if (pList != null && pList.isNotEmpty) {
        passengers.value = '${pList.length} ${pList.length == 1 ? "Passenger" : "Passengers"}';
      } else {
        passengers.value = '1 Passenger';
      }
    }
  }

  void closeAndGoHome() {
    print("Returning to Dashboard...");
    Get.until((route) => Get.currentRoute == '/customer-main-layout' || route.isFirst);
  }

  Future<void> downloadETicket() async {
    if (ticketData == null) return;
    
    final pdfData = TicketDownloadData.fromMap(ticketData!);
    await TicketPdfService().downloadTicket(pdfData);
  }

  void needHelp() {
    print("Opening Help Center for booking ${bookingId.value}...");
  }
}
