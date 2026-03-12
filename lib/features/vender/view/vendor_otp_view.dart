import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:savarii/core/theme/app_colors.dart';
import 'package:savarii/core/theme/app_text_styles.dart';

import '../controllers/vendor_otp_controller.dart';

class VendorOtpView extends GetView<VendorOtpController> {
  const VendorOtpView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Text('Verify OTP', style: AppTextStyles.h3),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryDark),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Mail Icon Container
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.mark_email_read_outlined,
                  color: AppColors.primaryAccent,
                  size: 32,
                ),
              ),
              const SizedBox(height: 32),

              // 2. Titles
              Text(
                'Verify OTP',
                style: AppTextStyles.h1.copyWith(fontSize: 28),
              ),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.secondaryGreyBlue,
                    height: 1.5,
                  ),
                  children: [
                    const TextSpan(text: 'Enter the 6-digit code sent to '),
                    TextSpan(
                      text: '+91 ${controller.mobileNumber}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),

              // 3. OTP Input Fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  6,
                  (index) => _buildOtpBox(context, index),
                ),
              ),
              const SizedBox(height: 32),

              // 4. Resend Code Section
              Center(
                child: Column(
                  children: [
                    Text(
                      "Didn't receive the code?",
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.secondaryGreyBlue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: controller.resendOtp,
                      icon: const Icon(
                        Icons.refresh,
                        color: AppColors.secondaryGreyBlue,
                        size: 16,
                      ),
                      label: Text(
                        'Resend Code',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.secondaryGreyBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // 5. Verify & Login Button
              ElevatedButton(
                onPressed: controller.verifyOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryAccent,
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                  shadowColor: AppColors.primaryAccent.withOpacity(0.4),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Verify & Login',
                      style: AppTextStyles.buttonText.copyWith(fontSize: 16),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.login, color: AppColors.white, size: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Sub-Widgets ---

  Widget _buildOtpBox(BuildContext context, int index) {
    return SizedBox(
      width: 45,
      child: TextField(
        controller: controller.otpControllers[index],
        focusNode: controller.focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: AppTextStyles.h2.copyWith(fontSize: 24),
        maxLength: 1,
        // Only one digit per box
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          counterText: "", // Hides the '0/1' character counter
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: AppColors.secondaryGreyBlue.withOpacity(0.3),
              width: 2,
            ),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.primaryAccent, width: 2),
          ),
        ),
        onChanged: (value) {
          // Auto-shift focus to the next box when a number is typed
          if (value.isNotEmpty && index < 5) {
            controller.focusNodes[index + 1].requestFocus();
          }
          // Auto-shift focus to the previous box when deleted
          if (value.isEmpty && index > 0) {
            controller.focusNodes[index - 1].requestFocus();
          }
        },
      ),
    );
  }
}
