import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:savarii/core/theme/app_colors.dart';
import 'package:savarii/core/theme/app_text_styles.dart';
import 'package:savarii/features/auth/controllers/customer%20_login_controller.dart';


class CustomerLoginView extends GetView<CustomerLoginController> {
  const CustomerLoginView({super.key});

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
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- CHANGED START: ADDED CUSTOMER LOGIN LABEL ---
                    Text(
                      'Customer Login',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2A2D3E), // Dark navy as in mockup
                      ),
                    ),
                    const SizedBox(height: 16), // Adjusted spacing below the new label
                    // --- CHANGED END ---

                    // Title
                    Text(
                      'Welcome back',
                      style: AppTextStyles.h1.copyWith(
                        fontSize: 32,
                        height: 1.2,
                        color: const Color(0xFF2A2D3E), 
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Subtitle
                    Text(
                      'Log in to your account using your email and\npassword.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.secondaryGreyBlue,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Email Address Label
                    Text(
                      'Email Address',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: const Color(0xFF2A2D3E),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Email Input Field
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.secondaryGreyBlue.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: controller.emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: AppTextStyles.bodyMedium,
                        decoration: InputDecoration(
                          hintText: 'name@example.com',
                          hintStyle: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.secondaryGreyBlue.withOpacity(0.6),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Password Label (Corrected from the mockup's double "Email Address")
                    Text(
                      'Password',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: const Color(0xFF2A2D3E),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Password Input Field
                    Obx(() => Container(
                          decoration: BoxDecoration(
                            color: AppColors.secondaryGreyBlue.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            controller: controller.passwordController,
                            obscureText: controller.isPasswordHidden.value,
                            style: AppTextStyles.bodyMedium,
                            decoration: InputDecoration(
                              hintText: '••••••••',
                              hintStyle: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.secondaryGreyBlue.withOpacity(0.6),
                                letterSpacing: 2,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  controller.isPasswordHidden.value ? Icons.visibility_off : Icons.visibility,
                                  color: AppColors.secondaryGreyBlue,
                                  size: 20,
                                ),
                                onPressed: controller.togglePasswordVisibility,
                              ),
                            ),
                          ),
                        )),
                    const SizedBox(height: 12),

                    // Forgot Password Link
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: controller.goToForgotPassword,
                        child: Text(
                          'Forgot password?',
                          style: AppTextStyles.caption.copyWith(
                            color: const Color(0xFF2A2D3E),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

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
                            const TextSpan(text: 'By clicking continue, you agree to our '),
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
                    const SizedBox(height: 40),

                    // Continue Button
                    Obx(() => ElevatedButton(
                          onPressed: controller.isLoading.value ? null : controller.login,
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
                                      'Continue',
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
                    "Don't have an account? ",
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.secondaryGreyBlue,
                    ),
                  ),
                  GestureDetector(
                    onTap: controller.goToSignUp,
                    child: Text(
                      'Sign up',
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
}