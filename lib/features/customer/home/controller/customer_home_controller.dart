import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:savarii/core/services/auth_services.dart';
import 'package:savarii/core/services/firestore_service.dart';
import 'package:savarii/features/auth/controllers/auth_controller.dart';
import 'package:savarii/features/customer/home/controller/main_layout_controller.dart';

class CustomerHomeController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final FirestoreService _firestoreService = Get.find<FirestoreService>();

  // Global key to control the Scaffold's Drawer from anywhere
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  // User details (dummy data for now)
  final RxString userName = "Savarii User".obs;
  final RxString phoneNumber = "".obs;
  final RxString profileImageUrl = "".obs;
  final double walletBalance = 45.50;

  final RxList<Map<String, dynamic>> activeTickets = <Map<String, dynamic>>[].obs;
  StreamSubscription? _ticketSubscription;
  StreamSubscription? _profileSubscription;

  @override
  void onInit() {
    super.onInit();
    _fetchActiveTicket();
    _fetchProfileData();
  }

  void _fetchProfileData() {
    final customerId = _authService.currentUser?.uid;
    if (customerId != null) {
      _profileSubscription = _firestoreService.getCustomerProfileStream(customerId).listen((data) {
        if (data != null) {
          userName.value = data['name'] ?? 'Savarii User';
          phoneNumber.value = data['phone'] ?? '';
          profileImageUrl.value = data['profileImageUrl'] ?? '';
        }
      });
    }
  }

  @override
  void onClose() {
    _ticketSubscription?.cancel();
    _profileSubscription?.cancel();
    super.onClose();
  }

  void _fetchActiveTicket() {
    final customerId = _authService.currentUser?.uid;
    if (customerId != null) {
      _ticketSubscription = _firestoreService
          .getCustomerTicketsStream(customerId)
          .listen((tickets) {
        if (tickets.isEmpty) {
          activeTickets.clear();
          return;
        }

        // Filter and find closest upcoming ticket
        final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
        
        List<Map<String, dynamic>> upcomingTickets = tickets.where((ticket) {
          // Exclude cancelled tickets
          final status = (ticket['status'] ?? '').toString().toLowerCase();
          if (status == 'cancelled') return false;

          final journeyDateStr = ticket['journeyDate']?.toString() ?? '';
          final parsedDate = _parseDate(journeyDateStr);
          if (parsedDate != null) {
            return !parsedDate.isBefore(today); // >= today
          }
          return false; // exclude if unparseable
        }).toList();

        // Sort by date (closest first)
        upcomingTickets.sort((a, b) {
          final dateA = _parseDate(a['journeyDate'].toString());
          final dateB = _parseDate(b['journeyDate'].toString());
          if (dateA != null && dateB != null) return dateA.compareTo(dateB);
          return 0;
        });

        activeTickets.assignAll(upcomingTickets);
      });
    }
  }

  DateTime? _parseDate(String dateStr) {
    try {
      if (dateStr.contains('-')) {
        return DateTime.parse(dateStr);
      }
      final parts = dateStr.split('/');
      if (parts.length == 3) {
        return DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      }
    } catch (e) {
      print('Error parsing date $dateStr: $e');
    }
    return null;
  }



  // --- Sidebar Logic ---
  void openSidebar() {
    scaffoldKey.currentState?.openDrawer();
  }

  void closeSidebar() {
    scaffoldKey.currentState?.closeDrawer();
  }

  // --- Dashboard Quick Actions ---
  void goToNotifications() {
    print("Navigating to Notifications Screen...");
    // Get.toNamed('/notifications');
  }

  void goToBookTicket() {
    print("Navigating to Seat Selection/Bus Search...");
    Get.toNamed('/book-ticket');
  }

  void goToTrackBus() {
    closeSidebar(); // Closes sidebar if opened from there
    print("Navigating to Live Tracking...");
    Get.toNamed('/track-bus');
  }

  void goToBookParcel() {
    print("Navigating to Parcel Booking...");
    Get.toNamed('/book-parcel');
  }

  void goToWallet() {
    print("Navigating to Wallet...");
    if (Get.isRegistered<MainLayoutController>()) {
      // 0 = Home, 1 = Trips, 2 = Wallet, 3 = Profile
      Get.find<MainLayoutController>().changeTab(2);
    } else {
      // Fallback: If for some reason they aren't on the dashboard, route directly
      Get.toNamed('/wallet');
    }
  }

  // --- Sidebar Navigation ---
  void goToMyBookings() {
    closeSidebar();
    print("Navigating to My Bookings...");
    Get.toNamed('/my-bookings');
  }

  void goToHelpAndSupport() {
    closeSidebar();
    print("Navigating to Help & Support...");
    Get.toNamed('/help-support');
  }

  void goToLanguage() {
    closeSidebar();
    print("Navigating to Language Settings...");
    Get.toNamed('/language');
  }

  void goToAboutUs() {
    closeSidebar();
    print("Navigating to About Us...");
    Get.toNamed('/about-us');
  }

  void logout() {
    closeSidebar();
    print("Logging out user...");
    if (Get.isRegistered<AuthController>()) {
      Get.find<AuthController>().logout();
    } else {
      Get.offAllNamed('/role-selection');
    }
  }
}
