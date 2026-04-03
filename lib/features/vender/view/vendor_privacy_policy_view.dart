import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
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
        title: Text('privacy.title'.tr(), style: AppTextStyles.h3),
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
                      'privacy.privacy_matters'.tr(),
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
                      '${"privacy.last_updated".tr()} ${controller.lastUpdated}',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.secondaryGreyBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // SECTION 1
                    _buildSectionTitle('privacy.intro_title'.tr()),
                    _buildBodyText('privacy.intro_desc1'.tr()),
                    _buildBodyText('privacy.intro_desc2'.tr()),
                    const SizedBox(height: 24),

                    // SECTION 2
                    _buildSectionTitle('privacy.info_collect_title'.tr()),
                    _buildBodyText('privacy.info_collect_desc1'.tr()),
                    _buildBulletItem(
                      'privacy.bullet1_title'.tr(),
                      'privacy.bullet1_desc'.tr(),
                    ),
                    _buildBulletItem(
                      'privacy.bullet2_title'.tr(),
                      'privacy.bullet2_desc'.tr(),
                    ),
                    _buildBulletItem(
                      'privacy.bullet3_title'.tr(),
                      'privacy.bullet3_desc'.tr(),
                    ),
                    const SizedBox(height: 16),
                    _buildBodyText('privacy.info_collect_desc2'.tr()),
                    _buildBulletItem(
                      'privacy.bullet4_title'.tr(),
                      'privacy.bullet4_desc'.tr(),
                    ),
                    _buildBulletItem(
                      'privacy.bullet5_title'.tr(),
                      'privacy.bullet5_desc'.tr(),
                    ),
                    const SizedBox(height: 24),

                    // SECTION 3
                    _buildSectionTitle('privacy.how_use_title'.tr()),
                    _buildBodyText('privacy.how_use_desc'.tr()),
                    _buildBulletItem(
                      'privacy.bullet6_title'.tr(),
                      'privacy.bullet6_desc'.tr(),
                    ),
                    _buildBulletItem(
                      'privacy.bullet7_title'.tr(),
                      'privacy.bullet7_desc'.tr(),
                    ),
                    _buildBulletItem(
                      'privacy.bullet8_title'.tr(),
                      'privacy.bullet8_desc'.tr(),
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
