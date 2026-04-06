import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SeatSelectionController extends GetxController {
  final String busName = Get.arguments?['busName'] ?? 'Unknown Bus';
  final String busId = Get.arguments?['busId'] ?? '';
  final String journeyDate = Get.arguments?['journeyDate'] ?? '';
  final double seatPrice = Get.arguments?['seatPrice'] ?? 1250.0;

  // Deck Toggle (true = Lower Deck, false = Upper Deck)
  final RxBool isLowerDeck = true.obs;

  // Bottom Sheet Tabs
  final List<String> bottomTabs = [
    'Bus Info',
    'Routes',
    'Boarding',
    'Rest Stops',
    'Rating',
  ];
  final RxString selectedTab = 'Bus Info'.obs;

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
      final bookedSeatsByDate = data['bookedSeatsByDate'] as Map<String, dynamic>? ?? {};
      final rawBooked = bookedSeatsByDate[formattedDate] as List<dynamic>? ?? [];

      bookedSeats.assignAll(rawBooked.map((s) => s.toString()).toList());
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
    print("Navigating to Payment Section....");
    Get.toNamed('/payment-details');
  }
}
