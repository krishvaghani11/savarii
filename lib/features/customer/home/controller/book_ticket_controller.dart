import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:savarii/models/recent_search_model.dart';
import 'package:savarii/core/services/city_geolocation_service.dart';

class CitySuggestionModel {
  final String city;
  final String fullName;
  final String placeId;

  CitySuggestionModel({
    required this.city,
    required this.fullName,
    required this.placeId,
  });
}

class BookTicketController extends GetxController {
  // 1. Text Controllers for locations
  final TextEditingController fromController = TextEditingController();
  final TextEditingController toController = TextEditingController();

  // 2. Reactive variables for date and passengers
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxInt passengerCount = 1.obs;

  // 3. City Suggestion Data (from Geolocation API)
  final RxList<CitySuggestionModel> filteredFrom = <CitySuggestionModel>[].obs;
  final RxList<CitySuggestionModel> filteredTo = <CitySuggestionModel>[].obs;

  final Rxn<CitySuggestionModel> selectedFrom = Rxn<CitySuggestionModel>();
  final Rxn<CitySuggestionModel> selectedTo = Rxn<CitySuggestionModel>();

  // 4. Recent Searches
  final RxList<RecentSearchModel> recentSearches = <RecentSearchModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadRecentSearches();

    // Listeners for autocomplete
    fromController.addListener(() {
      _fetchCitySuggestions(fromController.text, isFrom: true);
    });
    toController.addListener(() {
      _fetchCitySuggestions(toController.text, isFrom: false);
    });
  }

  Future<void> _fetchCitySuggestions(
    String query, {
    required bool isFrom,
  }) async {
    if (query.isEmpty) {
      if (isFrom) {
        filteredFrom.clear();
      } else {
        filteredTo.clear();
      }
      return;
    }

    try {
      // Fetch city suggestions from geolocation service (only cities)
      final citySuggestions = await CityGeolocationService.fetchCitySuggestions(query);

      final suggestions = citySuggestions.map((cs) {
        return CitySuggestionModel(
          city: cs.city,
          fullName: cs.fullName,
          placeId: cs.placeId,
        );
      }).toList();

      // Filter out the city already selected in the other field
      if (isFrom && selectedTo.value != null) {
        suggestions.removeWhere((s) => s.city == selectedTo.value!.city);
      } else if (!isFrom && selectedFrom.value != null) {
        suggestions.removeWhere((s) => s.city == selectedFrom.value!.city);
      }

      if (isFrom) {
        filteredFrom.assignAll(suggestions);
      } else {
        filteredTo.assignAll(suggestions);
      }
    } catch (e) {
      print('Error fetching city suggestions: $e');
      if (isFrom) {
        filteredFrom.clear();
      } else {
        filteredTo.clear();
      }
    }
  }

  void selectLocation(CitySuggestionModel location, {required bool isFrom}) {
    if (isFrom) {
      selectedFrom.value = location;
      fromController.text = location.city; // Show only city name
      filteredFrom.clear();
      // Also update To suggestions to remove this city
      if (filteredTo.isNotEmpty) {
        filteredTo.removeWhere((s) => s.city == location.city);
      }
    } else {
      selectedTo.value = location;
      toController.text = location.city; // Show only city name
      filteredTo.clear();
      // Also update From suggestions to remove this city
      if (filteredFrom.isNotEmpty) {
        filteredFrom.removeWhere((s) => s.city == location.city);
      }
    }
  }

  // Swap locations logic
  void swapLocations() {
    final tempLoc = selectedFrom.value;
    selectedFrom.value = selectedTo.value;
    selectedTo.value = tempLoc;

    String tempText = fromController.text;
    fromController.text = toController.text;
    toController.text = tempText;

    // Clear suggestions after swap
    filteredFrom.clear();
    filteredTo.clear();
  }

  // Select date using native calendar picker
  void selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.red,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
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

  // Update passenger count
  void incrementPassengers() {
    if (passengerCount.value < 10) passengerCount.value++;
  }

  void decrementPassengers() {
    if (passengerCount.value > 1) passengerCount.value--;
  }

  // Recent Searches Logic
  Future<void> loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? searchesJson = prefs.getStringList('recent_searches');
    if (searchesJson != null) {
      recentSearches.assignAll(
        searchesJson
            .map((s) => RecentSearchModel.fromJson(jsonDecode(s)))
            .toList(),
      );
    }
  }

  Future<void> clearRecentSearches() async {
    recentSearches.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('recent_searches');
  }

  void selectRecentSearch(RecentSearchModel search) {
    fromController.text = search.fromName;
    toController.text = search.toName;

    // Create CitySuggestionModel from recent search
    selectedFrom.value = CitySuggestionModel(
      city: search.fromName,
      fullName: search.fromName,
      placeId: search.fromId,
    );
    selectedTo.value = CitySuggestionModel(
      city: search.toName,
      fullName: search.toName,
      placeId: search.toId,
    );

    searchBuses();
  }

  // Action: Search Buses
  void searchBuses() {
    if (selectedFrom.value == null || selectedTo.value == null) {
      Get.snackbar(
        'Error',
        'Please select valid From and To cities',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (selectedFrom.value!.city == selectedTo.value!.city) {
      Get.snackbar(
        'Error',
        'From and To cities cannot be the same',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Save recent search
    final newSearch = RecentSearchModel(
      fromId: selectedFrom.value!.city,
      fromName: selectedFrom.value!.city,
      toId: selectedTo.value!.city,
      toName: selectedTo.value!.city,
      timestamp: DateTime.now(),
    );

    // Remove duplicates and add to recent searches
    recentSearches.removeWhere((s) => s.fromId == selectedFrom.value!.city && s.toId == selectedTo.value!.city);
    recentSearches.insert(0, newSearch);

    // Keep only last 5
    if (recentSearches.length > 5) {
      recentSearches.removeLast();
    }

    _saveRecentSearches();

    Get.toNamed(
      '/search-results',
      arguments: {
        'fromCity': selectedFrom.value!.city,
        'toCity': selectedTo.value!.city,
        'date': selectedDate.value,
        'passengers': passengerCount.value,
      },
    );
  }

  Future<void> _saveRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'recent_searches',
      recentSearches.map((s) => jsonEncode(s.toJson())).toList(),
    );
  }
}
