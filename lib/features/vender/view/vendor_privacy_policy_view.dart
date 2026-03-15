import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:savarii/core/theme/app_colors.dart';
import 'package:savarii/core/theme/app_text_styles.dart';
import '../controllers/vendor_privacy_policy_controller.dart';

class VendorPrivacyPolicyView extends GetView<VendorPrivacyPolicyController> {
  const VendorPrivacyPolicyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        title: Text('Privacy Policy', style: AppTextStyles.h3),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryDark),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Header Illustration using Image Asset
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 32),
                decoration: BoxDecoration(
                  color: AppColors.secondaryGreyBlue.withOpacity(0.05),
                  // Light subtle background
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors.secondaryGreyBlue.withOpacity(0.1),
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    // Make sure to add this image to your assets folder and pubspec.yaml!
                    Image.asset(
                      'assets/images/privacy_policy.png',
                      height: 140,
                      fit: BoxFit.contain,
                      // Fallback in case the image isn't loaded yet
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.admin_panel_settings,
                        size: 100,
                        color: AppColors.primaryAccent,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Your Privacy Matters',
                      style: AppTextStyles.h2.copyWith(fontSize: 22),
                    ),
                  ],
                ),
              ),

              // 2. Policy Content
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Last Updated: ${controller.lastUpdated}',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.secondaryGreyBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // SECTION 1
                    _buildSectionTitle('1. Introduction'),
                    _buildBodyText(
                      'This Privacy Policy describes how Savarii Vendor ("we," "us," or "our") collects, uses, and shares your personal information when you use our mobile application (the "App").',
                    ),
                    _buildBodyText(
                      'By using the App, you agree to the collection and use of information in accordance with this policy. If you do not agree with the terms of this Privacy Policy, please do not access or use the App.',
                    ),
                    const SizedBox(height: 24),

                    // SECTION 2
                    _buildSectionTitle('2. Information We Collect'),
                    _buildBodyText(
                      'We collect information that you provide directly to us when you use the App. This information may include:',
                    ),
                    _buildBulletItem(
                      'Personal Identification Information:',
                      'Name, email address, phone number, and other contact details.',
                    ),
                    _buildBulletItem(
                      'Agency Information:',
                      'Travels Name, Registration Number, GST Details, and Business Type.',
                    ),
                    _buildBulletItem(
                      'Payment Information:',
                      'Bank account details or UPI IDs for processing your earnings.',
                    ),
                    const SizedBox(height: 16),
                    _buildBodyText(
                      'We also collect certain information automatically when you use the App, including:',
                    ),
                    _buildBulletItem(
                      'Usage Data:',
                      'Information about how you use the App, such as the features you access and actions you take.',
                    ),
                    _buildBulletItem(
                      'Location Data:',
                      'Real-time GPS tracking of your fleet to provide live updates to passengers.',
                    ),
                    const SizedBox(height: 24),

                    // SECTION 3
                    _buildSectionTitle('3. How We Use Your Information'),
                    _buildBodyText(
                      'We may use the information we collect for various purposes, including to:',
                    ),
                    _buildBulletItem(
                      'Provide and Maintain the App:',
                      'To deliver the services you request, manage bookings, and keep the App running smoothly.',
                    ),
                    _buildBulletItem(
                      'Improve the App:',
                      'To understand how vendors interact with the App and to enhance its features.',
                    ),
                    _buildBulletItem(
                      'Communicate with You:',
                      'To send you notifications, earnings reports, updates, and support messages.',
                    ),
                    const SizedBox(height: 40),
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: AppTextStyles.h3.copyWith(
          fontSize: 18,
          color: AppColors.primaryDark,
        ),
      ),
    );
  }

  Widget _buildBodyText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        text,
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.secondaryGreyBlue.withOpacity(0.9),
          height: 1.6, // Increased line height for better readability
        ),
      ),
    );
  }

  Widget _buildBulletItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6.0, right: 12.0),
            child: Icon(Icons.circle, size: 6, color: AppColors.primaryAccent),
          ),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.secondaryGreyBlue.withOpacity(0.9),
                  height: 1.5,
                ),
                children: [
                  TextSpan(
                    text: '$title ',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  TextSpan(text: description),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
