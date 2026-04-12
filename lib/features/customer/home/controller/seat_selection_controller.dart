import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SeatSelectionController extends GetxController {
  final String busName = Get.arguments?['busName'] ?? 'Unknown Bus';
  final String busId = Get.arguments?['busId'] ?? '';
  final String journeyDate = Get.arguments?['journeyDate'] ?? '';
  final double seatPrice = Get.arguments?['seatPrice'] ?? 1250.0;
  final String vendorId = Get.arguments?['vendorId'] ?? '';

  // Deck Toggle (true = Lower Deck, false = Upper Deck)
  final RxBool isLowerDeck = true.obs;

  // Bottom Sheet Tabs
  final List<String> bottomTabs = [
    'Bus Info',
    'Boarding',
    'Dropping',
    'Rest Stops',
    'Rating',
  ];
  final RxString selectedTab = 'Bus Info'.obs;

  // Header Details
  final RxString busType = 'Standard'.obs;
  final RxString durationInfo = ''.obs;

  // Additional Bus & Driver Info
  final RxString driverName = ''.obs;
  final RxString driverMobile = ''.obs;
  final RxString busNumber = ''.obs;

  // Route Points Streams
  final RxList<Map<String, dynamic>> boardingPoints = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> droppingPoints = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> restStops = <Map<String, dynamic>>[].obs;

  // Seat Management
  final RxList<String> selectedSeats = <String>[].obs;

  // Booked seats loaded dynamically from Firestore per journey date
  final RxList<String> bookedSeats = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadBookedSeats();
  }

  Future<void> _loadBookedSeats() async {
    if (busId.isEmpty || journeyDate.isEmpty) return;

    // If the journey date is in the past, all seats are naturally unlocked
    try {
      final parts = journeyDate.split('/');
      if (parts.length == 3) {
        final jDate = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
        final today = DateTime.now();
        final todayMidnight = DateTime(today.year, today.month, today.day);
        if (jDate.isBefore(todayMidnight)) {
          bookedSeats.clear();
          return; // Journey is over — all seats unlocked
        }
      }
    } catch (_) {}

    try {
      final doc = await FirebaseFirestore.instance
          .collection('buses')
          .doc(busId)
          .get();

      if (!doc.exists) return;

      // Format date from dd/MM/yyyy -> dd-MM-yyyy (Firestore map key)
      final formattedDate = journeyDate.replaceAll('/', '-');
      final data = doc.data() ?? {};
      
      // Map Header Information
      busType.value = data['busType']?.toString() ?? 'Standard Bus';
      busNumber.value = data['busNumber']?.toString() ?? '';

      final driverMap = data['driver'] as Map<String, dynamic>? ?? {};
      driverName.value = driverMap['name']?.toString() ?? 'Unknown Driver';
      driverMobile.value = driverMap['mobile']?.toString() ?? 'No Contact Info';

      final routeMap = data['route'] as Map<String, dynamic>? ?? {};
      final depTime = routeMap['departureTime']?.toString() ?? '';
      final arrTime = routeMap['arrivalTime']?.toString() ?? '';
      
      if (depTime.isNotEmpty && arrTime.isNotEmpty) {
        durationInfo.value = '$depTime - $arrTime';
      } else {
        durationInfo.value = '';
      }

      final bookedSeatsByDate = data['bookedSeatsByDate'] as Map<String, dynamic>? ?? {};
      final rawBooked = bookedSeatsByDate[formattedDate] as List<dynamic>? ?? [];

      bookedSeats.assignAll(rawBooked.map((s) => s.toString()).toList());

      // Parse and inject the dynamic points created by the vendor
      if (routeMap['boardingPoints'] != null) {
        final List<dynamic> bps = routeMap['boardingPoints'];
        final parsedBps = bps.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        boardingPoints.assignAll(parsedBps);
      } else {
        print('DEBUG: No boardingPoints found in routeMap');
      }

      if (routeMap['droppingPoints'] != null) {
        final List<dynamic> dps = routeMap['droppingPoints'];
        final parsedDps = dps.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        droppingPoints.assignAll(parsedDps);
      }

      if (routeMap['restStops'] != null) {
        final List<dynamic> rss = routeMap['restStops'];
        final parsedRss = rss.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        restStops.assignAll(parsedRss);
      }
      
      print('DEBUG: Successfully loaded ${boardingPoints.length} boarding points');

    } catch (e) {
      print('Error loading booked seats: $e');
    }
  }

  void toggleDeck(bool lower) {
    isLowerDeck.value = lower;
  }

  void selectTab(String tab) {
    selectedTab.value = tab;
  }

  void toggleSeat(String seatId) {
    if (bookedSeats.contains(seatId)) return; // Cannot select booked seats

    if (selectedSeats.contains(seatId)) {
      selectedSeats.remove(seatId);
    } else {
      if (selectedSeats.length < 6) {
        // Limit to 6 seats per booking
        selectedSeats.add(seatId);
      } else {
        Get.snackbar('Limit Reached', 'You can only select up to 6 seats.');
      }
    }
  }

  double get totalPrice => selectedSeats.length * seatPrice;

  void proceedToPay() {
    print("Navigating to Point Selection....");
    
    // We already hold the raw datastream for dropping/boarding points in RxLists
    // Convert them back to a standard List format so they pass gracefully through arguments!
    Get.toNamed('/customer-select-points', arguments: {
      'busId': busId,
      'busName': busName,
      'journeyDate': journeyDate,
      'seatPrice': seatPrice,
      'selectedSeats': selectedSeats.toList(),
      'boardingPointsData': boardingPoints.toList(),
      'droppingPointsData': droppingPoints.toList(),
      'vendorId': vendorId,
    });
  }
}
