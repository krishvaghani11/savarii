import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:savarii/core/theme/app_colors.dart';
import 'package:savarii/core/theme/app_text_styles.dart';
import 'package:savarii/features/customer/home/controller/cancel_booking_controller.dart';

class CancelBookingView extends GetView<CancelBookingController> {
  const CancelBookingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Text('Cancel Booking', style: AppTextStyles.h3.copyWith(color: AppColors.secondaryGreyBlue)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.secondaryGreyBlue),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. Header Icon & Titles
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.primaryAccent.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.event_busy, // Calendar with 'X'
                            color: AppColors.primaryAccent,
                            size: 32,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Request Cancellation',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.h2.copyWith(color: AppColors.primaryDark),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please provide the following details associated\nwith your booking to initiate the cancellation\nprocess.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.secondaryGreyBlue,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // 2. Main Form Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.secondaryGreyBlue.withOpacity(0.05),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Mobile Number'),
                            _buildInputField(
                              hint: 'Enter registered mobile number',
                              icon: Icons.phone_android,
                              controller: controller.mobileController,
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: 20),

                            _buildLabel('Email ID'),
                            _buildInputField(
                              hint: 'Enter your email address',
                              icon: Icons.email_outlined,
                              controller: controller.emailController,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 20),

                            _buildLabel('PNR Number'),
                            _buildInputField(
                              hint: '10-digit PNR code',
                              icon: Icons.confirmation_number_outlined,
                              controller: controller.pnrController,
                            ),
                            const SizedBox(height: 24),

                            // Info Box
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF7F8FA),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.info, color: AppColors.primaryAccent, size: 18),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      "Cancellation charges may apply as per the service provider's policy. Refunds, if applicable, will be credited to the original payment source within 5-7 business days.",
                                      style: AppTextStyles.caption.copyWith(
                                        color: AppColors.secondaryGreyBlue,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // 3. Need Help Link
                      Center(
                        child: Text(
                          'NEED HELP WITH YOUR PNR?',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.secondaryGreyBlue,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),

            // 4. Sticky Bottom Button
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.lightBackground,
              ),
              child: Obx(() => ElevatedButton(
                onPressed: controller.isLoading.value ? null : controller.submitCancellation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryAccent,
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 0,
                ),
                child: controller.isLoading.value
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text('Cancel Ticket', style: AppTextStyles.buttonText.copyWith(fontSize: 16)),
              )),
            ),
          ],
        ),
      ),
    );
  }

  // --- Sub-Widgets ---

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.primaryDark,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA), // Light grey fill matching the mockup
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: AppTextStyles.bodyMedium,
        validator: (value) => value == null || value.isEmpty ? 'This field is required' : null,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.secondaryGreyBlue.withOpacity(0.6),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          prefixIcon: Icon(icon, color: AppColors.secondaryGreyBlue, size: 20),
        ),
      ),
    );
  }
}