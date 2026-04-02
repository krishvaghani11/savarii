import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:savarii/core/theme/app_colors.dart';
import 'package:savarii/core/theme/app_text_styles.dart';
import '../controllers/vendor_payment_confirmation_controller.dart';

class VendorPaymentConfirmationView
    extends GetView<VendorPaymentConfirmationController> {
  const VendorPaymentConfirmationView({super.key});

  @override
  Widget build(BuildContext context) {
    // Overriding the back button behavior to ensure it goes home, not back to payment
    return WillPopScope(
      onWillPop: () async {
        controller.backToHome();
        return false;
      },
      child: Scaffold(
        backgroundColor: AppColors.lightBackground,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text('Payment Confirmation', style: AppTextStyles.h3),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.primaryDark),
            onPressed: controller.backToHome,
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Success Header
                _buildSuccessHeader(),
                const SizedBox(height: 32),

                // 2. The Ticket Card
                _buildTicketCard(),
                const SizedBox(height: 32),

                // 3. Payment Summary
                Text(
                  'Payment Summary',
                  style: AppTextStyles.h3.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 16),
                _buildPaymentSummaryCard(),
                const SizedBox(height: 40),

                // 4. Action Buttons
                _buildActionButtons(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Sub-Widgets ---

  Widget _buildSuccessHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Color(0xFFE8F8F0), // Light green background
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle,
            color: Color(0xFF00A65A),
            size: 40,
          ), // Dark green icon
        ),
        const SizedBox(height: 20),
        Text(
          'Payment Successful!',
          style: AppTextStyles.h1.copyWith(fontSize: 24),
        ),
        const SizedBox(height: 8),
        Text(
          'Your booking has been confirmed',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.secondaryGreyBlue,
          ),
        ),
      ],
    );
  }

  Widget _buildTicketCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryGreyBlue.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Image Section
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            child: controller.busImageUrl.isNotEmpty
                ? Image.network(
                    controller.busImageUrl,
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _buildFallbackBusIcon(),
                  )
                : _buildFallbackBusIcon(),
          ),

          // Ticket Details Section
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Booking ID Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'BOOKING ID',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.secondaryGreyBlue,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          controller.bookingId,
                          style: AppTextStyles.h2.copyWith(fontSize: 18),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'CONFIRMED',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primaryAccent,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Divider(
                  color: AppColors.secondaryGreyBlue.withOpacity(0.1),
                  height: 1,
                ),
                const SizedBox(height: 16),

                // Details Grid
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailItem(
                        'Passenger',
                        controller.passengerName,
                      ),
                    ),
                    Expanded(
                      child: _buildDetailItem(
                        'Journey Date',
                        controller.journeyDate,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailItem('Route', controller.route),
                    ),
                    Expanded(
                      child: _buildDetailItem(
                        'Bus & Seat',
                        controller.busAndSeat,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Payment Method',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.secondaryGreyBlue,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.account_balance_wallet,
                                color: AppColors.primaryDark,
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                controller.paymentMethod,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackBusIcon() {
    return Container(
      height: 140,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.secondaryGreyBlue.withOpacity(0.1),
      ),
      child: const Icon(
        Icons.directions_bus,
        size: 50,
        color: AppColors.primaryDark,
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.secondaryGreyBlue,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildPaymentSummaryCard() {
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
          _buildSummaryRow('Ticket Price', controller.ticketPrice),
          const SizedBox(height: 12),
          _buildSummaryRow('GST (5%)', controller.gst),
          const SizedBox(height: 12),
          _buildSummaryRow('Platform Fee', controller.platformFee),
          const SizedBox(height: 16),
          Divider(color: AppColors.secondaryGreyBlue.withOpacity(0.2)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Paid',
                style: AppTextStyles.h3.copyWith(fontSize: 16),
              ),
              Text(
                '₹${controller.totalPaid.toStringAsFixed(2)}',
                style: AppTextStyles.h3.copyWith(
                  fontSize: 18,
                  color: AppColors.primaryAccent,
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

  Widget _buildActionButtons() {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: controller.downloadTicket,
          icon: const Icon(
            Icons.download_outlined,
            color: AppColors.white,
            size: 18,
          ),
          label: Text('Download Ticket', style: AppTextStyles.buttonText),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryAccent,
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: controller.backToHome,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryAccent.withOpacity(0.05),
            // Light transparent background
            foregroundColor: AppColors.primaryDark,
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: Text(
            'Back to Home',
            style: AppTextStyles.buttonText.copyWith(
              color: AppColors.primaryDark,
            ),
          ),
        ),
      ],
    );
  }
}
