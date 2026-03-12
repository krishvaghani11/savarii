import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:savarii/core/theme/app_colors.dart';
import 'package:savarii/core/theme/app_text_styles.dart';
import '../controllers/vendor_payment_details_controller.dart';

class VendorPaymentDetailsView extends GetView<VendorPaymentDetailsController> {
  const VendorPaymentDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Text('Payment Details', style: AppTextStyles.h3),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryDark),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 16.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. BOOKING SUMMARY
                    _buildSectionTitle('BOOKING SUMMARY'),
                    _buildBookingSummaryCard(),
                    const SizedBox(height: 24),

                    // 2. PASSENGER INFO
                    _buildSectionTitle('PASSENGER INFO'),
                    _buildPassengerCard(),
                    const SizedBox(height: 24),

                    // 3. FARE BREAKDOWN
                    _buildSectionTitle('FARE BREAKDOWN'),
                    _buildFareBreakdownCard(),
                    const SizedBox(height: 24),

                    // 4. SELECT PAYMENT METHOD
                    _buildSectionTitle('SELECT PAYMENT METHOD'),
                    _buildPaymentMethods(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // 5. Sticky Bottom Pay Button
            _buildStickyPayButton(),
          ],
        ),
      ),
    );
  }

  // --- Sub-Widgets ---

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.secondaryGreyBlue,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildBookingSummaryCard() {
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    controller.origin,
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.primaryAccent,
                      fontSize: 16,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Icon(
                      Icons.arrow_right_alt,
                      color: AppColors.secondaryGreyBlue,
                      size: 20,
                    ),
                  ),
                  Text(
                    controller.destination,
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.primaryAccent,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    color: AppColors.secondaryGreyBlue,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    controller.date,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Icon(
                    Icons.event_seat,
                    color: AppColors.secondaryGreyBlue,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    controller.seat,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.directions_bus,
              color: AppColors.primaryAccent,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPassengerCard() {
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.secondaryGreyBlue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person,
              color: AppColors.primaryDark,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                controller.passengerName,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                controller.passengerPhone,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.secondaryGreyBlue,
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
          _buildFareRow('Base Fare', controller.baseFare),
          const SizedBox(height: 12),
          _buildFareRow('GST (5%)', controller.gst),
          const SizedBox(height: 12),
          _buildFareRow('Platform Fee', controller.platformFee),
          const SizedBox(height: 16),
          Divider(color: AppColors.secondaryGreyBlue.withOpacity(0.2)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Amount',
                style: AppTextStyles.h3.copyWith(fontSize: 16),
              ),
              Text(
                '₹${controller.totalAmount.toStringAsFixed(2)}',
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.primaryAccent,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFareRow(String label, double amount) {
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

  Widget _buildPaymentMethods() {
    return Obx(
      () => Column(
        children: [
          _buildPaymentOption(
            id: 'UPI',
            title: 'UPI',
            subtitle: 'PhonePe, Google Pay, BHIM',
            icon: Icons.account_balance_wallet_outlined,
          ),
          const SizedBox(height: 12),
          _buildPaymentOption(id: 'Cash', title: 'Cash', icon: Icons.money),
          const SizedBox(height: 12),
          _buildPaymentOption(
            id: 'Cards',
            title: 'Cards (Credit/Debit)',
            icon: Icons.credit_card,
          ),
          const SizedBox(height: 12),
          _buildPaymentOption(
            id: 'Other',
            title: 'Other',
            icon: Icons.more_horiz,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption({
    required String id,
    required String title,
    String? subtitle,
    required IconData icon,
  }) {
    bool isSelected = controller.selectedPaymentMethod.value == id;

    return GestureDetector(
      onTap: () => controller.selectPaymentMethod(id),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryAccent
                : AppColors.secondaryGreyBlue.withOpacity(0.1),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondaryGreyBlue.withOpacity(0.02),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.secondaryGreyBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primaryDark, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.secondaryGreyBlue,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Custom Radio Button
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryAccent
                      : AppColors.secondaryGreyBlue.withOpacity(0.3),
                  width: isSelected ? 5 : 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStickyPayButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      decoration: BoxDecoration(color: AppColors.lightBackground),
      child: ElevatedButton(
        onPressed: controller.proceedToPay,
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
              'Proceed to Pay ₹${controller.totalAmount.toStringAsFixed(2)}',
              style: AppTextStyles.buttonText.copyWith(fontSize: 16),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward, color: AppColors.white, size: 20),
          ],
        ),
      ),
    );
  }
}
