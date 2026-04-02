import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:savarii/core/theme/app_colors.dart';
import 'package:savarii/core/theme/app_text_styles.dart';
import '../controllers/vendor_razorpay_controller.dart';

class VendorRazorpayView extends GetView<VendorRazorpayController> {
  const VendorRazorpayView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text('Secure Payment', style: AppTextStyles.h3),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryDark),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppColors.primaryAccent),
                SizedBox(height: 24),
                Text('Confirming your booking...'),
              ],
            ),
          );
        }

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Payment Summary Card
                Container(
                  padding: const EdgeInsets.all(24),
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
                    children: [
                      // Lock Icon
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primaryAccent.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.lock,
                          color: AppColors.primaryAccent,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Complete Your Payment',
                        style: AppTextStyles.h3.copyWith(fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Razorpay Secure Gateway',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.secondaryGreyBlue,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Divider(color: AppColors.secondaryGreyBlue.withOpacity(0.1)),
                      const SizedBox(height: 20),

                      // Route Info
                      _buildInfoRow(
                        Icons.route,
                        'Route',
                        '${controller.origin} → ${controller.destination}',
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        Icons.person,
                        'Passenger',
                        controller.passengerName,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        Icons.event_seat,
                        'Seat(s)',
                        controller.seat,
                      ),
                      const SizedBox(height: 20),
                      Divider(color: AppColors.secondaryGreyBlue.withOpacity(0.1)),
                      const SizedBox(height: 16),

                      // Total Amount
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Payable',
                            style: AppTextStyles.h3.copyWith(fontSize: 16),
                          ),
                          Text(
                            '₹${controller.totalAmount.toStringAsFixed(2)}',
                            style: AppTextStyles.h2.copyWith(
                              color: AppColors.primaryAccent,
                              fontSize: 22,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Pay Now Button
                ElevatedButton.icon(
                  onPressed: controller.openRazorpayCheckout,
                  icon: const Icon(Icons.payment, color: AppColors.white, size: 20),
                  label: Text(
                    'Pay Now ₹${controller.totalAmount.toStringAsFixed(2)}',
                    style: AppTextStyles.buttonText.copyWith(fontSize: 16),
                  ),
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

                // Security note
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.verified_user,
                      color: AppColors.secondaryGreyBlue,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '256-bit SSL encrypted | Powered by Razorpay',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.secondaryGreyBlue,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryAccent, size: 18),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.secondaryGreyBlue,
                fontSize: 11,
              ),
            ),
            Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
