import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/firestore_service.dart';
import '../../auth/controllers/auth_controller.dart';

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

  final FirestoreService _firestore = Get.find();
  final AuthController _authController = Get.find();

  Future<void> completeRegistration() async {
    if (!formKey.currentState!.validate()) return;

    try {
      final uid = _authController.uid!;

      /// SAVE USER
      await _firestore.createUser(uid, {
        "phone": _authController.phone.value,
        "role": "vendor",
        "createdAt": DateTime.now(),
      });

      /// SAVE VENDOR DATA
      await _firestore.createVendor(uid, {
        "userId": uid,
        "travelsName": travelsNameController.text,
        "fullName": fullNameController.text,
        "email": emailController.text,
        "currentAddress": currentAddressController.text,
        "permanentAddress": permanentAddressController.text,
        "createdAt": DateTime.now(),
      });

      Get.snackbar("Success", "Registration completed");

      Get.offAllNamed('/vendor-location-access');
    } catch (e) {
      Get.snackbar("Error", e.toString());
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
