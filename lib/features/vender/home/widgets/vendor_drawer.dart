import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:savarii/core/theme/app_colors.dart';
import 'package:savarii/core/theme/app_text_styles.dart';
import 'package:savarii/features/vender/controllers/vendor_home_controller.dart';

class VendorDrawer extends GetView<VendorHomeController> {
  const VendorDrawer({super.key});

  // Dark theme colors specific to this drawer
  final Color drawerBg = const Color(0xFF2A2D3E);
  final Color cardBg = const Color(0xFF383B4D);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: drawerBg,
      child: SafeArea(
        child: Column(
          children: [
            // 1. Profile Section
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Column(
                children: [
                  Obx(() {
                    final imageUrl = controller.vendorProfileImageUrl.value;
                    ImageProvider? imageProvider;
                    if (imageUrl.isNotEmpty) {
                      imageProvider = NetworkImage(imageUrl);
                    }

                    return Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.lightBackground,
                        image: imageProvider != null
                            ? DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.cover,
                              )
                            : null,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryAccent.withOpacity(0.4),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: imageProvider == null
                          ? const Center(
                              child: Icon(
                                Icons.person,
                                color: AppColors.secondaryGreyBlue,
                                size: 40,
                              ),
                            )
                          : null,
                    );
                  }),
                  const SizedBox(height: 16),
                  Obx(() => Text(
                    controller.vendorName,
                    style: AppTextStyles.h2.copyWith(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  )),
                  const SizedBox(height: 4),
                  Obx(() => Text(
                    controller.vendorPhone,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white70,
                    ),
                  )),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            Divider(color: Colors.white.withOpacity(0.1), height: 1),
            const SizedBox(height: 16),

            // 2. Navigation Menu
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMenuItem(
                      Icons.home_filled,
                      'Home',
                      onTap: controller.closeDrawer,
                      isSelected: true,
                    ),
                    _buildMenuItem(
                      Icons.directions_bus_outlined,
                      'Bus Tracking',
                      onTap: controller.busTracking,
                    ),
                    _buildMenuItem(
                      Icons.translate,
                      'Language',
                      onTap: controller.goToLanguage,
                    ),
                    _buildMenuItem(
                      Icons.add_circle_outline,
                      'Add a Bus',
                      onTap: controller.addBusAndRoute,
                    ),
                    _buildMenuItem(
                      Icons.help_outline,
                      'Contact Developer',
                      onTap: controller.contactDeveloper,
                    ),

                    const SizedBox(height: 32),

                    // 3. Quick Stats
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        'QUICK STATS',
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.white54,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Obx(() => Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Active Buses',
                            controller.activeBuses.value,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            "Today's Trips",
                            controller.todaysTrips,
                          ),
                        ),
                      ],
                    )),
                  ],
                ),
              ),
            ),

            // 4. Logout Button & Footer
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: controller.logout,
                    icon: const Icon(
                      Icons.logout,
                      color: Colors.white,
                      size: 20,
                    ),
                    label: Text(
                      'Logout Account',
                      style: AppTextStyles.buttonText.copyWith(fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryAccent,
                      minimumSize: const Size(double.infinity, 54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'SAVARII VENDOR V2.4.1',
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white38,
                      letterSpacing: 1.5,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Sidebar Sub-Widgets ---

  Widget _buildMenuItem(
    IconData icon,
    String title, {
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primaryAccent : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: isSelected ? Colors.white : Colors.white70),
        title: Text(
          title,
          style: AppTextStyles.bodyLarge.copyWith(
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        dense: true,
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: Colors.white54,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 8),
          Text(value, style: AppTextStyles.h2.copyWith(color: Colors.white)),
        ],
      ),
    );
  }
}
