import 'dart:async';
import 'package:get/get.dart';
import 'package:savarii/core/services/auth_services.dart';
import 'package:savarii/core/services/firestore_service.dart';

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

  VendorTicketModel({
    required this.passengerName,
    required this.passengerPhone,
    required this.bookingId,
    required this.busAndSeat,
    required this.route,
    required this.origin,
    required this.journeyDate,
    required this.totalPaid,
  });

  factory VendorTicketModel.fromMap(Map<String, dynamic> map) {
    return VendorTicketModel(
      passengerName: map['passengerName'] ?? 'Unknown Passenger',
      passengerPhone: map['passengerPhone'] ?? 'N/A',
      bookingId: map['bookingId'] ?? 'PNR-XXXXX',
      busAndSeat: map['busAndSeat'] ?? 'Unknown Bus | N/A',
      route: map['route'] ?? 'Unknown Route',
      origin: map['origin'] ?? 'Unknown Origin',
      journeyDate: map['journeyDate'] ?? 'Unknown Date',
      totalPaid: (map['totalPaid'] is num) ? (map['totalPaid'] as num).toDouble() : double.tryParse(map['totalPaid'].toString()) ?? 0.0,
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

  void downloadTicket(String ticketId) {
    print("Downloading ticket $ticketId...");
    Get.snackbar(
      'Downloading',
      'Ticket $ticketId is downloading...',
      snackPosition: SnackPosition.BOTTOM,
    );
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
