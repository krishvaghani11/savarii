import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:savarii/models/seat_model.dart';

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
  final RxMap<String, String> seatGenders = <String, String>{}.obs;

  final Rx<BusLayoutConfig?> layoutConfig = Rx<BusLayoutConfig?>(null);

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

      final bookedGendersByDate = data['bookedSeatsGendersByDate'] as Map<String, dynamic>? ?? {};
      final rawGenders = bookedGendersByDate[formattedDate] as Map<String, dynamic>? ?? {};
      
      final Map<String, String> gendersMap = {};
      rawGenders.forEach((key, value) {
        gendersMap[key] = value.toString();
      });
      seatGenders.assignAll(gendersMap);

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
      
      if (data['layoutConfig'] != null) {
        layoutConfig.value = BusLayoutConfig.fromMap(data['layoutConfig'] as Map<String, dynamic>);
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
        // Optional: Check restriction and warn
        final seat = _getSeatById(seatId);
        if (seat != null) {
          final status = _getEffectiveStatus(seat);
          if (status == 'restricted_female') {
            Get.snackbar(
              'Reserved for Females',
              'This seat is reserved for female passengers. Please ensure you enter correct details in the next step.',
              snackPosition: SnackPosition.TOP,
              backgroundColor: Colors.pink.shade50,
              colorText: Colors.pink.shade900,
            );
          } else if (status == 'restricted_male') {
             Get.snackbar(
              'Reserved for Males',
              'This seat is reserved for male passengers. Please ensure you enter correct details in the next step.',
              snackPosition: SnackPosition.TOP,
              backgroundColor: Colors.blue.shade50,
              colorText: Colors.blue.shade900,
            );
          }
        }
        selectedSeats.add(seatId);
      } else {
        Get.snackbar('Limit Reached', 'You can select up to 6 seats at once.', snackPosition: SnackPosition.TOP);
      }
    }
  }

  SeatModel? _getSeatById(String seatId) {
    if (layoutConfig.value == null) return null;
    if (seatId.startsWith('U')) {
      return layoutConfig.value!.upperSeats.firstWhereOrNull((s) => s.id == seatId);
    }
    return layoutConfig.value!.seats.firstWhereOrNull((s) => s.id == seatId || 'U${s.id}' == seatId);
  }

  String _getEffectiveStatus(SeatModel seat) {
    if (layoutConfig.value == null) return 'available';
    
    final bool useUpper = seat.id.startsWith('U');
    final List<SeatModel> gridSeats = useUpper ? layoutConfig.value!.upperSeats : layoutConfig.value!.seats;
    
    final rowSeats = gridSeats.where((s) => s.row == seat.row).toList();
    rowSeats.sort((a, b) => a.col.compareTo(b.col));
    
    int myIdx = rowSeats.indexWhere((s) => s.col == seat.col);
    if (myIdx == -1) return 'available';

    int start = myIdx;
    while (start > 0 && !rowSeats[start - 1].isSpace) start--;
    int end = myIdx;
    while (end < rowSeats.length - 1 && !rowSeats[end + 1].isSpace) end++;
    
    final block = rowSeats.sublist(start, end + 1);
    
    for (var s in block) {
      String sId = s.id;
      if (useUpper && !sId.startsWith('U')) sId = 'U$sId';
      if (bookedSeats.contains(sId)) {
        String? nGender = seatGenders[sId];
        if (nGender == 'female') return 'restricted_female';
        if (nGender == 'male') return 'restricted_male';
      }
    }
    return 'available';
  }

  double get totalPrice {
    if (layoutConfig.value != null) {
      double total = 0.0;
      for (String seatId in selectedSeats) {
        SeatModel? seat;
        if (seatId.startsWith('U') && layoutConfig.value!.hasUpperDeck) {
          seat = layoutConfig.value!.upperSeats.firstWhereOrNull((s) => s.id == seatId);
        } else {
          seat = layoutConfig.value!.seats.firstWhereOrNull(
            (s) => s.id == seatId || 'U${s.id}' == seatId
          );
        }
        
        if (seat != null && seat.price > 0) {
          total += seat.price;
        } else {
          total += seatPrice;
        }
      }
      return total;
    }
    return selectedSeats.length * seatPrice;
  }

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
