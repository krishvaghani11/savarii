import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:savarii/core/theme/app_colors.dart';
import 'package:savarii/core/theme/app_text_styles.dart';
import 'package:savarii/features/customer/home/controller/notification_settings_controller.dart';

class NotificationSettingsView extends GetView<NotificationSettingsController> {
  const NotificationSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        // Dark background from the mockup
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Notification Settings',
          style: AppTextStyles.h3.copyWith(color: AppColors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. GENERAL NOTIFICATIONS
              _buildSectionHeader(
                Icons.settings_outlined,
                'GENERAL NOTIFICATIONS',
              ),
              _buildSettingsGroup(
                children: [
                  Obx(
                    () => _buildToggleTile(
                      icon: Icons.notifications_active_outlined,
                      iconColor: AppColors.primaryAccent,
                      // Red icon for this specific one
                      iconBgColor: AppColors.primaryAccent.withOpacity(0.1),
                      title: 'Push Notifications',
                      subtitle: 'Receive alerts on your lock screen',
                      value: controller.pushNotifications.value,
                      onChanged: (val) => controller.toggleSetting(
                        controller.pushNotifications,
                        val,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 2. TRAVEL UPDATES
              _buildSectionHeader(
                Icons.directions_bus_outlined,
                'TRAVEL UPDATES',
              ),
              _buildSettingsGroup(
                children: [
                  Obx(
                    () => _buildToggleTile(
                      icon: Icons.confirmation_number_outlined,
                      title: 'Booking Confirmations',
                      value: controller.bookingConfirmations.value,
                      onChanged: (val) => controller.toggleSetting(
                        controller.bookingConfirmations,
                        val,
                      ),
                    ),
                  ),
                  _buildDivider(),
                  Obx(
                    () => _buildToggleTile(
                      icon: Icons.location_on_outlined,
                      title: 'Bus Tracking Alerts',
                      value: controller.busTrackingAlerts.value,
                      onChanged: (val) => controller.toggleSetting(
                        controller.busTrackingAlerts,
                        val,
                      ),
                    ),
                  ),
                  _buildDivider(),
                  Obx(
                    () => _buildToggleTile(
                      icon: Icons.warning_amber_outlined,
                      title: 'Delay Notifications',
                      titleColor: AppColors.primaryAccent,
                      // Red text as shown in mockup
                      value: controller.delayNotifications.value,
                      onChanged: (val) => controller.toggleSetting(
                        controller.delayNotifications,
                        val,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 3. PARCEL SERVICES
              _buildSectionHeader(
                Icons.inventory_2_outlined,
                'PARCEL SERVICES',
              ),
              _buildSettingsGroup(
                children: [
                  Obx(
                    () => _buildToggleTile(
                      icon: Icons.assignment_turned_in_outlined,
                      title: 'Parcel Pickup Alerts',
                      value: controller.parcelPickupAlerts.value,
                      onChanged: (val) => controller.toggleSetting(
                        controller.parcelPickupAlerts,
                        val,
                      ),
                    ),
                  ),
                  _buildDivider(),
                  Obx(
                    () => _buildToggleTile(
                      icon: Icons.local_shipping_outlined,
                      title: 'Delivery Status Updates',
                      value: controller.deliveryStatusUpdates.value,
                      onChanged: (val) => controller.toggleSetting(
                        controller.deliveryStatusUpdates,
                        val,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 4. PROMOTIONS & OFFERS
              _buildSectionHeader(
                Icons.local_offer_outlined,
                'PROMOTIONS & OFFERS',
              ),
              _buildSettingsGroup(
                children: [
                  Obx(
                    () => _buildToggleTile(
                      icon: Icons.card_giftcard,
                      title: 'Exclusive Deals',
                      value: controller.exclusiveDeals.value,
                      onChanged: (val) => controller.toggleSetting(
                        controller.exclusiveDeals,
                        val,
                      ),
                    ),
                  ),
                  _buildDivider(),
                  Obx(
                    () => _buildToggleTile(
                      icon: Icons.account_balance_wallet_outlined,
                      title: 'Wallet Cashback Alerts',
                      value: controller.walletCashbackAlerts.value,
                      onChanged: (val) => controller.toggleSetting(
                        controller.walletCashbackAlerts,
                        val,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // --- Sub-Widgets ---

  Widget _buildSectionHeader(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.secondaryGreyBlue, size: 18),
          const SizedBox(width: 8),
          Text(
            title,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.secondaryGreyBlue,
              letterSpacing: 1.2,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
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

  Widget _buildToggleTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? titleColor,
    Color? iconColor,
    Color? iconBgColor,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: iconBgColor ?? AppColors.lightBackground,
          // Grey by default, custom if provided
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor ?? AppColors.primaryDark, size: 22),
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyLarge.copyWith(
          fontWeight: FontWeight.w600,
          color:
              titleColor ??
              AppColors
                  .primaryDark, // Defaults to dark, overrides to red if passed
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.secondaryGreyBlue,
              ),
            )
          : null,
      trailing: CupertinoSwitch(
        value: value,
        activeColor: AppColors.primaryAccent, // Red when ON
        onChanged: onChanged,
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
