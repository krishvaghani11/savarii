import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:savarii/core/services/auth_services.dart';
import 'package:savarii/core/services/firestore_service.dart';

class EditProfileController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final FirestoreService _firestoreService = Get.find<FirestoreService>();

  // Global key to manage and validate the form
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Text Controllers for input fields
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  
  final RxString selectedGender = 'Male'.obs;
  final RxString profileImageUrl = ''.obs;
  
  final RxBool isLoading = false.obs;
  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    _loadCustomerProfile();
  }

  Future<void> _loadCustomerProfile() async {
    final uid = _authService.currentUser?.uid;
    if (uid != null) {
      isLoading.value = true;
      try {
        final data = await _firestoreService.getCustomerProfile(uid);
        if (data != null) {
          nameController.text = data['name'] ?? '';
          emailController.text = data['email'] ?? _authService.currentUser?.email ?? '';
          phoneController.text = data['phone'] ?? '';
          dobController.text = data['dob'] ?? '';
          if (data['gender'] != null) {
            selectedGender.value = data['gender'];
          }
          profileImageUrl.value = data['profileImageUrl'] ?? '';
        } else {
          // Pre-fill email if document doesn't exist
          emailController.text = _authService.currentUser?.email ?? '';
        }
      } catch (e) {
        print("Error loading profile: $e");
      } finally {
        isLoading.value = false;
      }
    }
  }

  void selectGender(String gender) {
    selectedGender.value = gender;
  }

  // Action Methods
  Future<void> saveProfile() async {
    if (formKey.currentState!.validate()) {
      final uid = _authService.currentUser?.uid;
      if (uid == null) return;

      isLoading.value = true;
      try {
        final profileData = {
          'name': nameController.text.trim(),
          'email': emailController.text.trim(),
          'phone': phoneController.text.trim(),
          'dob': dobController.text.trim(),
          'gender': selectedGender.value,
          'updatedAt': DateTime.now().toIso8601String(),
        };

        await _firestoreService.updateCustomerProfile(uid, profileData);

        Get.back();
        Get.snackbar(
          'Profile Updated',
          'Data successfully updated!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } catch (e) {
        print("Error saving profile: $e");
        Get.snackbar(
          'Error',
          'Failed to update profile. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } finally {
        isLoading.value = false;
      }
    }
  }

  Future<void> changeProfilePicture(BuildContext context) async {
    // Show Bottom Sheet to choose Camera or Gallery
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Photo Library'),
                  onTap: () {
                    _pickAndUploadImage(ImageSource.gallery);
                    Navigator.of(context).pop();
                  }),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  _pickAndUploadImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      }
    );
  }

  Future<void> _pickAndUploadImage(ImageSource source) async {
    final uid = _authService.currentUser?.uid;
    if (uid == null) return;

    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 70, // compress slightly
      );

      if (image != null) {
        isLoading.value = true;
        // Upload image
        final downloadUrl = await _firestoreService.uploadCustomerProfileImage(
            uid, File(image.path));
        
        // Save to firestore under customer document
        await _firestoreService.updateCustomerProfile(uid, {
          'profileImageUrl': downloadUrl,
        });

        // Update local state
        profileImageUrl.value = downloadUrl;
        
        Get.snackbar(
          'Image Uploaded',
          'Your profile picture was successfully updated!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print("Error picking/uploading image: $e");
      Get.snackbar(
        'Upload Failed',
        'There was an error uploading your picture.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void changePassword() {
    print("Navigating to Change Password flow...");
    // TODO: Navigate to Change Password screen
  }

  void deleteAccount() {
    print("Requesting Account Deletion...");
    // TODO: Show confirmation dialog, then proceed to deletion
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    dobController.dispose();
    super.onClose();
  }
}
