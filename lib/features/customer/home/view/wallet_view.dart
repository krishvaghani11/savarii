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
              // 1. Main Balance Card
              _buildBalanceCard(),
              const SizedBox(height: 32),

              // 2. Quick Actions
              _buildQuickActions(),
              const SizedBox(height: 32),

              // 3. Recent Transactions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Recent Transactions', style: AppTextStyles.h3),
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
        gradient: LinearGradient(
          colors: [
            const Color(0xFF2A2D3E), // Dark Navy/Grey
            AppColors.primaryDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withOpacity(0.3),
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
                  size: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              // Add Money Button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: controller.addMoney,
                  icon: const Icon(Icons.add, color: AppColors.white, size: 20),
                  label: Text('Add Money', style: AppTextStyles.buttonText),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryAccent, // Red
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Transfer Button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: controller.transferMoney,
                  icon: const Icon(
                    Icons.send,
                    color: AppColors.white,
                    size: 18,
                  ),
                  // Used send as closest to transfer arrow
                  label: Text('Transfer', style: AppTextStyles.buttonText),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.white.withOpacity(0.15),
                    // Semi-transparent
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildActionItem(
          icon: Icons.qr_code_scanner,
          label: 'Scan',
          onTap: controller.scanQR,
        ),
        _buildActionItem(
          icon: Icons.credit_card,
          label: 'Cards',
          onTap: controller.manageCards,
        ),
        _buildActionItem(
          icon: Icons.card_giftcard,
          label: 'Rewards',
          onTap: controller.viewRewards,
        ),
        _buildActionItem(
          icon: Icons.more_horiz,
          label: 'More',
          onTap: controller.moreOptions,
        ),
      ],
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.secondaryGreyBlue.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: AppColors.primaryAccent, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.secondaryGreyBlue,
              fontWeight: FontWeight.w500,
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
          // Determine icon based on transaction type
          IconData txIcon;
          if (tx['iconType'] == 'ride') {
            txIcon = Icons.directions_car;
          } else if (tx['iconType'] == 'wallet') {
            txIcon = Icons.account_balance_wallet;
          } else {
            txIcon = Icons.inventory_2;
          }

          return Container(
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
            child: Row(
              children: [
                // Left Icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.lightBackground,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(txIcon, color: AppColors.primaryDark, size: 24),
                ),
                const SizedBox(width: 16),

                // Middle Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tx['title'],
                        style: AppTextStyles.h3.copyWith(fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${tx['date']} • ${tx['status']}',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.secondaryGreyBlue,
                        ),
                      ),
                    ],
                  ),
                ),

                // Right Amount
                Text(
                  tx['amount'],
                  style: AppTextStyles.h3.copyWith(
                    fontSize: 16,
                    color: tx['isCredit']
                        ? Colors.green.shade600
                        : AppColors.primaryDark,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
