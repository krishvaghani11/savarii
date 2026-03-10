import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:savarii/features/customer/home/controller/language_controller.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class LanguageView extends GetView<LanguageController> {
  const LanguageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text('Select Language', style: AppTextStyles.h3),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryDark),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Header Section
              _buildHeader(),
              const SizedBox(height: 32),

              // 2. Language Options
              _buildLanguageCard(
                id: 'en',
                title: 'English',
                subtitle: 'Default System Language',
                iconText: 'A',
              ),
              const SizedBox(height: 16),
              _buildLanguageCard(
                id: 'gu',
                title: 'ગુજરાતી',
                subtitle: 'Gujarati',
                iconText: 'ગુ',
              ),
              const SizedBox(height: 16),
              _buildLanguageCard(
                id: 'hi',
                title: 'हिन्दी',
                subtitle: 'Hindi',
                iconText: 'हि',
              ),

              const Spacer(),

              // 3. Continue Button
              ElevatedButton(
                onPressed: controller.saveAndContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  shadowColor: AppColors.primaryAccent.withOpacity(0.3),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Continue',
                      style: AppTextStyles.buttonText.copyWith(fontSize: 18),
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
              const SizedBox(height: 16),

              // 4. Footer Branding
              Center(
                child: Text(
                  'SAVARII MOBILITY SOLUTIONS',
                  style: AppTextStyles.caption.copyWith(
                    letterSpacing: 1.5,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondaryGreyBlue.withOpacity(0.5),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // --- Sub-Widgets ---

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primaryAccent.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.translate, // Closest material icon to your mockup
            color: AppColors.primaryAccent,
            size: 32,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Welcome to Savarii',
          style: AppTextStyles.h1.copyWith(fontSize: 24),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Please choose your preferred language to\ncontinue',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.secondaryGreyBlue,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLanguageCard({
    required String id,
    required String title,
    required String subtitle,
    required String iconText,
  }) {
    return Obx(() {
      final isSelected = controller.selectedLanguage.value == id;

      return GestureDetector(
        onTap: () => controller.selectLanguage(id),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryAccent.withOpacity(0.05)
                : AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? AppColors.primaryAccent
                  : AppColors.secondaryGreyBlue.withOpacity(0.2),
              width: isSelected ? 1.5 : 1,
            ),
            boxShadow: [
              if (!isSelected)
                BoxShadow(
                  color: AppColors.secondaryGreyBlue.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Row(
            children: [
              // Icon Box (A, ગુ, हि)
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: AppColors.lightBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    iconText,
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.primaryDark,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Text Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.h3.copyWith(fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTextStyles.caption.copyWith(
                        fontStyle: FontStyle.italic,
                        color: AppColors.secondaryGreyBlue,
                      ),
                    ),
                  ],
                ),
              ),

              // Radio Button Indicator
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryAccent
                        : AppColors.secondaryGreyBlue.withOpacity(0.4),
                    width: isSelected
                        ? 6
                        : 1.5, // Thicker border when selected mimics a radio button
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
