import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:savarii/core/theme/app_colors.dart';
import 'package:savarii/core/theme/app_text_styles.dart';
import 'package:savarii/features/customer/home/controller/privacy_policy_controller.dart';

class PrivacyPolicyView extends GetView<PrivacyPolicyController> {
  const PrivacyPolicyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Text('Privacy Policy', style: AppTextStyles.h3),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryDark),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Header Section
              Text('Our Commitment', style: AppTextStyles.h2),
              const SizedBox(height: 12),
              Text(
                'At Savarii, we are committed to protecting your privacy. This policy explains how we collect, use, and safeguard your personal information to provide a seamless transportation and delivery experience. Your trust is our most valuable asset.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.secondaryGreyBlue,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),

              // 2. Expandable Policy Sections
              _buildPolicySection(
                title: 'Information Collection',
                icon: Icons.hub_outlined, // Nodes/network icon
                initiallyExpanded: true,
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'We collect essential data to make your journey smoother:',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.secondaryGreyBlue,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildBulletPoint(
                      'Account Details: ',
                      'Name, phone number, and email.',
                    ),
                    const SizedBox(height: 8),
                    _buildBulletPoint(
                      'Location Data: ',
                      'Real-time GPS for accurate bus tracking and route planning.',
                    ),
                    const SizedBox(height: 8),
                    _buildBulletPoint(
                      'Parcel Details: ',
                      'Information regarding weight, dimensions, and destination for delivery services.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              _buildPolicySection(
                title: 'Data Usage',
                icon: Icons.trending_up_outlined,
                content: Text(
                  'Details about how your data is used for app improvements and analytics go here.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.secondaryGreyBlue,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              _buildPolicySection(
                title: 'Data Sharing',
                icon: Icons.share_outlined,
                content: Text(
                  'Details about third-party sharing, payment gateways, and legal compliances go here.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.secondaryGreyBlue,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              _buildPolicySection(
                title: 'User Rights',
                icon: Icons.gavel_outlined,
                content: Text(
                  'Details about your right to delete data, request information, and opt-out go here.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.secondaryGreyBlue,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // 3. Contact Us Card
              _buildContactCard(),
              const SizedBox(height: 32),

              // 4. Footer Date
              Center(
                child: Text(
                  'LAST UPDATED: OCTOBER 2023',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.secondaryGreyBlue.withOpacity(0.6),
                    letterSpacing: 1,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // --- Sub-Widgets ---

  Widget _buildPolicySection({
    required String title,
    required IconData icon,
    required Widget content,
    bool initiallyExpanded = false,
  }) {
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
      // Theme wrapper removes the default ugly border lines from ExpansionTile
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          iconColor: AppColors.primaryDark,
          collapsedIconColor: AppColors.primaryDark,
          leading: Icon(icon, color: AppColors.primaryAccent, size: 22),
          title: Text(
            title,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          children: [content],
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String boldText, String regularText) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 6.0, right: 8.0),
          child: Icon(
            Icons.circle,
            size: 6,
            color: AppColors.secondaryGreyBlue,
          ),
        ),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.secondaryGreyBlue,
                height: 1.4,
              ),
              children: [
                TextSpan(
                  text: boldText,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
                ),
                TextSpan(text: regularText),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primaryAccent.withOpacity(0.05),
        // Light pink background
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryAccent.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text('Contact Us', style: AppTextStyles.h3),
          const SizedBox(height: 12),
          Text(
            'If you have any questions or concerns regarding our privacy practices, please reach out to our dedicated privacy team.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.secondaryGreyBlue,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: controller.emailSupport,
            icon: const Icon(Icons.email, color: AppColors.white, size: 18),
            label: Text('Email Support', style: AppTextStyles.buttonText),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryAccent,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }
}
