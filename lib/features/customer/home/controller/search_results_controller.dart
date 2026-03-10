import 'package:get/get.dart';

class SearchResultsController extends GetxController {
  // --- Dummy Data ---
  final String fromCity = "Mumbai";
  final String toCity = "Pune";
  final String travelDetails = "Today • 2 Travelers";

  // Selected date index
  final RxInt selectedDateIndex = 0.obs;

  // Selected filter (for UI toggle demonstration)
  final RxString selectedFilter = 'AC'.obs;

  // Bus List Data
  final List<Map<String, dynamic>> buses = [
    {
      'name': 'Savarii Express',
      'rating': '4.8',
      'ratingsCount': '124',
      'price': '850',
      'oldPrice': '1,200',
      'departureTime': '06:00',
      'arrivalTime': '10:00',
      'duration': '4h 00m',
      'amenities': 'AC Sleeper',
      'seatsLeft': '12',
    },
    {
      'name': 'Royal Travels',
      'rating': '4.2',
      'ratingsCount': '86',
      'price': '750',
      'oldPrice': null,
      'priceSubtext': 'onwards',
      'departureTime': '07:30',
      'arrivalTime': '11:45',
      'duration': '4h 15m',
      'amenities': 'AC Seater',
      'seatsLeft': '25',
    },
    {
      'name': 'Intercity Smart',
      'rating': '4.6',
      'ratingsCount': '210',
      'price': '920',
      'oldPrice': null,
      'priceSubtext': 'Fixed',
      'departureTime': '09:15',
      'arrivalTime': '13:00',
      'duration': '3h 45m',
      'amenities': 'WiFi + AC',
      'seatsLeft': '5',
    },
  ];

  void selectDate(int index) {
    selectedDateIndex.value = index;
  }

  void selectFilter(String filter) {
    selectedFilter.value = filter;
  }

  void bookBus(String busName) {
    print("Selecting seats for $busName...");
    // TODO: Navigate to Seat Selection Screen
    // Get.toNamed('/seat-selection');
    Get.toNamed('/seat-selection', arguments: {'busName': busName});
  }
}
