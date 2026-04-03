import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:savarii/core/theme/app_colors.dart';
import 'package:savarii/core/theme/app_text_styles.dart';

import '../controllers/vendor_registration_controller.dart';

class VendorRegistrationView extends GetView<VendorRegistrationController> {
  const VendorRegistrationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header Section
                      Center(
                        child: Column(
                          children: [
                            Text(
                              'auth.vendor_registration'.tr(),
                              style: AppTextStyles.h1.copyWith(fontSize: 28),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'auth.register_subtitle'.tr(),
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.secondaryGreyBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 48),

                      // Full Name Field
                      _buildLabel('auth.full_name'.tr()),
                      _buildTextField(
                        hint: 'auth.full_name_hint'.tr(),
                        icon: Icons.badge_outlined,
                        controller: controller.fullNameController,
                      ),
                      const SizedBox(height: 20),

                      // Mobile Number Field
                      _buildLabel('auth.mobile_number'.tr()),
                      _buildMobileField(),
                      const SizedBox(height: 20),

                      // Email Address Field
                      _buildLabel('auth.email_address_label'.tr()),
                      _buildTextField(
                        hint: 'vendor@example.com',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        controller: controller.emailController,
                      ),
                      const SizedBox(height: 20),

                      // Password Field
                      _buildLabel('auth.password_label'.tr()),
                      Obx(() => _buildPasswordField(
                            hint: '........',
                            controller: controller.passwordController,
                            isHidden: controller.isPasswordHidden.value,
                            onToggleVisibility: controller.togglePasswordVisibility,
                          )),
                      const SizedBox(height: 20),

                      // Confirm Password Field
                      _buildLabel('auth.confirm_password'.tr()),
                      Obx(() => _buildPasswordField(
                            hint: '........',
                            controller: controller.confirmPasswordController,
                            isHidden: controller.isConfirmPasswordHidden.value,
                            onToggleVisibility: controller.toggleConfirmPasswordVisibility,
                          )),
                      const SizedBox(height: 40),

                      // Register Button
                      Obx(() => ElevatedButton(
                            onPressed: controller.isLoading.value ? null : controller.completeRegistration,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryAccent,
                              minimumSize: const Size(double.infinity, 54),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
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
                                        'auth.register'.tr(),
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
                    ],
                  ),
                ),
              ),
            ),

            // Footer Section
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'auth.have_account'.tr(),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.secondaryGreyBlue,
                    ),
                  ),
                  GestureDetector(
                    onTap: controller.goToLogin,
                    child: Text(
                      'auth.login'.tr(),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primaryAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
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
        style: AppTextStyles.bodyLarge.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 12,
          letterSpacing: 0.5,
          color: AppColors.primaryDark.withOpacity(0.8),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
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
        keyboardType: keyboardType,
        style: AppTextStyles.bodyMedium,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.secondaryGreyBlue.withOpacity(0.5),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          prefixIcon: Icon(icon, color: AppColors.secondaryGreyBlue.withOpacity(0.7), size: 20),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required String hint,
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
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          prefixIcon: Icon(Icons.lock_outline, color: AppColors.secondaryGreyBlue.withOpacity(0.7), size: 20),
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

  Widget _buildMobileField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.secondaryGreyBlue.withOpacity(0.2)),
      ),
      child: TextFormField(
        controller: controller.mobileController,
        keyboardType: TextInputType.phone,
        style: AppTextStyles.bodyMedium,
        decoration: InputDecoration(
          hintText: '98765 43210',
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.secondaryGreyBlue.withOpacity(0.5),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          prefixIcon: Container(
            width: 90, 
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🇮🇳', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 4),
                Text(
                  '+91',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 1,
                  height: 20,
                  color: AppColors.secondaryGreyBlue.withOpacity(0.3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}