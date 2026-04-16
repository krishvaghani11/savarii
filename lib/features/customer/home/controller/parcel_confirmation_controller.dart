import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:savarii/core/services/ticket_pdf_service.dart';

class ParcelConfirmationController extends GetxController {
  late final String trackingId;
  late final String pickupLocation;
  late final String pickupTime;
  late final String dropoffLocation;
  late final String dropoffTime;
  
  Map<String, dynamic> parcelData = {};

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    parcelData = args;

    trackingId = args['trackingId'] ?? '#SAV-0000';
    pickupLocation = args['pickupCity'] ?? 'Origin';
    pickupTime = args['estimatedPickupTime'] ?? '--:--';
    dropoffLocation = args['dropCity'] ?? 'Destination';
    dropoffTime = args['estimatedDropoffTime'] ?? '--:--';
  }

  void copyTrackingId() {
    Clipboard.setData(ClipboardData(text: trackingId));
    Get.snackbar(
      'Copied',
      'Tracking ID copied to clipboard.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.black87,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  Future<void> downloadInvoice() async {
    try {
      final pdfData = ParcelDownloadData(
        trackingId: trackingId,
        senderName: parcelData['senderName'] ?? 'Sender',
        senderPhone: parcelData['senderPhone'] ?? '',
        receiverName: parcelData['receiverName'] ?? 'Receiver',
        receiverPhone: parcelData['receiverPhone'] ?? '',
        pickupLocation: pickupLocation,
        dropLocation: dropoffLocation,
        estimatedPickupTime: pickupTime,
        estimatedDropTime: dropoffTime,
        busAndDriver: '${parcelData['busName'] ?? 'Bus'} | ${parcelData['busNumber'] ?? ''}',
        weight: (parcelData['weight'] as num?)?.toDouble() ?? 1.0,
        paymentMethod: parcelData['paymentMethod'] ?? 'Razorpay',
        baseFare: (parcelData['baseFare'] as num?)?.toDouble() ?? 0.0,
        serviceFee: (parcelData['serviceFee'] as num?)?.toDouble() ?? 0.0,
        gst: (parcelData['tax'] as num?)?.toDouble() ?? 0.0,
        totalPaid: (parcelData['totalPaid'] as num?)?.toDouble() ?? 0.0,
      );

      await TicketPdfService().downloadParcel(pdfData);
    } catch (e) {
      Get.snackbar('Error', 'Could not generate invoice: $e');
    }
  }

  void trackParcel() {
    print("Navigating to Track Parcel Screen...");
    // TODO: Create and route to the Track Parcel screen
  }

  void backToHome() {
    Get.until((route) => Get.currentRoute == '/main-layout' || route.isFirst);
  }
}