import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:savarii/core/services/firestore_service.dart';
import 'package:savarii/models/location_model.dart';
import 'package:savarii/models/recent_search_model.dart';

class BookTicketController extends GetxController {
  final FirestoreService _firestoreService = Get.find<FirestoreService>();

  // 1. Text Controllers for locations
  final TextEditingController fromController = TextEditingController();
  final TextEditingController toController = TextEditingController();

  // 2. Reactive variables for date and passengers
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxInt passengerCount = 1.obs;

  // 3. Location Data
  final RxList<LocationModel> allLocations = <LocationModel>[].obs;
  final RxList<LocationModel> filteredFrom = <LocationModel>[].obs;
  final RxList<LocationModel> filteredTo = <LocationModel>[].obs;

  final Rxn<LocationModel> selectedFrom = Rxn<LocationModel>();
  final Rxn<LocationModel> selectedTo = Rxn<LocationModel>();

  // 4. Recent Searches
  final RxList<RecentSearchModel> recentSearches = <RecentSearchModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _fetchLocations();
    loadRecentSearches();
    
    // Listeners for autocomplete
    fromController.addListener(() {
      _filterLocations(fromController.text, isFrom: true);
    });
    toController.addListener(() {
      _filterLocations(toController.text, isFrom: false);
    });
  }

  Future<void> _fetchLocations() async {
    final locations = await _firestoreService.getLocations();
    allLocations.assignAll(locations);
  }

  void _filterLocations(String query, {required bool isFrom}) {
    if (query.isEmpty) {
      if (isFrom) filteredFrom.clear();
      else filteredTo.clear();
      return;
    }
    final filtered = allLocations
        .where((loc) => loc.name.toLowerCase().contains(query.toLowerCase()) || 
                         loc.city.toLowerCase().contains(query.toLowerCase()))
        .toList();
    if (isFrom) filteredFrom.assignAll(filtered);
    else filteredTo.assignAll(filtered);
  }

  void selectLocation(LocationModel location, {required bool isFrom}) {
    if (isFrom) {
      selectedFrom.value = location;
      fromController.text = location.name;
      filteredFrom.clear();
    } else {
      selectedTo.value = location;
      toController.text = location.name;
      filteredTo.clear();
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
        searchesJson.map((s) => RecentSearchModel.fromJson(jsonDecode(s))).toList()
      );
    }
  }

  Future<void> saveRecentSearch(LocationModel from, LocationModel to) async {
    final newSearch = RecentSearchModel(
      fromId: from.id,
      fromName: from.name,
      toId: to.id,
      toName: to.name,
      timestamp: DateTime.now(),
    );

    // Remove duplicates
    recentSearches.removeWhere((s) => s.fromId == from.id && s.toId == to.id);
    recentSearches.insert(0, newSearch);

    // Keep only last 5
    if (recentSearches.length > 5) {
      recentSearches.removeLast();
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'recent_searches',
      recentSearches.map((s) => jsonEncode(s.toJson())).toList()
    );
  }

  Future<void> clearRecentSearches() async {
    recentSearches.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('recent_searches');
  }

  void selectRecentSearch(RecentSearchModel search) {
    fromController.text = search.fromName;
    toController.text = search.toName;
    
    // Find the actual objects if they exist in cache
    selectedFrom.value = allLocations.firstWhereOrNull((l) => l.id == search.fromId);
    selectedTo.value = allLocations.firstWhereOrNull((l) => l.id == search.toId);
    
    searchBuses();
  }

  // Action: Search Buses
  void searchBuses() {
    if (selectedFrom.value == null || selectedTo.value == null) {
      Get.snackbar('Error', 'Please select valid From and To locations',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if (selectedFrom.value!.id == selectedTo.value!.id) {
      Get.snackbar('Error', 'From and To locations cannot be the same',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    saveRecentSearch(selectedFrom.value!, selectedTo.value!);

    Get.toNamed('/search-results', arguments: {
      'fromId': selectedFrom.value!.id,
      'fromName': selectedFrom.value!.name,
      'toId': selectedTo.value!.id,
      'toName': selectedTo.value!.name,
      'date': selectedDate.value,
      'passengers': passengerCount.value,
    });
  }
}
