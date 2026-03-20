import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:savarii/core/theme/app_colors.dart';
import 'package:savarii/core/theme/app_text_styles.dart';
import 'package:savarii/features/customer/home/controller/parcel_payment_controller.dart';

class ParcelPaymentView extends GetView<ParcelPaymentController> {
  const ParcelPaymentView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text('Parcel Payment', style: AppTextStyles.h3),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryDark),
          onPressed: () => Get.back(),
        ),
        actions: [
          TextButton(
            onPressed: controller.helpAction,
            child: Text(
              'Help',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primaryAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Delivery Details Card
              _buildDeliveryDetailsCard(),
              const SizedBox(height: 24),

              // 2. Charge Summary Card
              _buildSectionTitle('Charge Summary'),
              _buildChargeSummaryCard(),
              const SizedBox(height: 24),

              // 3. Promo Code Field
              _buildPromoCodeField(),

              const SizedBox(height: 100), // Buffer for sticky bottom bar
            ],
          ),
        ),
      ),
      // Sticky Bottom Bar
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  // --- Sub-Widgets ---

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(title, style: AppTextStyles.h3.copyWith(fontSize: 16)),
    );
  }

  Widget _buildDeliveryDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Icon and Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryAccent.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.local_shipping,
                  color: AppColors.primaryAccent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Standard Delivery',
                    style: AppTextStyles.h3.copyWith(fontSize: 16),
                  ),
                  Text(
                    'Order ID: ${controller.orderId}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.secondaryGreyBlue,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Vertical Timeline
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeline Dots and Line
              Column(
                children: [
                  const SizedBox(height: 4),
                  const Icon(
                    Icons.circle,
                    color: AppColors.primaryAccent,
                    size: 12,
                  ),
                  Container(
                    width: 2,
                    height: 40,
                    color: AppColors.secondaryGreyBlue.withOpacity(0.2),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
                  const Icon(
                    Icons.circle,
                    color: AppColors.primaryDark,
                    size: 12,
                  ),
                ],
              ),
              const SizedBox(width: 16),
              // Timeline Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pickup',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.secondaryGreyBlue,
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      controller.pickupLocation,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      controller.pickupTime,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.secondaryGreyBlue,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Drop-off',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.secondaryGreyBlue,
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      controller.dropoffLocation,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      controller.dropoffTime,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.secondaryGreyBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChargeSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
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
        children: [
          _buildSummaryRow('Base Fare', controller.baseFare),
          const SizedBox(height: 12),
          _buildSummaryRow(
            'Weight Surcharge (5kg)',
            controller.weightSurcharge,
          ),
          const SizedBox(height: 12),
          _buildSummaryRow('Service Fee', controller.serviceFee),
          const SizedBox(height: 12),
          _buildSummaryRow('Tax', controller.tax),
          const SizedBox(height: 16),
          Divider(color: AppColors.secondaryGreyBlue.withOpacity(0.2)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Payable',
                style: AppTextStyles.h3.copyWith(fontSize: 16),
              ),
              Obx(
                () => Text(
                  '₹${controller.totalAmount.value.toStringAsFixed(2)}',
                  // <-- Changed here!
                  style: AppTextStyles.h3.copyWith(
                    fontSize: 18,
                    color: AppColors.primaryAccent,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.secondaryGreyBlue,
          ),
        ),
        Text(
          '₹${amount.toStringAsFixed(2)}',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.primaryDark,
          ),
        ),
      ],
    );
  }

  Widget _buildPromoCodeField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secondaryGreyBlue.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryGreyBlue.withOpacity(0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller.promoController,
        style: AppTextStyles.bodyLarge,
        decoration: InputDecoration(
          hintText: 'Have a promo code?',
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.secondaryGreyBlue.withOpacity(0.6),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          prefixIcon: const Icon(
            Icons.local_offer_outlined,
            color: AppColors.primaryAccent,
            size: 20,
          ),
          suffixIcon: TextButton(
            onPressed: controller.applyPromo,
            child: Text(
              'Apply',
              style: AppTextStyles.buttonText.copyWith(
                color: AppColors.primaryAccent,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      decoration: BoxDecoration(
        color: AppColors.lightBackground,
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryGreyBlue.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Amount',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.secondaryGreyBlue,
                  ),
                ),
                Obx(
                  () => Text(
                    '₹${controller.totalAmount.value.toStringAsFixed(2)}',
                    style: AppTextStyles.h2.copyWith(fontSize: 22),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: controller.payNow,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryAccent,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Pay Now',
                    style: AppTextStyles.buttonText.copyWith(fontSize: 16),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward,
                    color: AppColors.white,
                    size: 20,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
