import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:get/get.dart';
import 'package:savarii/core/theme/app_colors.dart';
import 'package:savarii/core/theme/app_text_styles.dart';
import 'package:savarii/features/driver/controller/driver_signup_controller.dart';


class DriverSignupView extends GetView<DriverSignupController> {
  const DriverSignupView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true, // Centers the title text
        title: Text(
          'Driver Sign Up',
          style: AppTextStyles.h3.copyWith(color: AppColors.primaryDark),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryDark),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Header Section
                Text(
                  'Create Account',
                  style: AppTextStyles.h1.copyWith(
                    fontSize: 32,
                    color: const Color(0xFF2A2D3E), // Dark Navy
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Join Savarii for seamless travel and parcel\nservices.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.secondaryGreyBlue,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),

                // 2. Full Name Field
                _buildInputLabel('Full Name'),
                _buildInputField(
                  controller: controller.nameController,
                  hintText: 'John Doe',
                ),
                const SizedBox(height: 20),

                // 3. Phone Field
                _buildInputLabel('Phone Number'),
                _buildInputField(
                  controller: controller.phoneController,
                  hintText: '1234567890',
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 20),

                // 4. Email Field
                _buildInputLabel('Email Address'),
                _buildInputField(
                  controller: controller.emailController,
                  hintText: 'name@example.com',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),

                // 4. Password Field
                _buildInputLabel('Password'),
                Obx(() => _buildInputField(
                  controller: controller.passwordController,
                  hintText: '••••••••',
                  obscureText: !controller.isPasswordVisible.value,
                  suffixIcon: GestureDetector(
                    onTap: controller.togglePasswordVisibility,
                    child: Icon(
                      controller.isPasswordVisible.value
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: AppColors.secondaryGreyBlue,
                      size: 20,
                    ),
                  ),
                )),
                const SizedBox(height: 20),

                // 5. Confirm Password Field
                _buildInputLabel('Confirm Password'),
                Obx(() => _buildInputField(
                  controller: controller.confirmPasswordController,
                  hintText: '••••••••',
                  obscureText: !controller.isConfirmPasswordVisible.value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != controller.passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                  suffixIcon: GestureDetector(
                    onTap: controller.toggleConfirmPasswordVisibility,
                    child: Icon(
                      controller.isConfirmPasswordVisible.value
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: AppColors.secondaryGreyBlue,
                      size: 20,
                    ),
                  ),
                )),
                const SizedBox(height: 32),

                // 6. Terms & Privacy Text
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
                          text: 'Terms of Service',
                          style: const TextStyle(
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()..onTap = () {
                            // Navigate to Terms
                          },
                        ),
                        const TextSpan(text: '\nand '),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: const TextStyle(
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()..onTap = () {
                            // Navigate to Privacy Policy
                          },
                        ),
                        const TextSpan(text: '.'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 7. Sign Up Button
                Obx(() => ElevatedButton(
                  onPressed: controller.isLoading.value ? null : controller.signUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryAccent,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28), // Pill shape
                    ),
                    elevation: 4,
                    shadowColor: AppColors.primaryAccent.withOpacity(0.4),
                  ),
                  child: controller.isLoading.value
                      ? const CircularProgressIndicator(color: AppColors.white)
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Sign Up',
                              style: AppTextStyles.buttonText.copyWith(fontSize: 16),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward, color: AppColors.white, size: 20),
                          ],
                        ),
                )),
                const SizedBox(height: 32),

                // 8. Log In Link
                Row(
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
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Sub-Widgets ---

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.primaryDark,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6F9), // Light grey fill
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primaryDark),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.secondaryGreyBlue.withOpacity(0.6),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          suffixIcon: suffixIcon != null
              ? Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: suffixIcon,
                )
              : null,
          suffixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        ),
        validator: validator ??
            (value) {
              if (value == null || value.isEmpty) {
                return 'This field is required';
              }
              return null;
            },
      ),
    );
  }
}