import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/firestore_service.dart';
import '../../auth/controllers/auth_controller.dart';

class VendorTravelsDetailController extends GetxController {
  final AuthController _auth = Get.find<AuthController>();
  final FirestoreService _firestore = Get.find<FirestoreService>();

  final RxBool isLoading = true.obs;

  // Business Info
  final RxString travelsName = ''.obs;
  final RxString establishedDate = ''.obs;
  final RxString fleetSize = '0'.obs;
  final RxString rating = '0.0'.obs;
  final RxString routes = '0'.obs;

  final RxString gstNumber = ''.obs;
  final RxString businessType = ''.obs;
  final RxString ownerName = ''.obs;

  // Coverage
  final RxString primaryRoutes = ''.obs;

  // Contact Info
  final RxString primaryMobile = ''.obs;
  final RxString supportEmail = ''.obs;
  final RxString officeAddress = ''.obs;

  final RxString travelsImageUrl = ''.obs; // URL for bus picture

  @override
  void onInit() {
    super.onInit();
    fetchTravelsDetail();
  }

  Future<void> fetchTravelsDetail() async {
    final uid = _auth.uid;
    if (uid != null) {
      isLoading.value = true;
      try {
        final data = await _firestore.getTravelsDetail(uid);
        if (data != null) {
          travelsName.value = data['travelsName'] ?? '';
          establishedDate.value = data['establishedDate'] ?? '';
          gstNumber.value = data['gstNumber'] ?? '';
          businessType.value = data['businessType'] ?? '';
          
          final routesList = List<String>.from(data['primaryRoutes'] ?? []);
          if (routesList.isNotEmpty) {
            primaryRoutes.value = '• ${routesList.join('\n• ')}';
          } else {
            primaryRoutes.value = 'No routes added yet';
          }
          routes.value = routesList.length.toString();

          primaryMobile.value = data['mobileNumber'] ?? '';
          supportEmail.value = data['supportEmail'] ?? '';
          officeAddress.value = "${data['address'] ?? ''}\n${data['city'] ?? ''}, ${data['state'] ?? ''}".trim();
          ownerName.value = data['contactPerson'] ?? ''; // Contact person used as Owner

          if (data['travelsImageUrl'] != null && data['travelsImageUrl'].toString().isNotEmpty) {
            travelsImageUrl.value = data['travelsImageUrl'];
          } else {
            final imageUrl = await _firestore.getTravelsImageUrl(uid);
            if (imageUrl != null) travelsImageUrl.value = imageUrl;
          }
        }
      } catch (e) {
        print("Error fetching travels detail: $e");
      } finally {
        isLoading.value = false;
      }
    }
  }

  void editTravelsDetail() {
    print("Navigating to Edit Travels form...");
    // Redirect to the Add Travels screen
    Get.toNamed('/vendor-add-travels');
  }

  void copyToClipboard(String text, String label) {
    if (text.isEmpty) return;
    print("Copied $text to clipboard");
    Get.snackbar(
      '$label Copied',
      '$text has been copied to your clipboard.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.black87,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  void sendEmail() {
    final email = supportEmail.value;
    if (email.isNotEmpty) {
      print("Opening email client to $email...");
    }
  }
}
