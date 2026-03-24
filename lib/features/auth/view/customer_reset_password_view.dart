import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:savarii/core/theme/app_colors.dart';
import 'package:savarii/core/theme/app_text_styles.dart';

import '../controllers/customer_reset_password_controller.dart';

class CustomerResetPasswordView extends GetView<CustomerResetPasswordController> {
  const CustomerResetPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground, // The subtle greyish background
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: false, // Matches your screenshot alignment
        title: Text('Reset Password', style: AppTextStyles.h3),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryDark),
          onPressed: () => Get.back(),
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
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_reset, // Circular reset lock icon
                      color: AppColors.primaryAccent,
                      size: 36,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 2. Titles
                Center(
                  child: Text(
                    'Create New Password',
                    style: AppTextStyles.h1.copyWith(
                      fontSize: 22,
                      color: const Color(0xFF2A2D3E),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Your new password must be different\nfrom previous used passwords.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.secondaryGreyBlue,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),

                // 3. New Password Input
                _buildLabel('New Password'),
                Obx(() => _buildPasswordField(
                      hint: '........',
                      icon: Icons.lock_outline,
                      controller: controller.newPasswordController,
                      isHidden: controller.isNewPasswordHidden.value,
                      onToggleVisibility: controller.toggleNewPasswordVisibility,
                    )),
                const SizedBox(height: 20),

                // 4. Confirm Password Input
                _buildLabel('Confirm New Password'),
                Obx(() => _buildPasswordField(
                      hint: '........',
                      icon: Icons.verified_user_outlined, // Shield icon as per mockup
                      controller: controller.confirmPasswordController,
                      isHidden: controller.isConfirmPasswordHidden.value,
                      onToggleVisibility: controller.toggleConfirmPasswordVisibility,
                    )),
                const SizedBox(height: 32),

                // 5. Update Password Button
                Obx(() => ElevatedButton(
                      onPressed: controller.isLoading.value ? null : controller.updatePassword,
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
                                  'Update Password',
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

                // 6. Back to Login Link
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
                          color: const Color(0xFF2A2D3E),
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

  // --- Sub-Widgets ---

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: AppTextStyles.bodyLarge.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 12,
          color: const Color(0xFF2A2D3E).withOpacity(0.8),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    required bool isHidden,
    required VoidCallback onToggleVisibility,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.secondaryGreyBlue.withOpacity(0.2),
        ),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isHidden,
        style: AppTextStyles.bodyMedium,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.secondaryGreyBlue.withOpacity(0.5),
            letterSpacing: 2,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          prefixIcon: Icon(
            icon,
            color: AppColors.secondaryGreyBlue.withOpacity(0.7),
            size: 20,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              isHidden ? Icons.visibility_off : Icons.visibility,
              color: AppColors.secondaryGreyBlue.withOpacity(0.7),
              size: 20,
            ),
            onPressed: onToggleVisibility,
          ),
        ),
      ),
    );
  }
}