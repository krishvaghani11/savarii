import 'package:flutter/material.dart';
import 'package:get/get.dart';


class BookTicketController extends GetxController {
  // 1. Text Controllers for locations
  final TextEditingController fromController = TextEditingController();
  final TextEditingController toController = TextEditingController();

  // 2. Reactive variables for date and passengers
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxInt passengerCount = 1.obs;

  // 3. Swap locations logic
  void swapLocations() {
    String tempFrom = fromController.text;
    fromController.text = toController.text;
    toController.text = tempFrom;
  }

  // 4. Select date using native calendar picker
  void selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime.now(),
      // User cannot select a past date
      lastDate: DateTime.now().add(const Duration(days: 365)),
      // Up to a year in advance
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.red, // Head background
              onPrimary: Colors.white, // Head text
              surface: Colors.white, // Surface color
              onSurface: Colors.black, // Day color
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      selectedDate.value = picked;
    }
  }

  // 5. Update passenger count
  void incrementPassengers() {
    if (passengerCount.value < 10) {
      // Limit for example
      passengerCount.value++;
    }
  }

  void decrementPassengers() {
    if (passengerCount.value > 1) {
      passengerCount.value--;
    }
  }

  // 6. Action: Search Buses
  void searchBuses() {
    print(
      "Searching buses from ${fromController.text} to ${toController.text} for date ${selectedDate.value} with ${passengerCount.value} passengers...",
    );
    Get.toNamed('/search-results');
    // TODO: Add logic to fetch buses and navigate to search results
  }

  // Action: Clear recent searches
  void clearRecentSearches() {
    print("Clearing recent searches...");
  }
}
