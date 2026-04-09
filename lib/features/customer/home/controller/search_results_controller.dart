import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:savarii/core/services/firestore_service.dart';
import 'package:savarii/models/bus_model.dart';

class SearchResultsController extends GetxController {
  final FirestoreService _firestoreService = Get.find<FirestoreService>();

  // --- Search Parameters ---
  late String fromCity;
  late String toCity;
  late DateTime travelDate;
  late int passengers;

  String get travelDetails => "${travelDate.day}/${travelDate.month}/${travelDate.year} • $passengers Travelers";

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
    fromCity = args['fromCity'];
    toCity = args['toCity'];
    travelDate = args['date'];
    passengers = args['passengers'];

    fetchResults();
  }

  Future<void> fetchResults() async {
    isLoading.value = true;
    try {
      // 1. Get ALL buses from Firestore
      final allBuses = await _getAllBuses();

      // 2. Filter buses: must have fromCity and toCity in route (fromCity before toCity)
      final filteredBuses = allBuses.where((bus) {
        final searchFromCity = fromCity.toLowerCase().trim();
        final searchToCity = toCity.toLowerCase().trim();

        // 1. Direct match on main endpoints
        final busFromCity = bus.fromCity.toLowerCase().trim();
        final busToCity = bus.toCity.toLowerCase().trim();
        if (busFromCity == searchFromCity && busToCity == searchToCity) {
          return true;
        }

        // 2. Match intermediate route points
        if (bus.route.isNotEmpty) {
          final normalizedRoute = bus.route.map((city) => city.toLowerCase().trim()).toList();
          final fromIndex = normalizedRoute.indexOf(searchFromCity);
          final toIndex = normalizedRoute.indexOf(searchToCity);

          // Both cities must be in the route, and the boarding point must be before the dropping point
          if (fromIndex != -1 && toIndex != -1 && fromIndex < toIndex) {
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
      final snapshot = await FirebaseFirestore.instance.collection('buses').get();
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
    });
  }
}
