import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:savarii/core/theme/app_colors.dart';
import 'package:savarii/core/theme/app_text_styles.dart';
import 'package:savarii/core/utils/locale_utils.dart';
import '../controllers/vendor_terms_controller.dart';

class VendorTermsView extends GetView<VendorTermsController> {
  const VendorTermsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text('terms.title'.tr(), style: AppTextStyles.h3),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 16.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Introduction Card
                    _buildTermCard(
                      context: context,
                      title: 'terms.intro_title'.tr(),
                      content: 'terms.intro_desc'.tr(),
                    ),
                    const SizedBox(height: 16),

                    // Term 1
                    _buildTermCard(
                      context: context,
                      number: '1',
                      title: 'terms.term1_title'.tr(),
                      // Replace this placeholder string with your actual asset path, e.g., 'assets/images/signing_document.png'
                      imageAsset: 'assets/images/tern.png',
                      content: 'terms.term1_desc'.tr(),
                    ),
                    const SizedBox(height: 16),

                    // Term 2
                    _buildTermCard(
                      context: context,
                      number: '2',
                      title: 'terms.term2_title'.tr(),
                      content: 'terms.term2_desc'.tr(),
                    ),
                    const SizedBox(height: 16),

                    // Term 3
                    _buildTermCard(
                      context: context,
                      number: '3',
                      title: 'terms.term3_title'.tr(),
                      content: 'terms.term3_desc'.tr(),
                    ),
                    const SizedBox(height: 16),

                    // Term 4
                    _buildTermCard(
                      context: context,
                      number: '4',
                      title: 'terms.term4_title'.tr(),
                      content: 'terms.term4_desc'.tr(),
                    ),
                    const SizedBox(height: 16),

                    // Term 5
                    _buildTermCard(
                      context: context,
                      number: '5',
                      title: 'terms.term5_title'.tr(),
                      content: 'terms.term5_desc'.tr(),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // Sticky Footer Section
            _buildStickyFooter(),
          ],
        ),
      ),
    );
  }

  // --- Sub-Widgets ---

  Widget _buildTermCard({
    required BuildContext context,
    String? number,
    required String title,
    String? imageAsset,
    required String content,
  }) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row (Number Badge + Title)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (number != null) ...[
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.primaryAccent.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      LocaleUtils.formatNumber(context, number),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primaryAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.h3.copyWith(
                    fontSize: 16,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Optional Image
          if (imageAsset != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                imageAsset,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 120,
                  width: double.infinity,
                  color: AppColors.secondaryGreyBlue.withOpacity(0.1),
                  child: const Icon(
                    Icons.edit_document,
                    color: AppColors.secondaryGreyBlue,
                    size: 40,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Content Text
          Text(
            content,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.secondaryGreyBlue.withOpacity(0.9),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickyFooter() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      decoration: BoxDecoration(color: AppColors.lightBackground),
      child: Column(
        children: [
          ElevatedButton(
            onPressed: controller.acceptTerms,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryAccent,
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'terms.i_accept'.tr(),
                  style: AppTextStyles.buttonText.copyWith(fontSize: 16),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.check_circle,
                  color: AppColors.white,
                  size: 20,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'terms.last_updated'.tr(),
            style: AppTextStyles.caption.copyWith(
              color: AppColors.secondaryGreyBlue,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
