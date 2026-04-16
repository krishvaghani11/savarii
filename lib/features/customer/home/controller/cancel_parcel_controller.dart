import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/services/firestore_service.dart';

class CancelParcelController extends GetxController {
  final FirestoreService _firestoreService = Get.find<FirestoreService>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  late String parcelId;
  late String trackingId;
  late String senderPhone;

  final TextEditingController phoneController = TextEditingController();
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    parcelId = args['parcelId'] ?? '';
    trackingId = args['trackingId'] ?? '';
    senderPhone = args['senderPhone'] ?? '';

    // Auto-fill phone number
    phoneController.text = senderPhone;
  }

  Future<void> submitCancellation() async {
    if (!formKey.currentState!.validate()) return;

    if (phoneController.text.trim() != senderPhone) {
      Get.snackbar(
        'Validation Error',
        'The phone number provided does not match our records.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade100,
      );
      return;
    }

    isLoading.value = true;
    try {
      await _firestoreService.updateParcelStatus(parcelId, 'cancelled');
      Get.back(); // Back to list
      Get.snackbar(
        'Success',
        'Parcel booking #$trackingId has been cancelled.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to cancel parcel: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    phoneController.dispose();
    super.onClose();
  }
}
