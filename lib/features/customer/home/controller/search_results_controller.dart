import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:savarii/core/services/firestore_service.dart';
import 'package:savarii/models/bus_model.dart';

class SearchResultsController extends GetxController {
  final FirestoreService _firestoreService = Get.find<FirestoreService>();

  // --- Search Parameters ---
  late String fromCity;       // canonical: "City, District, State"
  late String toCity;         // canonical: "City, District, State"
  late String fromCityShort;  // display-only: "City"
  late String toCityShort;    // display-only: "City"
  late DateTime travelDate;
  late int passengers;

  String get travelDetails =>
      "${travelDate.day}/${travelDate.month}/${travelDate.year} • $passengers Travelers";

  // State
  final RxBool isLoading = true.obs;
  final RxList<BusModel> buses = <BusModel>[].obs;
  final RxMap<String, Map<String, int>> seatAvailabilityMap = <String, Map<String, int>>{}.obs; // busId -> {booked, available}

  // UI state
  final RxInt selectedDateIndex = 0.obs;
  final RxString selectedFilter = 'AC'.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>;
    fromCity      = args['fromCity'];       // canonical: "Bahadurpur, Banka, Bihar"
    toCity        = args['toCity'];         // canonical: "Surat, Surat, Gujarat"
    fromCityShort = args['fromCityShort'] ?? fromCity.split(',').first.trim();
    toCityShort   = args['toCityShort']   ?? toCity.split(',').first.trim();
    travelDate = args['date'];
    passengers = args['passengers'];

    fetchResults();
  }

  Future<void> fetchResults() async {
    isLoading.value = true;
    try {
      // 1. Get ALL buses from Firestore
      final allBuses = await _getAllBuses();

      // Filter buses: must serve fromCity → toCity in order
      final filteredBuses = allBuses.where((bus) {
        final searchFrom = fromCity.toLowerCase().trim();
        final searchTo   = toCity.toLowerCase().trim();

        // Helper: does value match either the canonical string or the city-only
        // first segment (backward-compat for buses saved before this update)
        bool matches(String stored, String canonical) {
          final s = stored.toLowerCase().trim();
          if (s == canonical) return true;
          // Fallback: match first segment (city name) of the canonical string
          final canonicalCity = canonical.split(',').first.trim();
          final storedCity    = s.split(',').first.trim();
          return storedCity == canonicalCity;
        }

        // 1. Direct match on main endpoints
        if (matches(bus.fromCity, searchFrom) &&
            matches(bus.toCity, searchTo)) {
          return true;
        }

        // 2. Match intermediate route points (boarding/dropping stops)
        if (bus.route.isNotEmpty) {
          final fromIdx = bus.route.indexWhere(
              (city) => matches(city, searchFrom));
          final toIdx = bus.route.indexWhere(
              (city) => matches(city, searchTo));

          if (fromIdx != -1 && toIdx != -1 && fromIdx < toIdx) {
            return true;
          }
        }

        return false;
      }).toList();

      buses.assignAll(filteredBuses);

      // 3. For each bus, fetch seat availability
      for (var bus in filteredBuses) {
        await _fetchSeatAvailability(bus);
      }
    } catch (e) {
      print('Error fetching search results: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch all buses from Firestore
  Future<List<BusModel>> _getAllBuses() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('buses')
          .where('isActive', isEqualTo: true)
          .get();
      return snapshot.docs
          .map((doc) => BusModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error fetching all buses: $e');
      return [];
    }
  }

  Future<void> _fetchSeatAvailability(BusModel bus) async {
    final formattedDate = '${travelDate.day.toString().padLeft(2, '0')}-${travelDate.month.toString().padLeft(2, '0')}-${travelDate.year}';
    final bookedCount = await _firestoreService.getBookedSeatsCount(bus.id, formattedDate);
    int totalSeats = bus.totalSeats;
    int availableCount = totalSeats - bookedCount;

    seatAvailabilityMap[bus.id] = {
      'booked': bookedCount,
      'available': availableCount,
    };
  }

  void selectDate(int index) {
    selectedDateIndex.value = index;
  }

  void selectFilter(String filter) {
    selectedFilter.value = filter;
  }

  void bookBus(BusModel bus) {
    print("Selecting seats for ${bus.busName}...");
    String formattedDate = "${travelDate.day.toString().padLeft(2, '0')}/${travelDate.month.toString().padLeft(2, '0')}/${travelDate.year}";
    
    Get.toNamed('/seat-selection', arguments: {
      'busId': bus.id,
      'busName': bus.busName,
      'fromCity': fromCity,
      'toCity': toCity,
      'journeyDate': formattedDate,
      'seatPrice': bus.price.toDouble(),
      'vendorId': bus.vendorId,
    });
  }
}
