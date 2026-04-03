import 'dart:async';
import 'package:get/get.dart';
import 'package:savarii/core/services/auth_services.dart';
import 'package:savarii/core/services/firestore_service.dart';
import 'package:savarii/core/services/ticket_pdf_service.dart';

// A simple model to hold the ticket data
class VendorTicketModel {
  final String passengerName;
  final String passengerPhone;
  final String bookingId;
  final String busAndSeat;
  final String route;
  final String origin;
  final String journeyDate;
  final double totalPaid;
  // Pricing breakdown (for PDF)
  final double ticketPrice;
  final double gst;
  final double platformFee;
  final String paymentMethod;
  final String ticketUrl;

  VendorTicketModel({
    required this.passengerName,
    required this.passengerPhone,
    required this.bookingId,
    required this.busAndSeat,
    required this.route,
    required this.origin,
    required this.journeyDate,
    required this.totalPaid,
    this.ticketPrice = 0.0,
    this.gst = 0.0,
    this.platformFee = 10.0,
    this.paymentMethod = 'UPI',
    this.ticketUrl = '',
  });

  factory VendorTicketModel.fromMap(Map<String, dynamic> map) {
    double _p(dynamic v, double fb) =>
        (v is num) ? v.toDouble() : double.tryParse(v.toString()) ?? fb;

    return VendorTicketModel(
      passengerName: map['passengerName'] ?? 'Unknown Passenger',
      passengerPhone: map['passengerPhone'] ?? 'N/A',
      bookingId: map['bookingId'] ?? 'PNR-XXXXX',
      busAndSeat: map['busAndSeat'] ?? 'Unknown Bus | N/A',
      route: map['route'] ?? 'Unknown Route',
      origin: map['origin'] ?? 'Unknown Origin',
      journeyDate: map['journeyDate'] ?? 'Unknown Date',
      totalPaid: _p(map['totalPaid'], 0.0),
      ticketPrice: _p(map['ticketPrice'], 0.0),
      gst: _p(map['gst'], 0.0),
      platformFee: _p(map['platformFee'], 10.0),
      paymentMethod: map['paymentMethod'] ?? 'UPI',
      ticketUrl: map['ticketUrl'] ?? '',
    );
  }
}

class VendorViewTicketsController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final FirestoreService _firestoreService = Get.find<FirestoreService>();

  final RxString currentDate = 'All Tickets'.obs;

  // Realtime Live Tickets Array
  final RxList<VendorTicketModel> tickets = <VendorTicketModel>[].obs;
  StreamSubscription? _ticketsSubscription;

  int get totalTickets => tickets.length;
  int get confirmedTickets => tickets.length;

  @override
  void onInit() {
    super.onInit();
    _loadTickets();
  }

  void _loadTickets() {
    final user = _authService.currentUser;
    if (user != null) {
      _ticketsSubscription = _firestoreService.getVendorTicketsStream(user.uid).listen((ticketDocs) {
        // Sort descending locally so newest PNRs appear at the top.
        // Doing this locally bypasses needing complex Firebase index configurations.
        ticketDocs.sort((a, b) => (b['createdAt'] ?? '').compareTo(a['createdAt'] ?? ''));
        
        tickets.value = ticketDocs.map((doc) => VendorTicketModel.fromMap(doc)).toList();
      });
    }
  }

  @override
  void onClose() {
    _ticketsSubscription?.cancel();
    super.onClose();
  }

  void previousDate() => print("Load previous date...");

  void nextDate() => print("Load next date...");

  void openFilters() => print("Opening filters...");

  /// Downloads a ticket PDF for the given [ticket] to the device.
  Future<void> downloadTicket(VendorTicketModel ticket) async {
    final data = TicketDownloadData(
      bookingId: ticket.bookingId,
      passengerName: ticket.passengerName,
      passengerPhone: ticket.passengerPhone,
      journeyDate: ticket.journeyDate,
      route: ticket.route,
      busAndSeat: ticket.busAndSeat,
      paymentMethod: ticket.paymentMethod,
      ticketPrice: ticket.ticketPrice,
      gst: ticket.gst,
      platformFee: ticket.platformFee,
      totalPaid: ticket.totalPaid,
    );
    await TicketPdfService().downloadTicket(data);
  }

  void shareTicket(String ticketId) {
    print("Sharing ticket $ticketId...");
    Get.snackbar(
      'Share',
      'Opening share dialog for $ticketId',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
