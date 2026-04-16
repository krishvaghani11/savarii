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
  final String status;

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
    this.status = 'confirmed',
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
      status: map['status'] ?? 'confirmed',
    );
  }

  factory VendorTicketModel.fromParcelMap(Map<String, dynamic> map) {
    double p(dynamic v, double fb) =>
        (v is num) ? v.toDouble() : double.tryParse(v.toString()) ?? fb;

    return VendorTicketModel(
      passengerName: map['senderName'] ?? 'Unknown Sender',
      passengerPhone: map['senderPhone'] ?? 'N/A',
      bookingId: map['trackingId'] ?? 'TRK-XXXXX',
      busAndSeat: '${map['weight'] ?? 0} KG',
      route: '${map['pickupCity']} to ${map['dropCity']}',
      origin: map['pickupCity'] ?? 'Unknown',
      journeyDate: _extractDateStringFromDateTime(map['createdAt'] ?? ''),
      totalPaid: p(map['totalPaid'], 0.0),
      ticketPrice: p(map['baseFare'], 0.0),
      gst: p(map['tax'], 0.0),
      platformFee: p(map['serviceFee'], 10.0),
      paymentMethod: map['paymentMethod'] ?? 'UPI',
      ticketUrl: map['ticketUrl'] ?? '',
      status: map['status'] ?? 'confirmed',
    );
  }

  static String _extractDateStringFromDateTime(String iso) {
    if (iso.isEmpty) return 'Unknown Date';
    if (iso.contains('T')) {
      final parts = iso.split('T').first.split('-');
      if (parts.length == 3) {
        return '${parts[2]}/${parts[1]}/${parts[0]}';
      }
    }
    return iso;
  }
}

class VendorViewTicketsController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final FirestoreService _firestoreService = Get.find<FirestoreService>();

  // Selected Date Management
  final Rx<DateTime> selectedDate = DateTime.now().obs;

  // Realtime Live Tickets Array
  final RxList<VendorTicketModel> allTickets = <VendorTicketModel>[].obs;
  final RxList<VendorTicketModel> ticketsForSelectedDate = <VendorTicketModel>[].obs;
  
  // Realtime Live Parcels Array
  final RxList<VendorTicketModel> allParcels = <VendorTicketModel>[].obs;
  final RxList<VendorTicketModel> parcelsForSelectedDate = <VendorTicketModel>[].obs;

  StreamSubscription? _ticketsSubscription;
  StreamSubscription? _parcelsSubscription;

  // 0 = Tickets, 1 = Parcels
  final RxInt currentMainTab = 0.obs;

  int get totalTickets => tickets.length;
  int get confirmedTickets => tickets.length;

  RxList<VendorTicketModel> get tickets {
    return currentMainTab.value == 0 ? ticketsForSelectedDate : parcelsForSelectedDate;
  }

  @override
  void onInit() {
    super.onInit();
    _loadTickets();
  }

  void _loadTickets() {
    final user = _authService.currentUser;
    if (user != null) {
      _ticketsSubscription = _firestoreService.getVendorTicketsStream(user.uid).listen((ticketDocs) {
        ticketDocs.sort((a, b) => (b['createdAt'] ?? '').compareTo(a['createdAt'] ?? ''));
        allTickets.clear();
        allTickets.addAll(ticketDocs.map((doc) => VendorTicketModel.fromMap(doc)));
        _filterTickets();
      });

      _parcelsSubscription = _firestoreService.getVendorParcelsStream(user.uid).listen((parcelDocs) {
        parcelDocs.sort((a, b) => (b['createdAt'] ?? '').compareTo(a['createdAt'] ?? ''));
        allParcels.clear();
        allParcels.addAll(parcelDocs.map((doc) => VendorTicketModel.fromParcelMap(doc)));
        _filterTickets();
      });
    }
  }

  void _filterTickets() {
    final selectedStr = "${selectedDate.value.day.toString().padLeft(2, '0')}/${selectedDate.value.month.toString().padLeft(2, '0')}/${selectedDate.value.year}";
    
    // Filter the cached full list into the reactive tickets list
    ticketsForSelectedDate.value = allTickets.where((ticket) {
      return ticket.journeyDate == selectedStr;
    }).toList();

    parcelsForSelectedDate.value = allParcels.where((parcel) {
      return parcel.journeyDate == selectedStr;
    }).toList();
  }

  void switchMainTab(int index) {
    currentMainTab.value = index;
  }

  @override
  void onClose() {
    _ticketsSubscription?.cancel();
    _parcelsSubscription?.cancel();
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
    // If we're displaying tickets, we download TicketDownloadData.
    // If parcels, we assume it's ParcelDownloadData.
    if (currentMainTab.value == 0) {
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
    } else {
      // Stub for downloading parcel PDFs using same flow
      final parts = ticket.route.split('to');
      final pData = ParcelDownloadData(
        trackingId: ticket.bookingId,
        senderName: ticket.passengerName,
        senderPhone: ticket.passengerPhone,
        receiverName: 'Receiver',
        receiverPhone: 'N/A',
        pickupLocation: parts.isNotEmpty ? parts[0].trim() : 'N/A',
        dropLocation: parts.length > 1 ? parts[1].trim() : 'N/A',
        estimatedPickupTime: ticket.journeyDate,
        estimatedDropTime: ticket.journeyDate,
        busAndDriver: '',
        weight: 1.0,
        paymentMethod: ticket.paymentMethod,
        baseFare: ticket.ticketPrice,
        serviceFee: ticket.platformFee,
        gst: ticket.gst,
        totalPaid: ticket.totalPaid,
      );
      
      try {
        final bytes = await TicketPdfService().generateParcelPdfBytes(pData);
        // Normally you save bytes to device. Reusing the download wrapper:
        final stubTicket = TicketDownloadData(
            bookingId: pData.trackingId, 
            passengerName: pData.senderName, 
            passengerPhone: pData.senderPhone, 
            journeyDate: pData.estimatedPickupTime, 
            route: '${pData.pickupLocation} to ${pData.dropLocation}', 
            busAndSeat: 'Parcel Logistics', 
            paymentMethod: pData.paymentMethod, 
            ticketPrice: pData.baseFare, 
            gst: pData.gst, 
            platformFee: pData.serviceFee, 
            totalPaid: pData.totalPaid);
            
        await TicketPdfService().downloadTicket(stubTicket);
      } catch (e) {
        print("Vendor parcel pdf failed: $e");
      }
    }
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
