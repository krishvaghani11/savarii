import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VendorContactDeveloperController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController subjectController = TextEditingController();
  final TextEditingController messageController = TextEditingController();

  final String supportEmail = "support@savarii.com";

  void sendEmail() {
    print("Opening default email client to $supportEmail...");
    Get.snackbar(
      'Email Support',
      'Redirecting to your email client...',
      snackPosition: SnackPosition.TOP,
    );
    // TODO: Implement url_launcher to open mailto:$supportEmail
  }

  void startWhatsAppChat() {
    print("Opening WhatsApp chat...");
    Get.snackbar(
      'WhatsApp Live Chat',
      'Redirecting to WhatsApp...',
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF25D366).withOpacity(0.1),
      // WhatsApp green tint
      colorText: const Color(0xFF075E54),
    );
    // TODO: Implement url_launcher to open WhatsApp link
  }

  void sendMessage() {
    if (formKey.currentState!.validate()) {
      print("Sending Message: ${subjectController.text}");

      Get.snackbar(
        'Message Sent',
        'Our support team will get back to you shortly.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.shade50,
        colorText: Colors.green.shade800,
      );

      // Clear the form
      subjectController.clear();
      messageController.clear();

      // Navigate back after a short delay
      Future.delayed(const Duration(seconds: 1), () => Get.back());
    }
  }

  @override
  void onClose() {
    subjectController.dispose();
    messageController.dispose();
    super.onClose();
  }
}
