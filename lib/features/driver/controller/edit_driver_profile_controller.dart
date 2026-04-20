import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:savarii/core/services/firestore_service.dart';
import 'package:savarii/features/auth/controllers/auth_controller.dart';
import 'package:savarii/core/theme/app_colors.dart';
import 'package:savarii/features/driver/controller/driver_profile_controller.dart';
import 'package:savarii/features/driver/controller/driver_main_controller.dart';

class EditDriverProfileController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  final FirestoreService _firestoreService = Get.find<FirestoreService>();
  final AuthController _authController = Get.find<AuthController>();

  // Reactive state for the profile picture URL
  final RxString profilePicUrl = ''.obs;
  final Rx<File?> localProfilePic = Rx<File?>(null);
  final RxBool isLoading = false.obs;
  
  String _originalPhone = "";
  
  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    _fetchExistingProfile();
  }

  Future<void> _fetchExistingProfile() async {
    final String? uid = _authController.uid;
    if (uid == null) return;

    try {
      isLoading.value = true;
      final doc = await FirebaseFirestore.instance.collection('drivers').doc(uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        nameController.text = data['name'] ?? '';
        phoneController.text = data['phone'] ?? '';
        emailController.text = data['email'] ?? '';
        profilePicUrl.value = data['profileImageUrl'] ?? data['profileImage'] ?? '';
        
        _originalPhone = data['phone'] ?? '';
      }
    } catch (e) {
      print("Error fetching existing driver profile loop: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void changeProfilePhoto() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Update Profile Photo', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
            const SizedBox(height: 16),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppColors.secondaryGreyBlue.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.photo_library, color: AppColors.primaryAccent),
              ),
              title: const Text('Select from Gallery', style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () {
                Get.back();
                _pickImage(ImageSource.gallery);
              },
            ),
            const Divider(),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppColors.secondaryGreyBlue.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.camera_alt, color: AppColors.primaryAccent),
              ),
              title: const Text('Take a Photo', style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () {
                Get.back();
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      localProfilePic.value = File(image.path);
    }
  }

  Future<void> saveChanges() async {
    if (!formKey.currentState!.validate()) return;
    
    final String? uid = _authController.uid;
    if (uid == null) return;

    try {
      isLoading.value = true;
      String currentProfileUrl = profilePicUrl.value;

      // 1. If physical new photo selected, push to storage
      if (localProfilePic.value != null) {
        currentProfileUrl = await _firestoreService.uploadProfileImage(uid, localProfilePic.value!);
        profilePicUrl.value = currentProfileUrl;
      }

      // 2. Query vendor records using the original phone/email securely to find any decoupled links
      final querySnapshot = await FirebaseFirestore.instance
          .collection('drivers')
          .where('phone', isEqualTo: _originalPhone.isNotEmpty ? _originalPhone : phoneController.text.trim())
          .get();

      if (querySnapshot.docs.isNotEmpty) {
          final targetDoc = querySnapshot.docs.first;
          await targetDoc.reference.update({
            'name': nameController.text.trim(),
            'phone': phoneController.text.trim(),
            'email': emailController.text.trim(),
            'profileImageUrl': currentProfileUrl,
            'profileImage': currentProfileUrl, // Crucial for Vendor UI matching!
          });
      } else {
          // Fallback if lookup magically failed
          await FirebaseFirestore.instance.collection('drivers').doc(uid).update({
            'name': nameController.text.trim(),
            'phone': phoneController.text.trim(),
            'email': emailController.text.trim(),
            'profileImageUrl': currentProfileUrl,
            'profileImage': currentProfileUrl,
          });
      }

      // Refresh the profile data before navigating
      try {
        Get.find<DriverProfileController>().fetchDriverDetails();
      } catch (_) {}

      // Navigate back and switch bottom nav to Profile tab (index 1)
      Get.back();
      try {
        Get.find<DriverMainController>().changeTab(1);
      } catch (_) {}

      Get.snackbar(
        'Success',
        'Profile updated successfully.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(12),
      );
    } catch (e) {
      print("Error saving driver changes: $e");
      Get.snackbar(
        'Update Failed',
        'We encountered an error. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade800,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void closeScreen() {
    Get.back();
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.onClose();
  }
}