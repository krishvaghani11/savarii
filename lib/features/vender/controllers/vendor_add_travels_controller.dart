import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/services/firestore_service.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../models/travels_model.dart';
import '../../../routes/app_routes.dart';
import 'vendor_main_controller.dart';
import 'vendor_travels_detail_controller.dart';

class VendorAddTravelsController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final AuthController _auth = Get.find<AuthController>();
  final FirestoreService _firestore = Get.find<FirestoreService>();

  // Text Controllers
  final TextEditingController travelsNameController = TextEditingController();
  final TextEditingController regNoController = TextEditingController();
  final TextEditingController gstController = TextEditingController();

  final TextEditingController contactPersonController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  final TextEditingController addressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();

  // New Controller for dynamic routing
  final TextEditingController routeInputController = TextEditingController();

  // Reactive States
  final RxString establishedDate = ''.obs;
  final RxString selectedBusinessType = 'Select business type'.obs;
  final RxString selectedState = 'Select state'.obs;
  final RxBool isLoading = false.obs;
  final Rx<File?> selectedImage = Rx<File?>(null);
  final RxString existingImageUrl = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadExistingData();
  }

  Future<void> _loadExistingData() async {
    final uid = _auth.uid;
    if (uid != null) {
      isLoading.value = true;
      try {
        final data = await _firestore.getTravelsDetail(uid);
        if (data != null) {
          travelsNameController.text = data['travelsName'] ?? '';
          gstController.text = data['gstNumber'] ?? '';
          selectedBusinessType.value = data['businessType'] ?? 'Select business type';
          establishedDate.value = data['establishedDate'] ?? '';
          contactPersonController.text = data['contactPerson'] ?? '';
          mobileController.text = data['mobileNumber'] ?? '';
          emailController.text = data['supportEmail'] ?? '';
          addressController.text = data['address'] ?? '';
          cityController.text = data['city'] ?? '';
          selectedState.value = data['state'] ?? 'Select state';
          
          final routesList = List<String>.from(data['primaryRoutes'] ?? []);
          savedRoutes.assignAll(routesList);

          if (data['travelsImageUrl'] != null && data['travelsImageUrl'].toString().isNotEmpty) {
            existingImageUrl.value = data['travelsImageUrl'];
          } else {
            final imageUrl = await _firestore.getTravelsImageUrl(uid);
            if (imageUrl != null && imageUrl.isNotEmpty) {
              existingImageUrl.value = imageUrl;
            }
          }
        }
      } catch (e) {
        print("Error loading existing travels data: $e");
      } finally {
        isLoading.value = false;
      }
    }
  }

  // List to hold the dynamically added routes
  // CHANGED: Initialized as an empty list so no routes show by default!
  final RxList<String> savedRoutes = <String>[].obs;

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

  // --- Dynamic Route Logic ---
  void addRoute() {
    final routeText = routeInputController.text.trim();
    if (routeText.isNotEmpty) {
      savedRoutes.add(routeText);
      routeInputController.clear(); // Clears the text field after adding
    } else {
      Get.snackbar(
        "Incomplete",
        "Please enter a route before adding.",
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  void removeRoute(int index) {
    savedRoutes.removeAt(index);
  }

  // --- Date Picker Logic ---
  Future<void> pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFE82E59),
            ), // Accent Color
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      // Format to mm/dd/yyyy
      establishedDate.value =
          "${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}";
    }
  }

  // --- Image Picker Logic ---
  Future<void> pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 70,
      );
      if (image != null) {
        selectedImage.value = File(image.path);
        Get.snackbar(
          "Image Selected",
          "Image successfully attached.",
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image: $e', snackPosition: SnackPosition.TOP);
    }
  }

  void registerTravels() async {
    if (formKey.currentState!.validate()) {
      if (selectedBusinessType.value == 'Select business type' ||
          selectedState.value == 'Select state') {
        Get.snackbar(
          'Missing Details',
          'Please select a business type and state.',
          snackPosition: SnackPosition.TOP,
        );
        return;
      }

      if (establishedDate.value.isEmpty) {
        Get.snackbar(
          'Missing Details',
          'Please select the established date.',
          snackPosition: SnackPosition.TOP,
        );
        return;
      }

      if (savedRoutes.isEmpty) {
        Get.snackbar(
          'Missing Details',
          'Please add at least one primary route.',
          snackPosition: SnackPosition.TOP,
        );
        return;
      }

      try {
        isLoading.value = true;
        final uid = _auth.uid;
        if (uid == null) {
          Get.snackbar("Error", "User not authenticated.");
          isLoading.value = false;
          return;
        }

        String? uploadedImageUrl;
        // Upload image if selected
        if (selectedImage.value != null) {
          uploadedImageUrl = await _firestore.uploadTravelsImage(uid, selectedImage.value!);
          // Ensure new images bypass local Flutter image cache
          uploadedImageUrl = "$uploadedImageUrl&v=${DateTime.now().millisecondsSinceEpoch}";
        }

        // Save data to Firestore
        final travelsModel = TravelsModel(
          vendorId: uid,
          travelsName: travelsNameController.text.trim(),
          gstNumber: gstController.text.trim(),
          businessType: selectedBusinessType.value,
          establishedDate: establishedDate.value,
          contactPerson: contactPersonController.text.trim(),
          mobileNumber: mobileController.text.trim(),
          supportEmail: emailController.text.trim(),
          address: addressController.text.trim(),
          city: cityController.text.trim(),
          state: selectedState.value,
          primaryRoutes: savedRoutes.toList(),
          travelsImageUrl: uploadedImageUrl ?? (existingImageUrl.value.isNotEmpty ? existingImageUrl.value : null),
          createdAt: DateTime.now(),
        );

        await _firestore.updateTravelsDetail(uid, travelsModel.toMap());

        // Refresh the detail page if it's active
        if (Get.isRegistered<VendorTravelsDetailController>()) {
          Get.find<VendorTravelsDetailController>().fetchTravelsDetail();
        }

        Get.snackbar(
          'Success',
          'travels detail update successfully',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green.shade50,
          colorText: Colors.green.shade800,
        );

        if (Get.isRegistered<VendorMainController>()) {
          Get.find<VendorMainController>().changeTab(3);
        }
        
        // Pop back to the main layout safely (where the profile tab lives)
        Get.until((route) => route.settings.name == AppRoutes.vendorMain || route.isFirst);
      } catch (e) {
        Get.snackbar("Error", "Failed to register travels: $e");
      } finally {
        isLoading.value = false;
      }
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
    routeInputController.dispose();
    super.onClose();
  }
}
