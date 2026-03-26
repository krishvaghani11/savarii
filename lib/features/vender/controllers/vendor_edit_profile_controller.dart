import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/services/firestore_service.dart';
import '../../auth/controllers/auth_controller.dart';
import 'vendor_profile_controller.dart';
import 'vendor_home_controller.dart';

class VendorEditProfileController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final AuthController _auth = Get.find<AuthController>();
  final FirestoreService _firestore = Get.find<FirestoreService>();
  final VendorProfileController _profileController = Get.find<VendorProfileController>();

  // Text Controllers
  late final TextEditingController fullNameController;
  late final TextEditingController mobileController;
  late final TextEditingController emailController;
  late final TextEditingController travelsNameController;

  final RxBool isLoading = false.obs;
  final Rx<File?> selectedImage = Rx<File?>(null);
  final RxString existingImageUrl = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final vendor = _profileController.vendorProfile.value;

    existingImageUrl.value = _profileController.profileImageUrl.value;
    fullNameController = TextEditingController(text: vendor?.name ?? "");
    mobileController = TextEditingController(text: vendor?.phone ?? "");
    emailController = TextEditingController(
      text: vendor?.email ?? _auth.firebaseUser.value?.email ?? "",
    );
    travelsNameController = TextEditingController(
      text: vendor?.businessName ?? "",
    );
  }

  Future<void> changePhoto() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800, // Reasonable size for storage
        maxHeight: 800,
        imageQuality: 70,
      );
      if (image != null) {
        selectedImage.value = File(image.path);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> saveChanges() async {
    if (formKey.currentState!.validate()) {
      final uid = _auth.uid;
      if (uid == null) {
        Get.snackbar('Error', 'User not logged in');
        return;
      }

      isLoading.value = true;
      try {
        if (selectedImage.value != null) {
          // Upload to Firebase Storage
          await _firestore.uploadProfileImage(uid, selectedImage.value!);
          // Update the local observable in VendorProfileController so it updates everywhere instantly
          final newUrl = await _firestore.getProfileImageUrl(uid);
          if (newUrl != null) {
             _profileController.profileImageUrl.value = newUrl;
             // Also update VendorHomeController if it's active so Home and Drawer update immediately
             if (Get.isRegistered<VendorHomeController>()) {
               Get.find<VendorHomeController>().vendorProfileImageUrl.value = newUrl;
             }
          }
        }

        final data = {
          'name': fullNameController.text.trim(),
          'phone': mobileController.text.trim(),
          'email': emailController.text.trim(),
          'businessName': travelsNameController.text.trim(),
        };

        await _firestore.updateVendorProfile(uid, data);
        
        Get.snackbar(
          'Profile Updated',
          'Your information has been successfully saved.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade50,
          colorText: Colors.green.shade800,
        );

        Future.delayed(const Duration(seconds: 1), () => Get.back());
      } catch (e) {
        Get.snackbar(
          'Error',
          'Failed to update profile: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade50,
          colorText: Colors.red.shade800,
        );
      } finally {
        isLoading.value = false;
      }
    }
  }

  @override
  void onClose() {
    fullNameController.dispose();
    mobileController.dispose();
    emailController.dispose();
    travelsNameController.dispose();
    super.onClose();
  }
}

