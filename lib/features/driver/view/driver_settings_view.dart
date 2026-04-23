import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:savarii/core/theme/app_colors.dart';
import 'package:savarii/core/theme/app_text_styles.dart';
import 'package:savarii/features/driver/controller/driver_settings_controller.dart';

class DriverSettingsView extends GetView<DriverSettingsController> {
  const DriverSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Settings',
          style: AppTextStyles.h3.copyWith(color: const Color(0xFF2A2D3E)),
        ),
        // Since it's a tab now, we usually don't need a back button if it's the root tab.
        automaticallyImplyLeading: false, 
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionTitle('PREFERENCES'),
              const SizedBox(height: 16),
              _buildSwitchTile(
                title: 'Push Notifications',
                icon: Icons.notifications_active_outlined,
                value: controller.isNotificationsEnabled.value,
                onChanged: controller.toggleNotifications,
              ),
              const SizedBox(height: 12),
              _buildSwitchTile(
                title: 'Dark Theme',
                icon: Icons.dark_mode_outlined,
                value: controller.isDarkThemeEnabled.value,
                onChanged: controller.toggleDarkTheme,
              ),
              const SizedBox(height: 32),

              _buildSectionTitle('ABOUT'),
              const SizedBox(height: 16),
              _buildNavigationTile(
                title: 'Privacy Policy',
                icon: Icons.privacy_tip_outlined,
                onTap: controller.openPrivacyPolicy,
              ),
              const SizedBox(height: 12),
              _buildNavigationTile(
                title: 'Terms & Conditions',
                icon: Icons.description_outlined,
                onTap: controller.openTermsAndConditions,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.caption.copyWith(
        color: AppColors.secondaryGreyBlue,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildSwitchTile({required String title, required IconData icon, required bool value, required Function(bool) onChanged}) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryGreyBlue.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Obx(() => SwitchListTile(
        title: Text(
          title,
          style: AppTextStyles.bodyLarge.copyWith(color: const Color(0xFF2A2D3E), fontWeight: FontWeight.w600),
        ),
        secondary: Icon(icon, color: AppColors.primaryAccent),
        value: value == true ? controller.isNotificationsEnabled.value : controller.isDarkThemeEnabled.value, // Dummy linkage for example
        onChanged: onChanged,
        activeThumbColor: AppColors.primaryAccent,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      )),
    );
  }

  Widget _buildNavigationTile({required String title, required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondaryGreyBlue.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.secondaryGreyBlue, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.bodyLarge.copyWith(color: const Color(0xFF2A2D3E), fontWeight: FontWeight.w600),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: AppColors.secondaryGreyBlue, size: 16),
          ],
        ),
      ),
    );
  }
}
