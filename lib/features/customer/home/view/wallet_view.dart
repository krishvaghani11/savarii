import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:savarii/features/customer/home/controller/main_layout_controller.dart';
import 'package:savarii/features/customer/home/controller/wallet_controller.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class WalletView extends GetView<WalletController> {
  const WalletView({super.key});

  @override
  Widget build(BuildContext context) {
    // Fallback injection for isolated testing
    if (!Get.isRegistered<WalletController>()) {
      Get.put(WalletController());
    }

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text('My Wallet', style: AppTextStyles.h3),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryDark),
          onPressed: () {
            // Route back to Home tab if inside the bottom nav
            if (Get.isRegistered<MainLayoutController>()) {
              Get.find<MainLayoutController>().changeTab(0);
            } else {
              Get.back();
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: AppColors.primaryDark),
            onPressed: controller.viewAllTransactions,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Main Balance Card (Redesigned)
              _buildBalanceCard(),
              const SizedBox(height: 32),

              // 2. Recent Transactions Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Recent Transactions', style: AppTextStyles.h3.copyWith(fontSize: 16)),
                  TextButton(
                    onPressed: controller.viewAllTransactions,
                    child: Text(
                      'See All',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primaryAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // 3. Transactions List
              _buildTransactionsList(),

              const SizedBox(height: 20), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }

  // --- Sub-Widgets ---

  Widget _buildBalanceCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2D3E), // Solid dark color matching the mockup
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2A2D3E).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Balance',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.white.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Obx(
                    () => Text(
                      '₹${controller.currentBalance.value.toStringAsFixed(2)}',
                      style: AppTextStyles.h1.copyWith(
                        color: AppColors.white,
                        fontSize: 36,
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  color: AppColors.white,
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Add Money Button (Pill shaped)
          ElevatedButton.icon(
            onPressed: controller.addMoney,
            icon: const Icon(Icons.add, color: AppColors.white, size: 18),
            label: Text('Add Money', style: AppTextStyles.buttonText.copyWith(fontSize: 14)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryAccent, // Red
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24), // Pill shape
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // View Transactions Button (Full width, dark outlined)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: controller.viewAllTransactions,
              icon: const Icon(
                Icons.list_alt,
                color: AppColors.primaryAccent,
                size: 18,
              ),
              label: Text(
                'View Transactions',
                style: AppTextStyles.buttonText.copyWith(
                  color: AppColors.primaryAccent,
                  fontSize: 14,
                ),
              ),
              style: OutlinedButton.styleFrom(
                backgroundColor: AppColors.white.withOpacity(0.05),
                side: BorderSide(
                  color: AppColors.primaryAccent.withOpacity(0.5),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList() {
    return Obx(
      () => Column(
        children: controller.recentTransactions.map((tx) {
          bool isCredit = tx['isCredit'] ?? false;
          
          // Determine icon and colors based on transaction type
          IconData txIcon;
          Color iconBgColor;
          Color iconColor;

          switch (tx['iconType']) {
            case 'wallet':
              txIcon = Icons.account_balance_wallet;
              iconBgColor = Colors.green.shade50;
              iconColor = Colors.green.shade600;
              break;
            case 'ticket':
              txIcon = Icons.confirmation_number;
              iconBgColor = Colors.blue.shade50;
              iconColor = Colors.blue.shade600;
              break;
            case 'parcel':
              txIcon = Icons.local_shipping;
              iconBgColor = Colors.orange.shade50;
              iconColor = Colors.orange.shade600;
              break;
            case 'ride':
              txIcon = Icons.directions_car;
              iconBgColor = Colors.purple.shade50;
              iconColor = Colors.purple.shade600;
              break;
            default:
              txIcon = isCredit
                  ? Icons.add_circle_outline
                  : Icons.remove_circle_outline;
              iconBgColor = isCredit
                  ? Colors.green.shade50
                  : Colors.red.shade50;
              iconColor = isCredit
                  ? Colors.green.shade600
                  : Colors.red.shade400;
          }

          return GestureDetector(
            onTap: () => controller.showTransactionDetails(tx),
            child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.secondaryGreyBlue.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Icon
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: iconBgColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(txIcon, color: iconColor, size: 24),
                    ),
                    const SizedBox(width: 16),

                    // Middle Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tx['title'] ?? 'Transaction',
                            style: AppTextStyles.h3.copyWith(fontSize: 15),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${tx['date'] ?? ''} • ${tx['status'] ?? 'Completed'}',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.secondaryGreyBlue,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Right Amount — green for credit, red for debit
                    Text(
                      tx['amount'] ?? '',
                      style: AppTextStyles.h3.copyWith(
                        fontSize: 15,
                        color: isCredit
                            ? Colors.green.shade600
                            : Colors.red.shade500,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Download Invoice Button
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => controller.downloadInvoice(tx),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.download_outlined,
                          color: AppColors.primaryAccent,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Download Invoice',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primaryAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ), // closes Container
          ); // closes GestureDetector
        }).toList(),
      ),
    );
  }
}