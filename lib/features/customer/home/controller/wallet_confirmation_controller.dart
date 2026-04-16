import 'package:get/get.dart';
import '../../../../core/services/ticket_pdf_service.dart';

class WalletConfirmationController extends GetxController {

  // Real data parsed from arguments
  var topUpAmount = ''.obs;
  var transactionId = ''.obs;
  var dateTime = ''.obs;
  var paymentMethodName = ''.obs;
  var paymentMethodType = ''.obs;
  var updatedBalance = ''.obs;

  // Extra fields needed for PDF
  var razorpayPaymentId = ''.obs;
  var accountName = ''.obs;
  var mobile = ''.obs;
  var remarks = ''.obs;
  var rawAmount = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    topUpAmount.value = args['topUpAmount'] ?? '₹0.00';
    transactionId.value = args['transactionId'] ?? 'N/A';
    dateTime.value = args['dateTime'] ?? 'N/A';
    paymentMethodName.value = args['paymentMethodName'] ?? 'Razorpay';
    paymentMethodType.value = args['paymentMethodType'] ?? 'Online';
    updatedBalance.value = args['updatedBalance'] ?? '₹0.00';
    // Extra fields
    razorpayPaymentId.value = args['razorpayPaymentId'] ?? 'N/A';
    accountName.value = args['accountName'] ?? 'N/A';
    mobile.value = args['mobile'] ?? 'N/A';
    remarks.value = args['remarks'] ?? '';
    rawAmount.value = (args['rawAmount'] as num?)?.toDouble() ?? 0.0;
  }

  void goToWallet() {
    // Pop back to the main layout or wallet tab
    Get.until((route) => Get.currentRoute == '/main-layout' || route.isFirst);
  }

  void downloadReceipt() {
    final receiptData = WalletReceiptData(
      transactionId: transactionId.value,
      razorpayPaymentId: razorpayPaymentId.value,
      accountName: accountName.value,
      mobile: mobile.value,
      remarks: remarks.value,
      amount: rawAmount.value,
      paymentMethod: paymentMethodName.value,
      status: 'Completed',
      dateTime: dateTime.value,
      updatedBalance: updatedBalance.value,
    );
    TicketPdfService().downloadWalletReceipt(receiptData);
  }
}