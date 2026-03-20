import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:savarii/features/customer/home/controller/settings_controller.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Text('Settings', style: AppTextStyles.h3),
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
              // 1. ACCOUNT SETTINGS
              _buildSectionHeader('ACCOUNT SETTINGS'),
              _buildSettingsGroup(
                children: [
                  _buildSettingsTile(
                    icon: Icons.notifications_none_outlined,
                    title: 'Notification Preferences',
                    subtitle: 'Manage alerts and sound settings',
                    onTap: controller.goToNotifications,
                  ),
                  _buildDivider(),
                  _buildSettingsTile(
                    icon: Icons.lock_outline,
                    title: 'Privacy',
                    subtitle: 'Control your data visibility',
                    onTap: controller.goToPrivacy,
                  ),
                  _buildDivider(),
                  _buildSettingsTile(
                    icon: Icons.security_outlined,
                    title: 'Security',
                    subtitle: 'Password and biometric options',
                    onTap: controller.goToSecurity,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 2. APP PREFERENCES
              _buildSectionHeader('APP PREFERENCES'),
              _buildSettingsGroup(
                children: [
                  _buildSettingsTile(
                    icon: Icons.translate,
                    title: 'Language',
                    trailingWidget: Text(
                      'English (US)',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primaryAccent,
                      ),
                    ),
                    onTap: controller.goToLanguage,
                  ),
                  _buildDivider(),
                  Obx(
                    () => _buildSettingsTile(
                      icon: Icons.dark_mode_outlined,
                      title: 'Dark Mode',
                      trailingWidget: CupertinoSwitch(
                        value: controller.isDarkMode.value,
                        activeTrackColor: AppColors.primaryAccent,
                        onChanged: controller.toggleDarkMode,
                      ),
                      onTap: () => controller.toggleDarkMode(
                        !controller.isDarkMode.value,
                      ),
                    ),
                  ),
                  _buildDivider(),
                  _buildSettingsTile(
                    icon: Icons.delete_outline,
                    title: 'Clear Cache',
                    subtitle: 'Free up space (124 MB)',
                    showArrow: false,
                    onTap: controller.clearCache,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 3. SUPPORT
              _buildSectionHeader('SUPPORT'),
              _buildSettingsGroup(
                children: [
                  _buildSettingsTile(
                    icon: Icons.help_outline,
                    title: 'Help Center',
                    trailingWidget: const Icon(
                      Icons.open_in_new,
                      color: AppColors.secondaryGreyBlue,
                      size: 18,
                    ),
                    onTap: controller.goToHelpCenter,
                  ),
                  _buildDivider(),
                  _buildSettingsTile(
                    icon: Icons.description_outlined,
                    title: 'Terms & Conditions',
                    onTap: controller.goToTerms,
                  ),
                  _buildDivider(),
                  _buildSettingsTile(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Policy',
                    onTap: controller.goToPrivacyPolicy,
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // 4. LOGOUT BUTTON
              ElevatedButton.icon(
                onPressed: controller.logout,
                icon: const Icon(
                  Icons.logout,
                  color: AppColors.primaryAccent,
                  size: 20,
                ),
                label: Text(
                  'Logout',
                  style: AppTextStyles.buttonText.copyWith(
                    color: AppColors.primaryAccent,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.white,
                  foregroundColor: AppColors.primaryAccent,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: AppColors.secondaryGreyBlue.withOpacity(0.2),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 5. VERSION TEXT
              Center(
                child: Text(
                  'Savarii App v2.4.1 (2024)',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.secondaryGreyBlue.withOpacity(0.7),
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.secondaryGreyBlue,
          letterSpacing: 1.2,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSettingsGroup({required List<Widget> children}) {
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
      child: Column(children: children),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailingWidget,
    bool showArrow = true,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.primaryAccent.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.primaryAccent, size: 22),
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.secondaryGreyBlue,
              ),
            )
          : null,
      trailing:
          trailingWidget ??
          (showArrow
              ? const Icon(
                  Icons.chevron_right,
                  color: AppColors.secondaryGreyBlue,
                )
              : null),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: AppColors.secondaryGreyBlue.withOpacity(0.1),
      height: 1,
      indent: 60, // Aligns divider with text, skipping the icon
      endIndent: 16,
    );
  }
}
