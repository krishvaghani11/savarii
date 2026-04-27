import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'dart:math';

import '../../../../core/services/auth_services.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../core/services/ticket_pdf_service.dart';
import '../../../../routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class WalletController extends GetxController {
  final FirestoreService _firestoreService = Get.find<FirestoreService>();
  final AuthService _authService = Get.find<AuthService>();

  late Razorpay _razorpay;

  // Rx observables for UI
  final RxDouble currentBalance = 0.0.obs;
  final RxList<Map<String, dynamic>> recentTransactions = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;

  // Controllers for Add Money Bottom Sheet
  final amountController = TextEditingController();
  final mobileController = TextEditingController();
  final nameController = TextEditingController();
  final remarksController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _initWalletStreams();
    _initializeRazorpay();
  }

  void _initWalletStreams() {
    final userId = _authService.currentUser?.uid;
    if (userId == null) return;

    // ── Real-time wallet balance ───────────────────────────────────────────────
    _firestoreService.streamWalletBalance(userId).listen(
      (balance) => currentBalance.value = balance,
      onError: (e) => debugPrint('Balance stream error: $e'),
    );

    // ── Real-time transactions ────────────────────────────────────────────────
    // NOTE: Firestore requires a composite index on (userId ASC, createdAt DESC)
    // for wallet_transactions. If you see a FirebaseException, open the link
    // printed to the console and create the index. It takes ~30-60 seconds.
    _firestoreService.getWalletTransactions(userId).listen(
      (transactions) {
        recentTransactions.value = transactions.map((t) {
          final bool isCredit = t['isCredit'] ?? false;
          final double rawAmt =
              (t['amount'] as num?)?.toDouble() ?? 0.0;
          return {
            // ── display fields ───────────────────────────────────────
            'id': t['id'],
            'transactionId': t['transactionId'] ?? t['id'],
            'title': t['title'] ??
                (isCredit ? 'Wallet Top-up' : 'Wallet Deduction'),
            'date': _formatDate(t['createdAt']),
            'status': t['status'] ?? 'Completed',
            'amount':
                '${isCredit ? '+' : '-'} ₹${rawAmt.toStringAsFixed(2)}',
            'isCredit': isCredit,
            'iconType': t['iconType'] ?? 'wallet',
            // ── raw fields for detail slider + PDF ───────────────────
            'rawAmount': rawAmt,
            'razorpayPaymentId': t['razorpayPaymentId'] ?? 'N/A',
            'name': t['name'] ?? 'N/A',
            'mobile': t['mobile'] ?? 'N/A',
            'remarks': t['remarks'] ?? '',
            'paymentMethod': t['paymentMethod'] ?? 'Razorpay',
          };
        }).toList();
      },
      onError: (e) {
        debugPrint('Transaction stream error: $e');
        // Firestore composite index missing — fall back gracefully
        Get.snackbar(
          'Index Required',
          'Please create a Firestore composite index. Check the debug console for the link.',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 6),
        );
      },
    );
  }

  String _formatDate(dynamic createdAt) {
    if (createdAt == null) return 'Unknown Date';
    DateTime date;
    if (createdAt is String) {
      date = DateTime.tryParse(createdAt) ?? DateTime.now();
    } else {
      date = DateTime.now();
    }
    return DateFormat('MMM dd, yyyy • hh:mm a').format(date);
  }

  void _initializeRazorpay() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void addMoney() {
    // Reset fields
    amountController.clear();
    mobileController.clear();
    nameController.clear();
    remarksController.clear();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24.0),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Add Money to Wallet', style: AppTextStyles.h2.copyWith(color: AppColors.primaryDark)),
              const SizedBox(height: 24),
              TextField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Amount (₹)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.currency_rupee),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: mobileController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Mobile Number',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.phone),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: remarksController,
                decoration: InputDecoration(
                  labelText: 'Remarks (Optional)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.note),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _startRazorpayPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Obx(
                  () => isLoading.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text('Confirm & Pay', style: AppTextStyles.buttonText),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _startRazorpayPayment() {
    final amountText = amountController.text.trim();
    if (amountText.isEmpty) {
      Get.snackbar('Error', 'Please enter an amount', backgroundColor: Colors.red.shade100);
      return;
    }
    
    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      Get.snackbar('Error', 'Please enter a valid amount', backgroundColor: Colors.red.shade100);
      return;
    }

    isLoading.value = true;
    final amountInPaise = (amount * 100).toInt();

    final options = {
      'key': dotenv.env['RAZORPAY_KEY'] ?? 'rzp_test_YourKey', 
      'amount': amountInPaise,
      'name': 'Savarii Wallet',
      'description': 'Add Money to Wallet',
      'prefill': {
        'contact': mobileController.text.trim(),
        'name': nameController.text.trim(),
      },
      'theme': {'color': '#E82E59'}, // AppColors.primaryAccent hex
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Razorpay Error: $e');
      isLoading.value = false;
      Get.snackbar('Error', 'Unable to start payment.', backgroundColor: Colors.red.shade100);
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) {
      isLoading.value = false;
      return;
    }

    final amountAdded = double.tryParse(amountController.text.trim()) ?? 0.0;
    
    // Generate a transaction ID standard with top apps (e.g. T- followed by random digits)
    final txnId = 'T${DateTime.now().millisecondsSinceEpoch}${Random().nextInt(9999)}';

    final transactionData = {
      'transactionId': txnId,
      'razorpayPaymentId': response.paymentId ?? '',
      'title': 'Wallet Top-up',
      'amount': amountAdded,
      'isCredit': true,
      'iconType': 'wallet',
      'status': 'Completed',
      'paymentMethod': 'Razorpay',
      'name': nameController.text.trim(),
      'mobile': mobileController.text.trim(),
      'remarks': remarksController.text.trim(),
      'createdAt': DateTime.now().toIso8601String(),
    };

    try {
      // 1. Update wallet balance
      await _firestoreService.updateWalletBalance(userId, amountAdded);

      // 2. Add transaction history
      await _firestoreService.addWalletTransaction(userId, transactionData);

      // Dismiss bottom sheet safely
      if (Get.isBottomSheetOpen == true) {
        Get.back();
      }

      Get.snackbar(
        'Success',
        'Money fully credited in wallet',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade800,
      );

      final newBalance = currentBalance.value + amountAdded;

      // Navigate to success confirmation
      Get.toNamed(AppRoutes.walletConfirmation, arguments: {
        'topUpAmount': '₹${amountAdded.toStringAsFixed(2)}',
        'transactionId': txnId,
        'dateTime': _formatDate(transactionData['createdAt']),
        'paymentMethodName': 'Razorpay',
        'paymentMethodType': 'Online',
        'updatedBalance': '₹${newBalance.toStringAsFixed(2)}',
        // Extra fields for PDF receipt
        'razorpayPaymentId': response.paymentId ?? 'N/A',
        'accountName': nameController.text.trim(),
        'mobile': mobileController.text.trim(),
        'remarks': remarksController.text.trim(),
        'rawAmount': amountAdded,
      });

    } catch (e) {
      debugPrint('Wallet Update Error: $e');
      Get.snackbar('Error', 'Failed to update wallet balance.', backgroundColor: Colors.red.shade100);
    } finally {
      isLoading.value = false;
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    isLoading.value = false;
    Get.snackbar(
      'Payment Failed',
      response.message ?? 'Unknown error occurred',
      backgroundColor: Colors.red.shade100,
      colorText: Colors.red.shade800,
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    isLoading.value = false;
    Get.snackbar(
      'External Wallet',
      'Selected: ${response.walletName}',
      backgroundColor: Colors.blue.shade100,
    );
  }

  void viewAllTransactions() {
    Get.toNamed('/wallet-topups'); 
  }

  /// Opens a bottom sheet showing all details of a single transaction.
  void showTransactionDetails(Map<String, dynamic> tx) {
    final bool isCredit = tx['isCredit'] ?? false;
    final Color amountColor = isCredit ? Colors.green.shade700 : Colors.red.shade700;
    final String amountStr = tx['amount'] ?? '₹0.00';

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              // Header row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Transaction Details',
                      style: AppTextStyles.h3.copyWith(fontSize: 18)),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isCredit
                          ? Colors.green.shade50
                          : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      (tx['status'] ?? 'N/A').toString().toUpperCase(),
                      style: AppTextStyles.caption.copyWith(
                        color: amountColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Large amount display
              Center(
                child: Text(
                  amountStr,
                  style: AppTextStyles.h1.copyWith(
                    fontSize: 36,
                    color: amountColor,
                  ),
                ),
              ),
              Center(
                child: Text(
                  tx['date'] ?? '',
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.secondaryGreyBlue),
                ),
              ),
              const SizedBox(height: 24),
              Divider(color: Colors.grey.shade200),
              const SizedBox(height: 12),
              // Detail rows
              _detailRow('Transaction ID', tx['transactionId'] ?? tx['id'] ?? 'N/A', mono: true),
              _detailRow('Razorpay Payment ID', tx['razorpayPaymentId'] ?? 'N/A', mono: true),
              _detailRow('Payment Method', tx['paymentMethod'] ?? 'Razorpay'),
              _detailRow('Account Name', tx['name'] ?? 'N/A'),
              _detailRow('Mobile', tx['mobile'] ?? 'N/A'),
              if ((tx['remarks'] ?? '').toString().isNotEmpty)
                _detailRow('Remarks', tx['remarks']),
              _detailRow('Type', isCredit ? 'Credit (Top-up)' : 'Debit'),
              const SizedBox(height: 24),
              // Download receipt button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Get.back();
                    downloadInvoice(tx);
                  },
                  icon: const Icon(Icons.download_outlined,
                      color: AppColors.white, size: 18),
                  label: Text('Download Receipt',
                      style: AppTextStyles.buttonText.copyWith(fontSize: 14)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _detailRow(String label, String value, {bool mono = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.secondaryGreyBlue, fontSize: 12)),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
                fontFamily: mono ? 'RobotoMono' : null,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void downloadInvoice(Map<String, dynamic> tx) {
    final receiptData = WalletReceiptData(
      transactionId: tx['transactionId'] ?? tx['id'] ?? 'N/A',
      razorpayPaymentId: tx['razorpayPaymentId'] ?? 'N/A',
      accountName: tx['name'] ?? 'N/A',
      mobile: tx['mobile'] ?? 'N/A',
      remarks: tx['remarks'] ?? '',
      amount: (tx['rawAmount'] as double?) ?? 0.0,
      paymentMethod: tx['paymentMethod'] ?? 'Razorpay',
      status: tx['status'] ?? 'Completed',
      dateTime: tx['date'] ?? 'N/A',
      updatedBalance: '₹${currentBalance.value.toStringAsFixed(2)}',
    );
    TicketPdfService().downloadWalletReceipt(receiptData);
  }

  @override
  void onClose() {
    _razorpay.clear();
    amountController.dispose();
    mobileController.dispose();
    nameController.dispose();
    remarksController.dispose();
    super.onClose();
  }
}