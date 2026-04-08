import 'dart:async';
import 'package:flutter/material.dart';
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
    double p(dynamic v, double fb) =>
        (v is num) ? v.toDouble() : double.tryParse(v.toString()) ?? fb;

    return VendorTicketModel(
      passengerName: map['passengerName'] ?? 'Unknown Passenger',
      passengerPhone: map['passengerPhone'] ?? 'N/A',
      bookingId: map['bookingId'] ?? 'PNR-XXXXX',
      busAndSeat: map['busAndSeat'] ?? 'Unknown Bus | N/A',
      route: map['route'] ?? 'Unknown Route',
      origin: map['origin'] ?? 'Unknown Origin',
      journeyDate: map['journeyDate'] ?? 'Unknown Date',
      totalPaid: p(map['totalPaid'], 0.0),
      ticketPrice: p(map['ticketPrice'], 0.0),
      gst: p(map['gst'], 0.0),
      platformFee: p(map['platformFee'], 10.0),
      paymentMethod: map['paymentMethod'] ?? 'UPI',
      ticketUrl: map['ticketUrl'] ?? '',
    );
  }
}

class VendorViewTicketsController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final FirestoreService _firestoreService = Get.find<FirestoreService>();

  // Selected Date Management
  final Rx<DateTime> selectedDate = DateTime.now().obs;

  // Realtime Live Tickets Array
  final RxList<VendorTicketModel> allTickets = <VendorTicketModel>[].obs;
  final RxList<VendorTicketModel> tickets = <VendorTicketModel>[].obs;
  StreamSubscription? _ticketsSubscription;

  int get totalTickets => allTickets.length;
  int get confirmedTickets => allTickets.length;

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
        ticketDocs.sort((a, b) => (b['createdAt'] ?? '').compareTo(a['createdAt'] ?? ''));
        
        allTickets.clear();
        allTickets.addAll(ticketDocs.map((doc) => VendorTicketModel.fromMap(doc)));
        
        _filterTickets();
      });
    }
  }

  void _filterTickets() {
    final selectedStr = "${selectedDate.value.day.toString().padLeft(2, '0')}/${selectedDate.value.month.toString().padLeft(2, '0')}/${selectedDate.value.year}";
    
    // Filter the cached full list into the reactive tickets list
    tickets.value = allTickets.where((ticket) {
      return ticket.journeyDate == selectedStr;
    }).toList();
  }

  @override
  void onClose() {
    _ticketsSubscription?.cancel();
    super.onClose();
  }

  /// Get Monday to Sunday of the week containing the current selectedDate
  List<DateTime> get currentWeekDays {
    final date = selectedDate.value;
    // DateTime.weekday returns 1 for Monday to 7 for Sunday
    final int daysSinceMonday = date.weekday - 1;
    final monday = date.subtract(Duration(days: daysSinceMonday));
    return List.generate(7, (index) => monday.add(Duration(days: index)));
  }

  void selectDate(DateTime date) {
    selectedDate.value = date;
    _filterTickets();
  }

  Future<void> pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFE82E59), // header bg, selected day bg
              onPrimary: Colors.white, // text
              onSurface: Colors.black, // unselected items
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate.value) {
      selectDate(picked);
    }
  }

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
