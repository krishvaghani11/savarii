import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:savarii/core/services/firestore_service.dart';
import 'package:savarii/features/auth/controllers/auth_controller.dart';

class EditDriverController extends GetxController {
  final FirestoreService _firestoreService = Get.find<FirestoreService>();
  final AuthController _authController = Get.find<AuthController>();
  final ImagePicker _picker = ImagePicker();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  var isLoading = false.obs;

  late String driverId;
  late String existingProfileImageUrl;
  late String existingDlImageUrl;
  late String existingAadharImageUrl;

  // Personal Details
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController altMobileController = TextEditingController();

  // Identification & License
  final TextEditingController dlController = TextEditingController();
  final TextEditingController aadharController = TextEditingController();

  // Address Details
  final TextEditingController streetController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController pinCodeController = TextEditingController();

  // Files (Nullable since user might not want to change them)
  var newProfileImage = Rxn<File>();
  var newDlFile = Rxn<File>();
  var newAadharFile = Rxn<File>();

  @override
  void onInit() {
    super.onInit();
    final Map<String, dynamic> driver = Get.arguments ?? {};
    driverId = driver['id'] ?? '';
    
    // Populate fields
    nameController.text = driver['name'] ?? '';
    emailController.text = driver['email'] ?? '';
    mobileController.text = driver['phone'] ?? '';
    altMobileController.text = driver['altPhone'] ?? '';
    dlController.text = driver['dlNumber'] ?? '';
    aadharController.text = driver['aadharNumber'] ?? '';
    streetController.text = driver['street'] ?? '';
    cityController.text = driver['city'] ?? '';
    stateController.text = driver['state'] ?? '';
    pinCodeController.text = driver['pinCode'] ?? '';
    
    existingProfileImageUrl = driver['profileImage'] ?? '';
    existingDlImageUrl = driver['dlImage'] ?? '';
    existingAadharImageUrl = driver['aadharImage'] ?? '';
  }

  // Actions
  Future<void> pickDlImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      newDlFile.value = File(image.path);
    }
  }

  Future<void> pickAadharImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      newAadharFile.value = File(image.path);
    }
  }

  Future<void> pickProfilePhoto() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      newProfileImage.value = File(image.path);
    }
  }

  Future<void> takeLivePhoto() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      newProfileImage.value = File(photo.path);
    }
  }

  Future<void> updateDriverProfile() async {
    if (!formKey.currentState!.validate()) return;

    try {
      isLoading.value = true;
      final String vendorId = _authController.uid ?? '';

      // 1. Upload new images if any
      String profileImageUrl = existingProfileImageUrl;
      String dlImageUrl = existingDlImageUrl;
      String aadharImageUrl = existingAadharImageUrl;

      if (newProfileImage.value != null) {
        profileImageUrl = await _firestoreService.uploadDriverFile(vendorId, driverId, newProfileImage.value!, 'profile');
      }
      
      if (newDlFile.value != null) {
        dlImageUrl = await _firestoreService.uploadDriverFile(vendorId, driverId, newDlFile.value!, 'dl');
      }
      
      if (newAadharFile.value != null) {
        aadharImageUrl = await _firestoreService.uploadDriverFile(vendorId, driverId, newAadharFile.value!, 'aadhar');
      }

      // 2. Prepare Updated Data
      final updatedData = {
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'phone': mobileController.text.trim(),
        'altPhone': altMobileController.text.trim(),
        'dlNumber': dlController.text.trim(),
        'aadharNumber': aadharController.text.trim(),
        'street': streetController.text.trim(),
        'city': cityController.text.trim(),
        'state': stateController.text.trim(),
        'pinCode': pinCodeController.text.trim(),
        'profileImage': profileImageUrl,
        'dlImage': dlImageUrl,
        'aadharImage': aadharImageUrl,
      };

      // 3. Update in Firestore
      await _firestoreService.updateDriverData(driverId, updatedData);

      Get.snackbar(
        'Success',
        'Driver details updated successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      Future.delayed(const Duration(milliseconds: 500), () {
        Get.back();
      });
    } catch (e) {
      Get.snackbar('Error', 'Failed to update driver: $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    altMobileController.dispose();
    dlController.dispose();
    aadharController.dispose();
    streetController.dispose();
    cityController.dispose();
    stateController.dispose();
    pinCodeController.dispose();
    super.onClose();
  }
}
