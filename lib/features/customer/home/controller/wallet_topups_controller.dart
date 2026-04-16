import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/services/auth_services.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../core/services/ticket_pdf_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class WalletTopupsController extends GetxController {
  final FirestoreService _firestoreService = Get.find<FirestoreService>();
  final AuthService _authService = Get.find<AuthService>();

  final RxList<Map<String, dynamic>> topupTransactions =
      <Map<String, dynamic>>[].obs;

  // Store raw transaction data for detail slider
  final RxList<Map<String, dynamic>> _rawTransactions =
      <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadTopups();
  }

  void _loadTopups() {
    final userId = _authService.currentUser?.uid;
    if (userId != null) {
      _firestoreService.getWalletTransactions(userId).listen((transactions) {
        // Keep raw data for detail slider
        _rawTransactions.value =
            transactions.where((t) => t['isCredit'] == true).toList();

        // Map to display format
        topupTransactions.value = _rawTransactions.map((t) {
          return {
            'id': t['id'],
            'transactionId': t['transactionId'] ?? t['id'],
            'razorpayPaymentId': t['razorpayPaymentId'] ?? 'N/A',
            'bank': t['paymentMethod'] ?? 'Online',
            'date': _formatDate(t['createdAt']),
            'amount': '₹${(t['amount'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
            'rawAmount': (t['amount'] as num?)?.toDouble() ?? 0.0,
            'status': (t['status'] ?? 'Success').toString().toUpperCase(),
            'isCredit': t['isCredit'] ?? true,
            'name': t['name'] ?? 'N/A',
            'mobile': t['mobile'] ?? 'N/A',
            'remarks': t['remarks'] ?? '',
            'paymentMethod': t['paymentMethod'] ?? 'Razorpay',
            'createdAt': t['createdAt'] ?? '',
          };
        }).toList();
      });
    }
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

  void showTransactionDetails(Map<String, dynamic> tx) {
    final bool isCredit = tx['isCredit'] ?? true;
    final Color amountColor =
        isCredit ? Colors.green.shade700 : Colors.red.shade700;

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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Transaction Details',
                      style: AppTextStyles.h3.copyWith(fontSize: 18)),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isCredit
                          ? Colors.green.shade50
                          : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      tx['status'] ?? 'SUCCESS',
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
              Center(
                child: Text(
                  tx['amount'] ?? '₹0.00',
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
              _detailRow('Transaction ID', tx['transactionId'] ?? 'N/A',
                  mono: true),
              _detailRow('Razorpay Payment ID',
                  tx['razorpayPaymentId'] ?? 'N/A', mono: true),
              _detailRow('Payment Method', tx['paymentMethod'] ?? 'Razorpay'),
              _detailRow('Account Name', tx['name'] ?? 'N/A'),
              _detailRow('Mobile', tx['mobile'] ?? 'N/A'),
              if ((tx['remarks'] ?? '').toString().isNotEmpty)
                _detailRow('Remarks', tx['remarks']),
              _detailRow('Type', isCredit ? 'Credit (Top-up)' : 'Debit'),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Get.back();
                    downloadReceipt(tx);
                  },
                  icon: const Icon(Icons.download_outlined,
                      color: AppColors.white, size: 18),
                  label: Text('Download Receipt',
                      style:
                          AppTextStyles.buttonText.copyWith(fontSize: 14)),
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

  void searchTopups() {
    print("Opening search bar for top-ups...");
  }

  void viewAll() {
    print("Loading older transactions...");
  }

  void downloadReceipt(Map<String, dynamic> tx) {
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
      updatedBalance: tx['amount'] ?? '₹0.00',
    );
    TicketPdfService().downloadWalletReceipt(receiptData);
  }
}