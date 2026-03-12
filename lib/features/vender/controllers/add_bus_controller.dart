import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddBusController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Text Controllers
  final TextEditingController busNameController = TextEditingController();
  final TextEditingController busNumberController = TextEditingController();
  final TextEditingController totalSeatsController = TextEditingController();
  final TextEditingController fromController = TextEditingController();
  final TextEditingController toController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController driverNameController = TextEditingController();
  final TextEditingController driverMobileController = TextEditingController();
  final TextEditingController licenseController = TextEditingController();

  // Reactive States
  final RxString selectedBusType = 'AC Sleeper'.obs;
  final RxString departureTime = '--:-- --'.obs;
  final RxString arrivalTime = '--:-- --'.obs;

  final List<String> busTypes = [
    'AC Sleeper',
    'Non-AC Sleeper',
    'AC Seater',
    'Non-AC Seater',
    'Luxury',
  ];

  void selectBusType(String type) {
    selectedBusType.value = type;
  }

  Future<void> pickTime(BuildContext context, bool isDeparture) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFE82E59),
            ), // Brand red
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      // Format time to 12-hour AM/PM format
      final localizations = MaterialLocalizations.of(context);
      final formattedTime = localizations.formatTimeOfDay(
        picked,
        alwaysUse24HourFormat: false,
      );

      if (isDeparture) {
        departureTime.value = formattedTime;
      } else {
        arrivalTime.value = formattedTime;
      }
    }
  }

  void saveBusAndRoute() {
    if (formKey.currentState!.validate()) {
      print("Saving Bus: ${busNameController.text} (${selectedBusType.value})");
      print("Route: ${fromController.text} to ${toController.text}");

      Get.snackbar(
        'Success',
        'Bus & Route added successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade50,
        colorText: Colors.green.shade800,
      );

      Future.delayed(const Duration(seconds: 1), () => Get.back());
    } else {
      Get.snackbar(
        'Error',
        'Please fill all required fields.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  void onClose() {
    busNameController.dispose();
    busNumberController.dispose();
    totalSeatsController.dispose();
    fromController.dispose();
    toController.dispose();
    priceController.dispose();
    driverNameController.dispose();
    driverMobileController.dispose();
    licenseController.dispose();
    super.onClose();
  }
}
