import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VendorAddTravelsController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Text Controllers
  final TextEditingController travelsNameController = TextEditingController();
  final TextEditingController regNoController = TextEditingController();
  final TextEditingController gstController = TextEditingController();

  final TextEditingController contactPersonController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  final TextEditingController addressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();

  // Dropdown States
  final RxString selectedBusinessType = 'Select business type'.obs;
  final RxString selectedState = 'Select state'.obs;

  final List<String> businessTypes = [
    'Select business type',
    'Sole Proprietorship',
    'Partnership',
    'Private Limited',
    'Public Limited',
  ];

  final List<String> states = [
    'Select state',
    'Gujarat',
    'Maharashtra',
    'Delhi',
    'Rajasthan',
    'Karnataka',
  ];

  void registerTravels() {
    if (formKey.currentState!.validate()) {
      if (selectedBusinessType.value == 'Select business type' ||
          selectedState.value == 'Select state') {
        Get.snackbar(
          'Missing Details',
          'Please select a business type and state.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      print("Registering Travels: ${travelsNameController.text}");

      Get.snackbar(
        'Registration Successful',
        'New travels agency has been added successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade50,
        colorText: Colors.green.shade800,
      );

      // Navigate back after a short delay
      Future.delayed(const Duration(seconds: 1), () => Get.back());
    }
  }

  @override
  void onClose() {
    travelsNameController.dispose();
    regNoController.dispose();
    gstController.dispose();
    contactPersonController.dispose();
    mobileController.dispose();
    emailController.dispose();
    addressController.dispose();
    cityController.dispose();
    super.onClose();
  }
}
