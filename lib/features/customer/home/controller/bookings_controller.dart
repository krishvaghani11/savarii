import 'package:get/get.dart';
import '../../../../core/constants/app_assets.dart'; // Adjust this path if needed based on your folder structure

class BookingsController extends GetxController {
  // Active Bookings Data
  final RxList<Map<String, dynamic>> activeBookings = [
    {
      'id': 'b1',
      'status': 'Active',
      'subInfo': 'Seat: 12A',
      'title': 'Intercity Express - Volvo AC',
      'from': 'Mumbai',
      'to': 'Pune',
      'datetime': '14 Oct, 08:00 AM',
      'image': AppAssets.busExteriorImage,
      'type': 'bus',
    },
    {
      'id': 'b2',
      'status': 'Active',
      'subInfo': 'Seat: U4',
      'title': 'Royal Travels - Sleeper',
      'from': 'Bangalore',
      'to': 'Chennai',
      'datetime': '18 Oct, 10:30 PM',
      'image': AppAssets.busInteriorImage,
      'type': 'bus',
    },
    {
      'id': 'p1',
      'status': 'Active',
      'subInfo': 'Parcel ID: #PK8921',
      'title': 'FastTrack Logistics',
      'from': 'Delhi',
      'to': 'Jaipur',
      'datetime': '20 Oct, 02:00 PM',
      'image': AppAssets.parcelBoxImage,
      'type': 'parcel',
    },
  ].obs;

  // Completed Bookings Data
  final RxList<Map<String, dynamic>> completedBookings = [
    {
      'id': 'c1',
      'status': 'Completed',
      'subInfo': 'Seat: 12A',
      'title': 'Intercity Express - Volvo AC',
      'from': 'Mumbai',
      'to': 'Pune',
      'datetime': '14 Oct, 08:00 AM',
      'image': AppAssets.busExteriorImage,
      'type': 'bus',
    },
    {
      'id': 'c2',
      'status': 'Completed',
      'subInfo': 'Seat: U4',
      'title': 'Royal Travels - Sleeper',
      'from': 'Bangalore',
      'to': 'Chennai',
      'datetime': '18 Oct, 10:30 PM',
      'image': AppAssets.busInteriorImage,
      'type': 'bus',
    },
    {
      'id': 'p2',
      'status': 'Delivered',
      'subInfo': 'Parcel ID: #PK8921',
      'title': 'FastTrack Logistics',
      'from': 'Delhi',
      'to': 'Jaipur',
      'datetime': '20 Oct, 02:00 PM',
      'image': AppAssets.parcelBoxImage,
      'type': 'parcel',
    },
  ].obs;

  void cancelBooking(String id) {
    print("Requesting cancellation for booking ID: $id");
    Get.snackbar(
      'Cancellation Requested',
      'Your request to cancel this booking has been submitted.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // --- THESE ARE THE METHODS YOUR VIEW WAS LOOKING FOR ---

  void bookAgain(String type) {
    if (type == 'bus') {
      print("Navigating to Book Ticket Screen...");
      Get.toNamed('/book-ticket');
    } else if (type == 'parcel') {
      print("Navigating to Book Parcel Screen...");
      Get.toNamed('/book-parcel');
    }
  }

  void rateTrip(String id) {
    print("Navigating to Review Screen for ID: $id...");
    Get.toNamed('/review-trip', arguments: {'bookingId': id});
  }

  void reportIssue(String id) {
    print("Navigating to Report Issue Screen for ID: $id...");
    // We pass the booking ID so the next screen knows which trip to display
    Get.toNamed('/report-issue', arguments: {'bookingId': id});
  }
}
