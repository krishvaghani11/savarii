import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:savarii/core/theme/app_colors.dart';
import 'package:savarii/core/theme/app_text_styles.dart';
import '../controllers/vendor_login_controller.dart';

class VendorLoginView extends GetView<VendorLoginController> {
  const VendorLoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      // Using the light greyish background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text('Vendor Login', style: AppTextStyles.h3),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryDark),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Expanded allows the content to push the footer to the bottom
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 32.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Area
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'Welcome Back',
                            style: AppTextStyles.h1.copyWith(fontSize: 28),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Access your Savarii vendor dashboard',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.secondaryGreyBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Mobile Number Label
                    Text(
                      'Mobile Number',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Phone Input Field
                    _buildPhoneInput(),
                    const SizedBox(height: 32),

                    // Login Button
                    ElevatedButton(
                      onPressed: controller.login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryAccent,
                        minimumSize: const Size(double.infinity, 54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                        shadowColor: AppColors.primaryAccent.withOpacity(
                          0.4,
                        ), // Subtle red shadow
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Login',
                            style: AppTextStyles.buttonText.copyWith(
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.arrow_forward,
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

            // Footer (Sticks to bottom)
            Padding(
              padding: const EdgeInsets.all(24.0),
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
                    onTap: controller.goToRegister,
                    child: Text(
                      'Register',
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

  Widget _buildPhoneInput() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryGreyBlue.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller.mobileController,
        keyboardType: TextInputType.phone,
        style: AppTextStyles.bodyLarge.copyWith(letterSpacing: 1.5),
        decoration: InputDecoration(
          hintText: '00000 00000',
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.secondaryGreyBlue.withOpacity(0.5),
            letterSpacing: 1.5,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          prefixIcon: Container(
            width: 100,
            // <-- Increased width from 70 to 100 to fit the flag nicely!
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🇮🇳', style: TextStyle(fontSize: 18)),
                // <-- ADDED THE FLAG HERE
                const SizedBox(width: 4),
                Text(
                  '+91',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.secondaryGreyBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 1,
                  height: 20,
                  color: AppColors.secondaryGreyBlue.withOpacity(0.2),
                ),
                // Thin divider
              ],
            ),
          ),
        ),
      ),
    );
  }
}
