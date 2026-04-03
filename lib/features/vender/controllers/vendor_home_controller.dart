import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/services/firestore_service.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../models/vendor_model.dart';

class VendorHomeController extends GetxController {
  final AuthController _auth = Get.find<AuthController>();
  final FirestoreService _firestore = Get.find<FirestoreService>();

  final Rx<VendorModel?> vendorProfile = Rx<VendorModel?>(null);
  final RxString vendorProfileImageUrl = ''.obs;

  String get vendorName => vendorProfile.value?.name ?? 'Savarii Vendor';
  String get vendorPhone {
    final p = vendorProfile.value?.phone;
    if (p != null && p.isNotEmpty) return p;
    return 'Not Provided';
  }
  String get vendorEmail {
    final e = vendorProfile.value?.email;
    if (e != null && e.isNotEmpty) return e;
    return FirebaseAuth.instance.currentUser?.email ?? 'No Email';
  }

  final String date = "${DateTime.now().day} ${_getMonth(DateTime.now().month)} ${DateTime.now().year}";

  static String _getMonth(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  // Stats
  final RxString activeBuses = "0".obs;
  final RxString ticketsSold = "0".obs;
  final RxDouble totalEarnings = 0.0.obs;
  final RxList<int> weeklyTicketCounts = List.filled(7, 0).obs;
  final String todaysTrips = "0"; // Used in drawer, optional to make dynamic later

  /// Formatted earnings string for display (e.g. ₹14.2k or ₹850)
  String get earningsDisplay {
    final val = totalEarnings.value;
    if (val >= 1000) {
      return "₹${(val / 1000).toStringAsFixed(1)}k";
    }
    return "₹${val.toStringAsFixed(0)}";
  }

  @override
  void onInit() {
    super.onInit();
    _loadVendorProfile();
  }

  void _loadVendorProfile() {
    final uid = _auth.uid;
    if (uid != null) {
      _firestore.getVendorProfileStream(uid).listen((profile) {
        if (profile != null) {
          vendorProfile.value = profile;
        }
      });
      _loadProfileImage(uid);
      _loadDashboardStats(uid);
    }
  }

  void _loadDashboardStats(String uid) {
    // Listen to buses stream
    _firestore.getVendorBusesStream(uid).listen((buses) {
      final activeCount = buses.where((b) => b['isActive'] == true).length;
      activeBuses.value = activeCount.toString();
    });

    // Listen to tickets stream
    _firestore.getVendorTicketsStream(uid).listen((ticketDocs) {
      ticketsSold.value = ticketDocs.length.toString();

      double earned = 0;
      List<int> counts = List.filled(7, 0);
      final now = DateTime.now();
      final todayMidnight = DateTime(now.year, now.month, now.day);

      for (var doc in ticketDocs) {
        final amount = doc['totalPaid'];
        if (amount != null) {
          earned += (amount is num) ? amount.toDouble() : double.tryParse(amount.toString()) ?? 0.0;
        }

        // Daily ticket counts logic
        if (doc['createdAt'] != null) {
          try {
            final createdAt = DateTime.parse(doc['createdAt']);
            final ticketMidnight = DateTime(createdAt.year, createdAt.month, createdAt.day);
            final differenceInDays = todayMidnight.difference(ticketMidnight).inDays;
            
            if (differenceInDays >= 0 && differenceInDays < 7) {
              // index 6 is today, 5 is yesterday... 0 is 6 days ago.
              counts[6 - differenceInDays] += 1;
            }
          } catch (e) {
            // ignore if unparseable
          }
        }
      }

      totalEarnings.value = earned;
      weeklyTicketCounts.value = counts;
    });
  }

  Future<void> _loadProfileImage(String uid) async {
    final url = await _firestore.getProfileImageUrl(uid);
    if (url != null) {
      vendorProfileImageUrl.value = url;
    }
  }

  void openNotifications() => print("Opening notifications...");

  // Dashboard Actions
  void addBusAndRoute() {
    print("Navigating to Add Bus...");
    Get.toNamed('/add-bus');
  }

  void viewBusTickets() {
    print("Navigating to View Tickets...");
    Get.toNamed('/vendor-view-tickets');
  }

  void bookTicket() {
    print("Navigating to Manual Booking...");
    Get.toNamed('/vendor-book-ticket');
  }

  void busTracking() {
    print("Navigating to Fleet Tracking...");
    Get.toNamed('/vendor-fleet-tracking');
  }

  // Sidebar Actions
  void closeDrawer() => Get.back();

  void goToLanguage() {
    print("Navigating to Language Selection from Sidebar...");
    Get.back(); // Closes the drawer first
    Get.toNamed('/vendor-language');
  }

  void contactDeveloper() {
    print("Opening Contact Developer...");
    Get.back(); // Closes the drawer first
    Get.toNamed('/vendor-contact-developer');
  }

  void logout() {
    print("Logging out Vendor...");
    _auth.logout(); // Explicitly terminate the session through AuthController
  }
}
