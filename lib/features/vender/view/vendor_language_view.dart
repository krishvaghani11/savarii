import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:savarii/core/theme/app_colors.dart';
import 'package:savarii/core/theme/app_text_styles.dart';
import '../controllers/vendor_language_controller.dart';

class VendorLanguageView extends GetView<VendorLanguageController> {
  const VendorLanguageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 16.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Custom Back Button
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () => Get.back(),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryGreyBlue.withOpacity(
                              0.05,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: AppColors.primaryDark,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 2. Header
                    Text(
                      'Select Language',
                      style: AppTextStyles.h1.copyWith(fontSize: 28),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Choose your preferred language for the Savarii Vendor app.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.secondaryGreyBlue,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // 3. Language Options
                    Obx(
                      () => Column(
                        children: [
                          _buildLanguageCard(
                            code: 'EN',
                            title: 'English',
                            subtitle: 'Default app language',
                          ),
                          const SizedBox(height: 16),
                          _buildLanguageCard(
                            code: 'ગુ',
                            title: 'Gujarati',
                            subtitle: 'ગુજરાતી',
                          ),
                          const SizedBox(height: 16),
                          _buildLanguageCard(
                            code: 'हि',
                            title: 'Hindi',
                            subtitle: 'हिन्दी',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 4. Sticky Bottom Button
            _buildStickySaveButton(),
          ],
        ),
      ),
    );
  }

  // --- Sub-Widgets ---

  Widget _buildLanguageCard({
    required String code,
    required String title,
    required String subtitle,
  }) {
    bool isSelected = controller.selectedLanguage.value == title;

    return GestureDetector(
      onTap: () => controller.selectLanguage(title),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryAccent
                : AppColors.secondaryGreyBlue.withOpacity(0.15),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryAccent.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            // Icon Badge
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryAccent.withOpacity(0.1)
                    : AppColors.secondaryGreyBlue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  code,
                  style: AppTextStyles.h3.copyWith(
                    color: isSelected
                        ? AppColors.primaryAccent
                        : AppColors.primaryDark,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Language Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.secondaryGreyBlue,
                    ),
                  ),
                ],
              ),
            ),

            // Custom Radio Button
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryAccent
                      : AppColors.secondaryGreyBlue.withOpacity(0.3),
                  width: isSelected
                      ? 6
                      : 1.5, // The thick red border creates the "filled" look
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStickySaveButton() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(color: AppColors.secondaryGreyBlue.withOpacity(0.05)),
        ),
      ),
      child: ElevatedButton(
        onPressed: controller.saveLanguage,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryAccent,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Text(
          'Save Language',
          style: AppTextStyles.buttonText.copyWith(fontSize: 16),
        ),
      ),
    );
  }
}
