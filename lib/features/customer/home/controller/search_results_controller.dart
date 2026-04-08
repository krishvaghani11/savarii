import 'package:get/get.dart';
import 'package:savarii/core/services/firestore_service.dart';
import 'package:savarii/models/bus_model.dart';

class SearchResultsController extends GetxController {
  final FirestoreService _firestoreService = Get.find<FirestoreService>();

  // --- Search Parameters ---
  late String fromId;
  late String fromCity;
  late String toId;
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
    fromId = args['fromId'];
    fromCity = args['fromName'];
    toId = args['toId'];
    toCity = args['toName'];
    travelDate = args['date'];
    passengers = args['passengers'];

    fetchResults();
  }

  Future<void> fetchResults() async {
    isLoading.value = true;
    try {
      // 1. Get buses where route contains fromId
      final allBusesMatchedFrom = await _firestoreService.searchBuses(fromId);
      
      // 2. Filter in-app: indexOf(fromId) < indexOf(toId)
      final filteredBuses = allBusesMatchedFrom.where((bus) {
        final fromIndex = bus.route.indexOf(fromId);
        final toIndex = bus.route.indexOf(toId);
        return fromIndex != -1 && toIndex != -1 && fromIndex < toIndex;
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

  Future<void> _fetchSeatAvailability(BusModel bus) async {
    final seatList = await _firestoreService.getSeatList(bus.id);
    int bookedCount = seatList.where((s) => s['isBooked'] == true).length;
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
    Get.toNamed('/seat-selection', arguments: {
      'busId': bus.id,
      'busName': bus.busName,
      'fromId': fromId,
      'fromName': fromCity,
      'toId': toId,
      'toName': toCity,
      'date': travelDate,
    });
  }
}
