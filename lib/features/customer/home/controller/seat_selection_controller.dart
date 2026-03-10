import 'package:get/get.dart';

class SeatSelectionController extends GetxController {
  final String busName = Get.arguments?['busName'] ?? 'Pune to Bangalore';
  final double seatPrice = 1250.0;

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

  // Dummy booked seats (Greyed out)
  final List<String> bookedSeats = ['L4', 'L5', 'R1', 'L10', 'U2', 'U5'];

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
    if (selectedSeats.isEmpty) {
      Get.snackbar(
        'No Seat Selected',
        'Please select at least one seat to proceed.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    print(
      "Proceeding to pay for seats: ${selectedSeats.join(', ')} | Total: ₹$totalPrice",
    );
    // TODO: Navigate to Checkout/Payment Screen
  }
}
