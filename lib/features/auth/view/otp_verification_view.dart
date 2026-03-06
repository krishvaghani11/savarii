import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:savarii/core/theme/app_colors.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/theme/app_text_styles.dart';
import '../controllers/otp_verification_controller.dart';

class OTPVerificationView extends GetView<OTPVerificationController> {
  const OTPVerificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text('Verification', style: AppTextStyles.h3),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryDark),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Shield Image
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          AppAssets.otpShieldImage,
                          width: 150,
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Title & Description
                    Text(
                      'Enter Verification Code',
                      style: AppTextStyles.h2,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'We have sent the verification code to your\nmobile number ${controller.dummyPhoneNumber}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.secondaryGreyBlue,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),

                    // 6 Circular OTP Input Fields
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(
                        6,
                        (index) => _buildCircularOTPField(index),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Static Timer UI
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.timer,
                          color: AppColors.primaryAccent,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "00:59",
                          style: AppTextStyles.h3.copyWith(fontSize: 18),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Static Resend Text
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Didn't receive code? ",
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.secondaryGreyBlue,
                          ),
                        ),
                        Text(
                          'Resend OTP',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.secondaryGreyBlue,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),

                    // The Spacer works correctly with SliverFillRemaining(hasScrollBody: false)
                    const Spacer(),
                    const SizedBox(height: 20),

                    // Bottom Verify Button
                    ElevatedButton(
                      onPressed: controller.onVerifyClicked,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryAccent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        shadowColor: AppColors.primaryAccent.withValues(
                          alpha: 0.3,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Verify',
                            style: AppTextStyles.buttonText.copyWith(
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.check_circle,
                            color: AppColors.white,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Reusable widget for the circular OTP bubbles
  Widget _buildCircularOTPField(int index) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.secondaryGreyBlue.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Center(
        child: TextField(
          controller: controller.otpControllers[index],
          focusNode: controller.focusNodes[index],

          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          style: AppTextStyles.h2.copyWith(fontSize: 22),
          cursorColor: AppColors.primaryAccent,

          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(6), // Allows pasting
          ],
          decoration: const InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),

          // CRITICAL: This triggers the jump to the next box every time you type
          onChanged: (value) => controller.onOTPChanged(value, index),
        ),
      ),
    );
  }
}
