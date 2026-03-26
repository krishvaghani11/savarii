import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:savarii/routes/app_routes.dart';
import '../../../core/services/firestore_service.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../models/vendor_model.dart';

class VendorProfileController extends GetxController {
  final AuthController _auth = Get.find<AuthController>();
  final FirestoreService _firestore = Get.find<FirestoreService>();

  final Rx<VendorModel?> vendorProfile = Rx<VendorModel?>(null);
  final RxString profileImageUrl = ''.obs;
  final RxString activeTravelsName = ''.obs;

  String get vendorName => vendorProfile.value?.name ?? 'Vendor';
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
  String get vendorBusinessName {
    if (activeTravelsName.value.isNotEmpty) return activeTravelsName.value;
    final b = vendorProfile.value?.businessName;
    if (b != null && b.isNotEmpty) return b;
    return 'Not Set';
  }

  final String trips = "1,248";
  final String rating = "4.8";
  final String vehicles = "12";

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
      _firestore.getTravelsDetailStream(uid).listen((data) {
        if (data != null && data['travelsName'] != null) {
          activeTravelsName.value = data['travelsName'];
        }
      });
      _loadProfileImage(uid);
    }
  }

  Future<void> _loadProfileImage(String uid) async {
    final url = await _firestore.getProfileImageUrl(uid);
    if (url != null) {
      profileImageUrl.value = url;
    }
  }

  // Actions
  void editProfileImage() {}

  void openMenu() => print("Opening top right menu...");

  void editProfileInfo() {
    print("Navigating to Edit Profile...");
    Get.toNamed(AppRoutes.vendorEditProfile);
  }

  void addTravels() {
    print("Navigating to Add Travels...");
    Get.toNamed('/vendor-add-travels');
  }

  void goToTravelsDetail() {
    print("Navigating to Travels Detail...");
    Get.toNamed('/vendor-travels-detail');
  }

  void goToSettings() {
    print("Navigating to Settings...");
    // Assuming you have a settings route you want to reuse or build later
    Get.toNamed('/vendor-settings');
  }

  void logout() {
    print("Logging out...");
    Get.snackbar(
      'Logged Out',
      'You have been successfully logged out.',
      snackPosition: SnackPosition.BOTTOM,
    );
    _auth.logout(); // Explicitly terminate the session completely
  }
}
