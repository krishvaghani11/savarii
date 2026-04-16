import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:savarii/core/theme/app_colors.dart';
import 'package:savarii/core/theme/app_text_styles.dart';
import 'package:savarii/features/customer/home/controller/wallet_confirmation_controller.dart';


class WalletConfirmationView extends GetView<WalletConfirmationController> {
  const WalletConfirmationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground, // Light grey background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text('Confirmation', style: AppTextStyles.h3),
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.primaryAccent), // Red close icon as per mockup
          onPressed: controller.goToWallet,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              
              // 1. Success Graphic (Red circle with checkmark & glow)
              _buildSuccessGraphic(),
              const SizedBox(height: 32),

              // 2. Success Text
              Text(
                'Top-up Successful',
                textAlign: TextAlign.center,
                style: AppTextStyles.h1.copyWith(fontSize: 26, color: AppColors.primaryDark),
              ),
              const SizedBox(height: 12),
              Obx(() => Text(
                '${controller.topUpAmount.value} has been added to your\nwallet successfully.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.secondaryGreyBlue,
                  height: 1.5,
                ),
              )),
              const SizedBox(height: 32),

              // 3. Transaction Details Card
              _buildTransactionCard(),
              const SizedBox(height: 40),

              // 4. Action Buttons
              _buildActionButtons(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // --- Sub-Widgets ---

  Widget _buildSuccessGraphic() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryAccent,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryAccent.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 5,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Icon(
        Icons.check,
        color: AppColors.white,
        size: 40,
      ),
    );
  }

  Widget _buildTransactionCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryGreyBlue.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TRANSACTION DETAILS',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.secondaryGreyBlue,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  fontSize: 11,
                ),
              ),
              const Icon(Icons.receipt_long_outlined, color: AppColors.secondaryGreyBlue, size: 18),
            ],
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Divider(color: AppColors.secondaryGreyBlue.withOpacity(0.1), height: 1),
          ),

          // Detail Rows
          Obx(() => _buildDetailRow('Transaction ID', controller.transactionId.value, isBold: true)),
          const SizedBox(height: 16),
          Obx(() => _buildDetailRow('Date & Time', controller.dateTime.value, isBold: true)),
          const SizedBox(height: 16),
          
          // Payment Method Row (Custom due to subtitle)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Payment Method',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.secondaryGreyBlue),
              ),
              Obx(() => Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    controller.paymentMethodName.value,
                    style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                  ),
                  Text(
                    controller.paymentMethodType.value,
                    style: AppTextStyles.caption.copyWith(color: AppColors.secondaryGreyBlue, fontSize: 11),
                  ),
                ],
              )),
            ],
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Divider(color: AppColors.secondaryGreyBlue.withOpacity(0.1), height: 1),
          ),

          // Footer Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Updated Wallet Balance',
                style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.primaryDark),
              ),
              Obx(() => Text(
                controller.updatedBalance.value,
                style: AppTextStyles.h3.copyWith(fontSize: 18, color: AppColors.primaryAccent),
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.secondaryGreyBlue),
        ),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: AppColors.primaryDark,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Go to Wallet Button (Solid Red)
        ElevatedButton(
          onPressed: controller.goToWallet,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryAccent,
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 0,
            shadowColor: AppColors.primaryAccent.withOpacity(0.4),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Go to Wallet', style: AppTextStyles.buttonText.copyWith(fontSize: 16)),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward, color: AppColors.white, size: 18),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Download Receipt Button (Light Grey Pill)
        ElevatedButton.icon(
          onPressed: controller.downloadReceipt,
          icon: const Icon(Icons.download_outlined, color: AppColors.primaryDark, size: 18),
          label: Text('Download Receipt', style: AppTextStyles.buttonText.copyWith(color: AppColors.primaryDark)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF7F8FA), // Light grey fill
            foregroundColor: AppColors.primaryDark,
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 0,
          ),
        ),
      ],
    );
  }
}