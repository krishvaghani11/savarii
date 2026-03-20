import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:savarii/core/theme/app_colors.dart';
import 'package:savarii/core/theme/app_text_styles.dart';
import 'package:savarii/features/customer/home/controller/payment_details_controller.dart';

class PaymentDetailsView extends GetView<PaymentDetailsController> {
  const PaymentDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text('Payment Details', style: AppTextStyles.h3),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryDark),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Trip Details Card
              _buildTripDetailsCard(),
              const SizedBox(height: 16),

              // 2. Fare Breakdown Card
              _buildFareBreakdownCard(),
              const SizedBox(height: 16),

              // 3. Promo Code Field Card
              _buildPromoCodeCard(),

              const SizedBox(height: 120), // Buffer for sticky bottom bar
            ],
          ),
        ),
      ),
      // Sticky Bottom Bar
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  // --- Sub-Widgets ---

  Widget _buildTripDetailsCard() {
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
          // Header Row
          Row(
            children: [
              const Icon(
                Icons.route_outlined,
                color: AppColors.primaryAccent,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Trip Details',
                style: AppTextStyles.h3.copyWith(fontSize: 16),
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
                  const Icon(Icons.circle, color: Colors.green, size: 12),
                  SizedBox(
                    width: 1.5,
                    height: 30,
                    // Dotted line effect using a Flex
                    child: Flex(
                      direction: Axis.vertical,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(
                        6,
                        (_) => Container(
                          width: 1.5,
                          height: 3,
                          color: AppColors.secondaryGreyBlue.withOpacity(0.4),
                        ),
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.circle,
                    color: AppColors.primaryAccent,
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
                      'BOARDING POINT',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.secondaryGreyBlue,
                        fontSize: 10,
                        letterSpacing: 0.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      controller.boardingPoint,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'DROPPING POINT',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.secondaryGreyBlue,
                        fontSize: 10,
                        letterSpacing: 0.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      controller.droppingPoint,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
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

  Widget _buildFareBreakdownCard() {
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
          // Ride Type Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryAccent.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.directions_bus,
                  color: AppColors.primaryAccent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.rideType,
                    style: AppTextStyles.h3.copyWith(fontSize: 16),
                  ),
                  Text(
                    controller.rideTime,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.secondaryGreyBlue,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),
          // Horizontal Dotted Divider
          Row(
            children: List.generate(
              30,
              (index) => Expanded(
                child: Container(
                  color: index % 2 == 0
                      ? Colors.transparent
                      : AppColors.secondaryGreyBlue.withOpacity(0.2),
                  height: 1,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Price Rows
          _buildSummaryRow('Base Fare', controller.baseFare),
          const SizedBox(height: 12),
          _buildSummaryRow('Distance Charge (12km)', controller.distanceCharge),
          const SizedBox(height: 12),
          _buildSummaryRow('Tax & Fees', controller.taxAndFees),
          const SizedBox(height: 20),

          // Total Amount
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Amount',
                style: AppTextStyles.h3.copyWith(fontSize: 16),
              ),
              Obx(
                () => Text(
                  '₹${controller.totalAmount.value.toStringAsFixed(2)}',
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

  Widget _buildPromoCodeCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryGreyBlue.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller.promoController,
        style: AppTextStyles.bodyLarge,
        decoration: InputDecoration(
          hintText: 'Add Promo Code',
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.secondaryGreyBlue.withOpacity(0.6),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          prefixIcon: const Icon(
            Icons.local_offer,
            color: AppColors.primaryAccent,
            size: 20,
          ),
          suffixIcon: TextButton(
            onPressed: controller.applyPromo,
            child: Text(
              'APPLY',
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
        color: AppColors.white,
        // White background for the bottom bar as per mockup
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Secure Payment Text
            Row(
              children: [
                const Icon(Icons.security, color: Colors.green, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Secure Payment Encrypted',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.secondaryGreyBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Confirm Button
            ElevatedButton(
              onPressed: controller.confirmPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryAccent,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Obx(
                () => Text(
                  'Confirm Payment • ₹${controller.totalAmount.value.toStringAsFixed(2)}',
                  style: AppTextStyles.buttonText.copyWith(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
