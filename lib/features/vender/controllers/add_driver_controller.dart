import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:savarii/core/services/firestore_service.dart';
import 'package:savarii/features/auth/controllers/auth_controller.dart';
import 'package:uuid/uuid.dart';

class AddDriverController extends GetxController {
  final FirestoreService _firestoreService = Get.find<FirestoreService>();
  final AuthController _authController = Get.find<AuthController>();
  final ImagePicker _picker = ImagePicker();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  var isLoading = false.obs;

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

  // Files
  var profileImage = Rxn<File>();
  var dlFile = Rxn<File>();
  var aadharFile = Rxn<File>();

  // Actions
  Future<void> uploadDrivingLicense() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      dlFile.value = File(image.path);
    }
  }

  Future<void> uploadAadharCard() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      aadharFile.value = File(image.path);
    }
  }

  Future<void> selectPhoto() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      profileImage.value = File(image.path);
    }
  }

  Future<void> takeLivePhoto() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      profileImage.value = File(photo.path);
    }
  }

  Future<void> saveDriverProfile() async {
    print("Save Driver Profile triggered...");
    if (!formKey.currentState!.validate()) {
      print("Form validation failed.");
      return;
    }

    if (profileImage.value == null) {
      print("No profile image selected.");
      Get.snackbar('Image Required', 'Please provide a driver photo');
      return;
    }

    try {
      isLoading.value = true;
      final String vendorId = _authController.uid ?? '';
      final String driverId = const Uuid().v4();
      
      print("Starting upload for driver $driverId (Vendor: $vendorId)...");

      // 1. Upload Images
      String profileImageUrl = '';
      String dlImageUrl = '';
      String aadharImageUrl = '';

      profileImageUrl = await _firestoreService.uploadDriverFile(vendorId, driverId, profileImage.value!, 'profile');
      print("Profile image uploaded: $profileImageUrl");
      
      if (dlFile.value != null) {
        dlImageUrl = await _firestoreService.uploadDriverFile(vendorId, driverId, dlFile.value!, 'dl');
        print("DL image uploaded.");
      }
      
      if (aadharFile.value != null) {
        aadharImageUrl = await _firestoreService.uploadDriverFile(vendorId, driverId, aadharFile.value!, 'aadhar');
        print("Aadhar image uploaded.");
      }

      // 2. Prepare Data
      final driverData = {
        'id': driverId,
        'vendorId': vendorId,
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
        'status': 'AVAILABLE',
        'createdAt': DateTime.now().toIso8601String(),
      };

      print("Saving driver data to Firestore...");
      // 3. Save to Firestore
      await _firestoreService.addDriver(driverData);
      print("Firestore save successful.");

      Get.snackbar(
        'Success',
        'Driver details added successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      print("Navigating back in 500ms...");
      Future.delayed(const Duration(milliseconds: 500), () {
        Get.back();
      });
    } catch (e) {
      print("Error in saveDriverProfile: $e");
      Get.snackbar('Error', 'Failed to save driver: $e');
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