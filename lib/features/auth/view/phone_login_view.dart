import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:savarii/core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../controllers/phone_login_controller.dart';

class PhoneLoginView extends GetView<PhoneLoginController> {
  const PhoneLoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white, // Using white as per your mockup
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
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
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Title
                    Text(
                      'Enter your mobile\nnumber',
                      style: AppTextStyles.h1.copyWith(
                        fontSize: 32,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Subtitle
                    Text(
                      'We will send you a confirmation code to\nverify your identity.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.secondaryGreyBlue,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Input Fields Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Country Code Block
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Code', style: AppTextStyles.caption),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.lightBackground,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Text(
                                    '🇮🇳',
                                    style: TextStyle(fontSize: 20),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '+91',
                                    style: AppTextStyles.h3.copyWith(
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),

                        // Mobile Number Input Block
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Mobile Number',
                                style: AppTextStyles.caption,
                              ),
                              const SizedBox(height: 8),
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.lightBackground,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: TextField(
                                  controller: controller.phoneController,
                                  keyboardType: TextInputType.phone,
                                  style: AppTextStyles.h3.copyWith(
                                    fontSize: 18,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: '00000 00000',
                                    hintStyle: AppTextStyles.h3.copyWith(
                                      fontSize: 18,
                                      color: AppColors.secondaryGreyBlue
                                          .withValues(alpha: 0.5),
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Terms and Privacy Policy RichText
                    Center(
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: AppTextStyles.caption.copyWith(height: 1.5),
                          children: [
                            const TextSpan(
                              text: 'By clicking continue, you agree to our ',
                            ),
                            TextSpan(
                              text: 'Terms of Service\n',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.primaryDark,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            const TextSpan(text: 'and '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.primaryDark,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            const TextSpan(text: '.'),
                          ],
                        ),
                      ),
                    ),

                    // Pushes the button to the bottom
                    const Spacer(),
                    const SizedBox(height: 20), // Buffer for the keyboard
                    // Bottom Continue Button
                    Obx(
                          () => SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: controller.isLoading.value
                              ? null
                              : () {
                            final phone = controller.phoneController.text.trim();

                            /// VALIDATION
                            if (phone.isEmpty || phone.length != 10) {
                              Get.snackbar(
                                "Error",
                                "Enter valid 10-digit number",
                              );
                              return;
                            }

                            /// CALL CONTROLLER
                            controller.sendOtp("+91$phone");
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryAccent,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            shadowColor:
                            AppColors.primaryAccent.withOpacity(0.4),
                            elevation: 8,
                          ),
                          child: controller.isLoading.value
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Continue',
                                style: AppTextStyles.buttonText.copyWith(
                                  fontSize: 18,
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
}
