import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:savarii/core/theme/app_colors.dart';
import 'package:savarii/core/theme/app_text_styles.dart';

import '../controllers/vendor_forgot_password_controller.dart';

class VendorForgotPasswordView extends GetView<VendorForgotPasswordController> {
  const VendorForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground, // The greyish background
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        title: Text('Reset Password', style: AppTextStyles.h3),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryDark),
          onPressed: controller.goBackToLogin,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.secondaryGreyBlue.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Icon Header
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.primaryAccent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.lock_reset, // Matches the reset lock icon
                      color: AppColors.primaryAccent,
                      size: 32,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 2. Titles
                Center(
                  child: Text(
                    'Forgot Password?',
                    style: AppTextStyles.h1.copyWith(fontSize: 22),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Enter your registered email address to receive password reset instructions.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.secondaryGreyBlue,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),

                // 3. Email Input
                Text(
                  'Email Address',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: AppColors.primaryDark.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.secondaryGreyBlue.withOpacity(0.2),
                    ),
                  ),
                  child: TextField(
                    controller: controller.emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: AppTextStyles.bodyMedium,
                    decoration: InputDecoration(
                      hintText: 'name@company.com',
                      hintStyle: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.secondaryGreyBlue.withOpacity(0.5),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      prefixIcon: Icon(
                        Icons.email_outlined,
                        color: AppColors.secondaryGreyBlue.withOpacity(0.7),
                        size: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 4. Confirm Button
                Obx(() => ElevatedButton(
                      // CONNECTED TO NEW METHOD HERE
                      onPressed: controller.isLoading.value ? null : controller.verifyEmailAndProceed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryAccent,
                        minimumSize: const Size(double.infinity, 54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                        shadowColor: AppColors.primaryAccent.withOpacity(0.4),
                      ),
                      child: controller.isLoading.value
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Confirm',
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
                    )),
                const SizedBox(height: 32),

                // 5. Back to Login Link
                GestureDetector(
                  onTap: controller.goBackToLogin,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.arrow_back,
                        color: AppColors.secondaryGreyBlue.withOpacity(0.8),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Back to Login',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.secondaryGreyBlue.withOpacity(0.9),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}