import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:savarii/core/theme/app_colors.dart';
import 'package:savarii/core/theme/app_text_styles.dart';
import '../controllers/vendor_settings_controller.dart';

class VendorSettingsView extends GetView<VendorSettingsController> {
  const VendorSettingsView({super.key});

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
              _buildSectionTitle('ACCOUNT SETTINGS'),
              _buildCardGroup([
                _buildActionTile(
                  Icons.phone_android,
                  'Change Mobile Number',
                  onTap: controller.changeMobileNumber,
                  useRedIcon: true,
                ),
                _buildDivider(),
                _buildActionTile(
                  Icons.mail_outline,
                  'Change Email',
                  onTap: controller.changeEmail,
                  useRedIcon: true,
                ),
                _buildDivider(),
                _buildActionTile(
                  Icons.location_on_outlined,
                  'Update Address',
                  onTap: controller.updateAddress,
                  useRedIcon: true,
                ),
              ]),
              const SizedBox(height: 24),

              // 2. NOTIFICATION SETTINGS
              _buildSectionTitle('NOTIFICATION SETTINGS'),
              Obx(
                () => _buildCardGroup([
                  _buildToggleTile(
                    Icons.notifications_none,
                    'Push Notifications',
                    controller.pushNotifications.value,
                    controller.togglePushNotifications,
                  ),
                  _buildDivider(),
                  _buildToggleTile(
                    Icons.chat_bubble_outline,
                    'SMS Alerts',
                    controller.smsAlerts.value,
                    controller.toggleSmsAlerts,
                  ),
                  _buildDivider(),
                  _buildToggleTile(
                    Icons.alternate_email,
                    'Email Updates',
                    controller.emailUpdates.value,
                    controller.toggleEmailUpdates,
                  ),
                ]),
              ),
              const SizedBox(height: 24),

              // 3. APPLICATION
              _buildSectionTitle('APPLICATION'),
              Obx(
                () => _buildCardGroup([
                  _buildActionTile(
                    Icons.language,
                    'App Language',
                    trailingWidget: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          controller.currentLanguage.value,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primaryAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.chevron_right,
                          color: AppColors.secondaryGreyBlue,
                        ),
                      ],
                    ),
                    onTap: controller.changeLanguage,
                  ),
                  _buildDivider(),
                  _buildToggleTile(
                    Icons.dark_mode_outlined,
                    'Dark Mode',
                    controller.darkMode.value,
                    controller.toggleDarkMode,
                  ),
                ]),
              ),
              const SizedBox(height: 24),

              // 4. SUPPORT & LEGAL
              _buildSectionTitle('SUPPORT & LEGAL'),
              _buildCardGroup([
                _buildActionTile(
                  Icons.help_outline,
                  'Help Center',
                  trailingIcon: Icons.open_in_new,
                  onTap: controller.openHelpCenter,
                ),
                _buildDivider(),
                _buildActionTile(
                  Icons.shield_outlined,
                  'Privacy Policy',
                  onTap: controller.openPrivacyPolicy,
                ),
                _buildDivider(),
                _buildActionTile(
                  Icons.gavel_outlined,
                  'Terms & Conditions',
                  onTap: controller.openTerms,
                ),
                _buildDivider(),
                _buildActionTile(
                  Icons.info_outline,
                  'App Version',
                  trailingWidget: Text(
                    'v1.0.4',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.secondaryGreyBlue,
                    ),
                  ),
                  onTap: () {},
                ),
              ]),
              const SizedBox(height: 32),

              // 5. DEACTIVATE ACCOUNT
              GestureDetector(
                onTap: controller.deactivateAccount,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primaryAccent.withOpacity(0.2),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.secondaryGreyBlue.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.person_off_outlined,
                        color: AppColors.primaryAccent,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Deactivate Account',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.primaryAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // --- Sub-Widgets ---

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.secondaryGreyBlue,
          letterSpacing: 1.2,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildCardGroup(List<Widget> children) {
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

  Widget _buildActionTile(
    IconData icon,
    String title, {
    bool useRedIcon = false,
    IconData trailingIcon = Icons.chevron_right,
    Widget? trailingWidget,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: useRedIcon
              ? AppColors.primaryAccent.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: useRedIcon
              ? AppColors.primaryAccent
              : AppColors.secondaryGreyBlue,
          size: 22,
        ),
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyLarge.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.primaryDark,
        ),
      ),
      trailing:
          trailingWidget ??
          Icon(trailingIcon, color: AppColors.secondaryGreyBlue, size: 20),
    );
  }

  Widget _buildToggleTile(
    IconData icon,
    String title,
    bool value,
    Function(bool) onChanged,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(icon, color: AppColors.secondaryGreyBlue, size: 22),
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyLarge.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.primaryDark,
        ),
      ),
      trailing: CupertinoSwitch(
        value: value,
        activeTrackColor: AppColors.primaryAccent,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: AppColors.secondaryGreyBlue.withOpacity(0.1),
      height: 1,
      indent: 56, // Push past the icon
      endIndent: 16,
    );
  }
}
