import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:savarii/core/theme/app_colors.dart';
import 'package:savarii/core/theme/app_text_styles.dart';
import 'package:savarii/features/customer/home/controller/privacy_settings_controller.dart';

class PrivacySettingsView extends GetView<PrivacySettingsController> {
  const PrivacySettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Text('Privacy', style: AppTextStyles.h3),
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
              // 1. DATA VISIBILITY
              _buildSectionHeader('DATA VISIBILITY'),
              _buildSettingsGroup(
                children: [
                  Obx(
                    () => _buildSettingsTile(
                      icon: Icons.person_search_outlined,
                      title: 'Profile Visibility',
                      subtitle: 'Control who can see your profile details.',
                      trailingWidget: CupertinoSwitch(
                        value: controller.profileVisibility.value,
                        activeTrackColor: AppColors.primaryAccent,
                        onChanged: controller.toggleProfileVisibility,
                      ),
                      onTap: () => controller.toggleProfileVisibility(
                        !controller.profileVisibility.value,
                      ),
                    ),
                  ),
                  _buildDivider(),
                  _buildSettingsTile(
                    icon: Icons.history_edu_outlined,
                    title: 'Ride History',
                    subtitle: 'Manage who can see your recent trips.',
                    onTap: controller.goToRideHistory,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 2. ACCOUNT PRIVACY
              _buildSectionHeader('ACCOUNT PRIVACY'),
              _buildSettingsGroup(
                children: [
                  _buildSettingsTile(
                    icon: Icons.verified_user_outlined,
                    title: 'Two-Step Verification',
                    subtitle: 'Extra layer of security for your account.',
                    onTap: controller.goToTwoStepVerification,
                  ),
                  _buildDivider(),
                  _buildSettingsTile(
                    icon: Icons.block_outlined,
                    title: 'Blocked Users',
                    subtitle: 'Manage users you have blocked.',
                    onTap: controller.goToBlockedUsers,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 3. PERMISSIONS
              _buildSectionHeader('PERMISSIONS'),
              _buildSettingsGroup(
                children: [
                  _buildSettingsTile(
                    icon: Icons.location_on_outlined,
                    title: 'Location Access',
                    subtitle: 'Manage app location settings.',
                    trailingWidget: _buildStatusPill('WHILE USING'),
                    onTap: controller.manageLocationAccess,
                  ),
                  _buildDivider(),
                  Obx(
                    () => _buildSettingsTile(
                      icon: Icons.contact_phone_outlined,
                      title: 'Contacts Sync',
                      subtitle: 'Find friends using Savarii.',
                      trailingWidget: CupertinoSwitch(
                        value: controller.contactsSync.value,
                        activeTrackColor: AppColors.primaryAccent,
                        onChanged: controller.toggleContactsSync,
                      ),
                      onTap: () => controller.toggleContactsSync(
                        !controller.contactsSync.value,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 4. DATA MANAGEMENT
              _buildSectionHeader('DATA MANAGEMENT'),
              _buildSettingsGroup(
                children: [
                  _buildSettingsTile(
                    icon: Icons.file_download_outlined,
                    title: 'Download My Data',
                    subtitle: 'Get a copy of your Savarii information.',
                    onTap: controller.downloadMyData,
                  ),
                  _buildDivider(),
                  _buildSettingsTile(
                    icon: Icons.delete_outline,
                    title: 'Delete Account',
                    subtitle: 'Permanently remove your account.',
                    isDestructive: true,
                    // This triggers the red styling
                    onTap: controller.deleteAccount,
                  ),
                ],
              ),
              const SizedBox(height: 40), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }

  // --- Sub-Widgets ---

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
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
    bool isDestructive = false,
    required VoidCallback onTap,
  }) {
    // Determine colors based on whether it's a destructive action (like Delete Account)
    final Color itemColor = isDestructive
        ? AppColors.primaryAccent
        : AppColors.primaryDark;
    final Color iconBgColor = isDestructive
        ? AppColors.primaryAccent.withOpacity(0.1)
        : AppColors.lightBackground;
    final Color iconColor = isDestructive
        ? AppColors.primaryAccent
        : AppColors.secondaryGreyBlue;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyLarge.copyWith(
          fontWeight: FontWeight.w600,
          color: itemColor,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: AppTextStyles.caption.copyWith(
                color: isDestructive
                    ? AppColors.primaryAccent.withOpacity(0.7)
                    : AppColors.secondaryGreyBlue,
              ),
            )
          : null,
      trailing: trailingWidget ?? Icon(Icons.chevron_right, color: itemColor),
    );
  }

  Widget _buildStatusPill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.primaryAccent,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: AppColors.secondaryGreyBlue.withOpacity(0.1),
      height: 1,
      indent: 64, // Pushes the divider past the icon
      endIndent: 16,
    );
  }
}
