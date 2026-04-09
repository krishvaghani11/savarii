import 'package:get/get.dart';
import 'package:savarii/core/services/bus_search_service.dart';
import 'package:savarii/core/services/recent_search_manager.dart';
import 'package:savarii/models/bus_search_model.dart';

class SearchController extends GetxController {
  final BusSearchService _busSearchService = Get.find<BusSearchService>();
  final RecentSearchManager _recentSearchManager = RecentSearchManager();

  // Observable state variables
  final Rx<String> selectedFromId = ''.obs;
  final Rx<String> selectedFromName = ''.obs;
  final Rx<String> selectedToId = ''.obs;
  final Rx<String> selectedToName = ''.obs;

  final RxList<BusSearchResult> searchResults = <BusSearchResult>[].obs;
  final RxBool isLoading = false.obs;
  final Rx<String> errorMessage = ''.obs;

  final RxList<RecentSearch> recentSearches = <RecentSearch>[].obs;

  // Cache for locations
  final RxMap<String, String> locationCache = <String, String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeManager();
    _loadLocations();
    _loadRecentSearches();
  }

  /// Initialize the recent search manager
  Future<void> _initializeManager() async {
    try {
      await _recentSearchManager.init();
    } catch (e) {
      print('Error initializing RecentSearchManager: $e');
    }
  }

  /// Load all locations for caching
  Future<void> _loadLocations() async {
    try {
      final locations = await _busSearchService.getAllLocations();
      locationCache.assignAll(locations);
    } catch (e) {
      print('Error loading locations: $e');
    }
  }

  /// Load recent searches from storage
  Future<void> _loadRecentSearches() async {
    try {
      final searches = await _recentSearchManager.getRecentSearches();
      recentSearches.assignAll(searches);
    } catch (e) {
      print('Error loading recent searches: $e');
    }
  }

  /// Set selected from location
  void setFromLocation(String locationId, String locationName) {
    selectedFromId.value = locationId;
    selectedFromName.value = locationName;
    errorMessage.value = '';
  }

  /// Set selected to location
  void setToLocation(String locationId, String locationName) {
    selectedToId.value = locationId;
    selectedToName.value = locationName;
    errorMessage.value = '';
  }

  /// Main search function
  /// Validates input, fetches buses, filters, and enriches with times
  Future<void> searchBuses() async {
    // Reset error message
    errorMessage.value = '';

    // Validation: Check if both locations are selected
    if (selectedFromId.value.isEmpty || selectedToId.value.isEmpty) {
      errorMessage.value = 'Please select both boarding and dropping points';
      return;
    }

    // Validation: Check if from and to are different
    if (selectedFromId.value == selectedToId.value) {
      errorMessage.value = 'Boarding and dropping points cannot be the same';
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Perform search
      final results = await _busSearchService.searchBuses(
        selectedFromId.value,
        selectedToId.value,
      );

      // Check if results are empty
      if (results.isEmpty) {
        errorMessage.value = 'No buses found for this route';
        searchResults.clear();
      } else {
        searchResults.assignAll(results);

        // Save to recent searches
        final recentSearch = RecentSearch(
          fromId: selectedFromId.value,
          fromName: selectedFromName.value,
          toId: selectedToId.value,
          toName: selectedToName.value,
          timestamp: DateTime.now(),
        );
        await _recentSearchManager.saveRecentSearch(recentSearch);

        // Reload recent searches
        await _loadRecentSearches();
      }
    } catch (e) {
      print('Error during search: $e');
      errorMessage.value = 'An error occurred during search. Please try again.';
      searchResults.clear();
    } finally {
      isLoading.value = false;
    }
  }

  /// Use a recent search
  Future<void> useRecentSearch(RecentSearch search) async {
    selectedFromId.value = search.fromId;
    selectedFromName.value = search.fromName;
    selectedToId.value = search.toId;
    selectedToName.value = search.toName;

    await searchBuses();
  }

  /// Clear recent search
  Future<void> clearRecentSearch(String fromId, String toId) async {
    try {
      await _recentSearchManager.deleteRecentSearch(fromId, toId);
      await _loadRecentSearches();
    } catch (e) {
      print('Error clearing recent search: $e');
    }
  }

  /// Clear all recent searches
  Future<void> clearAllRecentSearches() async {
    try {
      await _recentSearchManager.clearRecentSearches();
      recentSearches.clear();
    } catch (e) {
      print('Error clearing all recent searches: $e');
    }
  }

  /// Swap from and to locations
  void swapLocations() {
    final tempId = selectedFromId.value;
    final tempName = selectedFromName.value;

    selectedFromId.value = selectedToId.value;
    selectedFromName.value = selectedToName.value;

    selectedToId.value = tempId;
    selectedToName.value = tempName;
  }

  /// Clear search results
  void clearSearch() {
    searchResults.clear();
    errorMessage.value = '';
  }

  /// Get location name from cache
  String getLocationName(String locationId) {
    return locationCache[locationId] ?? locationId;
  }
}

