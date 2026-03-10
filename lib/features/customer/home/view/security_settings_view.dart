import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:savarii/core/theme/app_colors.dart';
import 'package:savarii/core/theme/app_text_styles.dart';
import 'package:savarii/features/customer/home/controller/security_settings_controller.dart';

class SecuritySettingsView extends GetView<SecuritySettingsController> {
  const SecuritySettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Text('Security', style: AppTextStyles.h3),
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
              // 1. LOGIN SECURITY
              _buildSectionHeader('LOGIN SECURITY'),
              _buildSettingsGroup(
                children: [
                  Obx(
                    () => _buildToggleTile(
                      icon: Icons.fingerprint,
                      title: 'Biometric Authentication',
                      value: controller.biometricAuth.value,
                      onChanged: controller.toggleBiometric,
                    ),
                  ),
                  _buildDivider(),
                  Obx(
                    () => _buildToggleTile(
                      icon: Icons.person_outline,
                      title: 'Remember Me',
                      value: controller.rememberMe.value,
                      onChanged: controller.toggleRememberMe,
                    ),
                  ),
                  _buildDivider(),
                  _buildNavigationTile(
                    icon: Icons.lock_reset,
                    // You can also use Icons.password if available
                    title: 'Change PIN/Password',
                    onTap: controller.goToChangePassword,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 2. ACCOUNT PROTECTION
              _buildSectionHeader('ACCOUNT PROTECTION'),
              _buildSettingsGroup(
                children: [
                  Obx(
                    () => _buildToggleTile(
                      icon: Icons.verified_user_outlined,
                      title: 'Two-Step Verification',
                      value: controller.twoStepVerification.value,
                      onChanged: controller.toggleTwoStep,
                    ),
                  ),
                  _buildDivider(),
                  _buildNavigationTile(
                    icon: Icons.devices,
                    title: 'Trusted Devices',
                    onTap: controller.goToTrustedDevices,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 3. ACTIVITY (Active Sessions & Alerts)
              _buildSectionHeader('ACTIVITY'),
              _buildSettingsGroup(
                children: [
                  // Active Sessions Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.history,
                          color: AppColors.secondaryGreyBlue,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Active Sessions',
                          style: AppTextStyles.bodyMedium,
                        ),
                      ],
                    ),
                  ),

                  // Device 1
                  _buildDeviceRow(
                    icon: Icons.phone_iphone,
                    deviceName: 'iPhone 15 Pro (Current)',
                    locationTime: 'SAN FRANCISCO, USA • ONLINE',
                  ),

                  // Device 2
                  _buildDeviceRow(
                    icon: Icons.laptop_mac,
                    deviceName: 'MacBook Air M2',
                    locationTime: 'LONDON, UK • 2 HRS AGO',
                  ),

                  _buildDivider(indent: 16),
                  // Full width divider for this section

                  // Security Alerts Toggle
                  Obx(
                    () => _buildToggleTile(
                      icon: Icons.notifications_active_outlined,
                      title: 'Security Alerts',
                      value: controller.securityAlerts.value,
                      onChanged: controller.toggleSecurityAlerts,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }

  Widget _buildToggleTile({
    required IconData icon,
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Icon(icon, color: AppColors.secondaryGreyBlue, size: 24),
      title: Text(title, style: AppTextStyles.bodyLarge),
      trailing: CupertinoSwitch(
        value: value,
        activeColor: AppColors.primaryAccent,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildNavigationTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Icon(icon, color: AppColors.secondaryGreyBlue, size: 24),
      title: Text(title, style: AppTextStyles.bodyLarge),
      trailing: const Icon(
        Icons.chevron_right,
        color: AppColors.secondaryGreyBlue,
      ),
    );
  }

  Widget _buildDeviceRow({
    required IconData icon,
    required String deviceName,
    required String locationTime,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Device Icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: AppColors.lightBackground, // Grey background circle
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primaryDark, size: 20),
          ),
          const SizedBox(width: 16),

          // Device Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  deviceName,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  locationTime,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.secondaryGreyBlue,
                    fontSize: 10,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          // Logout Button
          OutlinedButton(
            onPressed: () => controller.logoutDevice(deviceName),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryAccent,
              side: BorderSide(color: AppColors.primaryAccent.withOpacity(0.3)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              minimumSize: const Size(0, 32), // Makes the button compact
            ),
            child: Text(
              'LOGOUT',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.primaryAccent,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider({double indent = 56}) {
    return Divider(
      color: AppColors.secondaryGreyBlue.withOpacity(0.1),
      height: 1,
      indent: indent, // Pushes the divider past the icon (default 56)
      endIndent: 16,
    );
  }
}
