import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VendorRegistrationController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController travelsNameController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController currentAddressController =
      TextEditingController();
  final TextEditingController permanentAddressController =
      TextEditingController();

  void completeRegistration() {
    if (formKey.currentState!.validate()) {
      print("--- Vendor Registration Submitted ---");
      print("Agency: ${travelsNameController.text}");
      print("Owner: ${fullNameController.text}");
      print("Phone: +91 ${mobileController.text}");

      Get.snackbar(
        'Registration Successful',
        'Welcome to Savarii! Your vendor account is under review.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade50,
        colorText: Colors.green.shade800,
        duration: const Duration(seconds: 3),
      );

      // TODO: Navigate to the Vendor Dashboard/Home screen
      Get.offAllNamed('/vendor-main');
    }
  }

  @override
  void onClose() {
    travelsNameController.dispose();
    fullNameController.dispose();
    mobileController.dispose();
    emailController.dispose();
    currentAddressController.dispose();
    permanentAddressController.dispose();
    super.onClose();
  }
}
