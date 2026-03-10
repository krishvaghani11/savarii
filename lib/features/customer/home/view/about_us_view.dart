import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:savarii/features/customer/home/controller/about_us_controller.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class AboutUsView extends GetView<AboutUsController> {
  const AboutUsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        // Dark app bar from your design
        elevation: 0,
        centerTitle: false,
        title: Text(
          'About Us',
          style: AppTextStyles.h3.copyWith(color: AppColors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Logo & App Name Header
            _buildHeader(),
            const SizedBox(height: 32),

            // 2. Our Story Card
            _buildOurStoryCard(),
            const SizedBox(height: 32),

            // 3. Our Mission Section
            Text('Our Mission', style: AppTextStyles.h3),
            const SizedBox(height: 16),
            _buildMissionCard(
              title: 'Reliable Transit',
              subtitle:
                  'Ensuring every ride is punctual, safe, and comfortable for every passenger.',
              icon: Icons.directions_car_outlined,
            ),
            _buildMissionCard(
              title: 'Safe Deliveries',
              subtitle:
                  'State-of-the-art tracking and handling for your parcels, big or small.',
              icon: Icons.inventory_2_outlined,
            ),
            _buildMissionCard(
              title: 'Community Growth',
              subtitle:
                  'Empowering local drivers and businesses to thrive in a shared economy.',
              icon: Icons.people_outline,
            ),
            const SizedBox(height: 32),

            // 4. Links Section (Version, Terms, Privacy)
            _buildLinksSection(),
            const SizedBox(height: 40),

            // 5. Footer (Socials & Copyright)
            _buildFooter(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- Sub-Widgets ---

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.primaryAccent.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryAccent.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Image.asset(
            AppAssets.savariiLogo, // Replace with your actual logo asset path
            fit: BoxFit.contain,
            // Fallback icon if image is missing during development:
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.directions_car,
              color: AppColors.primaryAccent,
              size: 40,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text('Savarii', style: AppTextStyles.h1.copyWith(fontSize: 28)),
        const SizedBox(height: 4),
        Text(
          'Your Local Travel & Parcel Partner',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.secondaryGreyBlue,
          ),
        ),
      ],
    );
  }

  Widget _buildOurStoryCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryGreyBlue.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.menu_book,
                color: AppColors.primaryAccent,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text('Our Story', style: AppTextStyles.h3.copyWith(fontSize: 18)),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            "Savarii was born from a simple observation: our communities are full of travelers and neighbors going the same way. We've built a platform that bridges the gap between daily commuters and local delivery needs, creating a more sustainable and connected ecosystem for everyone.",
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.secondaryGreyBlue,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionCard({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryGreyBlue.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primaryAccent, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.h3.copyWith(fontSize: 16)),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.secondaryGreyBlue,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinksSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryGreyBlue.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 8,
            ),
            title: Text(
              'Version',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.secondaryGreyBlue,
              ),
            ),
            trailing: Text(
              '2.1.0',
              style: AppTextStyles.h3.copyWith(fontSize: 16),
            ),
          ),
          Divider(
            color: AppColors.secondaryGreyBlue.withOpacity(0.1),
            height: 1,
            indent: 24,
            endIndent: 24,
          ),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 8,
            ),
            title: Text(
              'Terms & Conditions',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.secondaryGreyBlue,
              ),
            ),
            trailing: const Icon(
              Icons.chevron_right,
              color: AppColors.secondaryGreyBlue,
            ),
            onTap: controller.openTermsAndConditions,
          ),
          Divider(
            color: AppColors.secondaryGreyBlue.withOpacity(0.1),
            height: 1,
            indent: 24,
            endIndent: 24,
          ),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 8,
            ),
            title: Text(
              'Privacy Policy',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.secondaryGreyBlue,
              ),
            ),
            trailing: const Icon(
              Icons.chevron_right,
              color: AppColors.secondaryGreyBlue,
            ),
            onTap: controller.openPrivacyPolicy,
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(
                Icons.camera_alt_outlined,
                color: AppColors.secondaryGreyBlue,
              ),
              onPressed: () => controller.openSocial('Instagram'),
            ),
            const SizedBox(width: 8),
            IconButton(
              // Using an alternate icon for Twitter/X as flutter doesn't have it natively
              icon: const Icon(
                Icons.alternate_email,
                color: AppColors.secondaryGreyBlue,
              ),
              onPressed: () => controller.openSocial('Twitter'),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(
                Icons.facebook,
                color: AppColors.secondaryGreyBlue,
              ),
              onPressed: () => controller.openSocial('Facebook'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '© 2026 Savarii Technologies Inc.',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.secondaryGreyBlue.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}
