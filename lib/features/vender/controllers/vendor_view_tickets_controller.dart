import 'package:flutter/material.dart';
import 'package:get/get.dart';

// A simple model to hold the ticket data
class VendorTicketModel {
  final String name;
  final String phone;
  final String email;
  final String ticketId;
  final String seat;
  final String route;
  final String boardingPoint;
  final String date;

  VendorTicketModel({
    required this.name,
    required this.phone,
    required this.email,
    required this.ticketId,
    required this.seat,
    required this.route,
    required this.boardingPoint,
    required this.date,
  });
}

class VendorViewTicketsController extends GetxController {
  final RxString currentDate = 'Today, 24 Oct 2023'.obs;

  // Dummy Data from your mockup
  final List<VendorTicketModel> tickets = [
    VendorTicketModel(
      name: 'Ramesh Kumar',
      phone: '+91 98765 43210',
      email: 'ramesh.kumar@example.com',
      ticketId: 'TKT-9921',
      seat: '12A',
      route: 'Delhi to Manali',
      boardingPoint: 'ISBT Kashmiri Gate',
      date: '23 Oct 2023', // Booking date
    ),
    VendorTicketModel(
      name: 'Vikram Mehta',
      phone: '+91 98765 43211',
      email: 'vikram.m@example.com',
      ticketId: 'TKT-9928',
      seat: '18B',
      route: 'Delhi to Chandigarh',
      boardingPoint: 'ISBT Kashmiri Gate',
      date: '23 Oct 2023',
    ),
    VendorTicketModel(
      name: 'Suresh Raina',
      phone: '+91 98765 43212',
      email: 'suresh.r@example.com',
      ticketId: 'TKT-9930',
      seat: '01A',
      route: 'Delhi to Dehradun',
      boardingPoint: 'Anand Vihar',
      date: '24 Oct 2023',
    ),
  ];

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
