import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:savarii/core/theme/app_colors.dart';
import 'package:savarii/core/theme/app_text_styles.dart';

import '../controllers/customer_registration_controller.dart';

class CustomerRegistrationView extends GetView<CustomerRegistrationController> {
  const CustomerRegistrationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white, 
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
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
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- CHANGED START: ADDED CUSTOMER REGISTRATION LABEL ---
                    Text(
                      'Customer Registration',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2A2D3E), // Dark navy as in mockup
                      ),
                    ),
                    const SizedBox(height: 16), // Adjusted spacing below the new label
                    // --- CHANGED END ---

                    // Title
                    Text(
                      'Create Account',
                      style: AppTextStyles.h1.copyWith(
                        fontSize: 32,
                        height: 1.2,
                        color: const Color(0xFF2A2D3E), 
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Subtitle
                    Text(
                      'Join Savarii for seamless travel and parcel\nservices.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.secondaryGreyBlue,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Full Name Field
                    _buildLabel('Full Name'),
                    _buildInputField(
                      hint: 'John Doe',
                      controller: controller.fullNameController,
                    ),
                    const SizedBox(height: 20),

                    // Email Address Field
                    _buildLabel('Email Address'),
                    _buildInputField(
                      hint: 'name@example.com',
                      controller: controller.emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 20),

                    // Password Field
                    _buildLabel('Password'),
                    Obx(() => _buildPasswordField(
                          hint: '••••••••',
                          controller: controller.passwordController,
                          isHidden: controller.isPasswordHidden.value,
                          onToggle: controller.togglePasswordVisibility,
                        )),
                    const SizedBox(height: 20),

                    // Confirm Password Field
                    _buildLabel('Confirm Password'),
                    Obx(() => _buildPasswordField(
                          hint: '••••••••',
                          controller: controller.confirmPasswordController,
                          isHidden: controller.isConfirmPasswordHidden.value,
                          onToggle: controller.toggleConfirmPasswordVisibility,
                        )),
                    const SizedBox(height: 32),

                    // Terms and Privacy Policy
                    Center(
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.secondaryGreyBlue,
                            height: 1.5,
                          ),
                          children: [
                            const TextSpan(text: 'By clicking sign up, you agree to our '),
                            TextSpan(
                              text: 'Terms of Service\n',
                              style: AppTextStyles.caption.copyWith(
                                color: const Color(0xFF2A2D3E),
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            const TextSpan(text: 'and '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: AppTextStyles.caption.copyWith(
                                color: const Color(0xFF2A2D3E),
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            const TextSpan(text: '.'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Sign Up Button
                    Obx(() => ElevatedButton(
                          onPressed: controller.isLoading.value ? null : controller.signUp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryAccent,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            shadowColor: AppColors.primaryAccent.withOpacity(0.4),
                            elevation: 8,
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
                                      'Sign Up',
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
            
            // Footer Section (Sticks to bottom)
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0, top: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account? ",
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.secondaryGreyBlue,
                    ),
                  ),
                  GestureDetector(
                    onTap: controller.goToLogin,
                    child: Text(
                      'Log In',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: const Color(0xFF2A2D3E),
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
          fontWeight: FontWeight.w600,
          fontSize: 13,
          color: const Color(0xFF2A2D3E),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.secondaryGreyBlue.withOpacity(0.05), // Light grey fill
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: AppTextStyles.bodyMedium,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.secondaryGreyBlue.withOpacity(0.6),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required String hint,
    required TextEditingController controller,
    required bool isHidden,
    required VoidCallback onToggle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.secondaryGreyBlue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        obscureText: isHidden,
        style: AppTextStyles.bodyMedium,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.secondaryGreyBlue.withOpacity(0.6),
            letterSpacing: 2,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          suffixIcon: IconButton(
            icon: Icon(
              isHidden ? Icons.visibility_off : Icons.visibility,
              color: AppColors.secondaryGreyBlue,
              size: 20,
            ),
            onPressed: onToggle,
          ),
        ),
      ),
    );
  }
}