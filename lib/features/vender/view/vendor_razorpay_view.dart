import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:savarii/core/theme/app_colors.dart';
import 'package:savarii/core/theme/app_text_styles.dart';
import 'package:savarii/core/utils/locale_utils.dart';
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
        title: Text('razorpay.title'.tr(), style: AppTextStyles.h3),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryDark),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: AppColors.primaryAccent),
                SizedBox(height: 24),
                Text('razorpay.confirming'.tr()),
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
                        'razorpay.complete_payment'.tr(),
                        style: AppTextStyles.h3.copyWith(fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'razorpay.secure_gateway'.tr(),
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
                        'razorpay.route'.tr(),
                        '${controller.origin} → ${controller.destination}',
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        Icons.person,
                        'razorpay.passenger'.tr(),
                        controller.passengerName,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        Icons.event_seat,
                        'razorpay.seats'.tr(),
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
                            'razorpay.total_payable'.tr(),
                            style: AppTextStyles.h3.copyWith(fontSize: 16),
                          ),
                          Text(
                            LocaleUtils.formatCurrency(context, controller.totalAmount),
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
                    '${"razorpay.pay_now".tr()} ${LocaleUtils.formatCurrency(context, controller.totalAmount)}',
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
                      'razorpay.ssl_encrypted'.tr(),
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
