import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:savarii/core/theme/app_colors.dart';
import 'package:savarii/core/theme/app_text_styles.dart';

import '../controllers/driver_management_controller.dart';

class DriverManagementView extends GetView<DriverManagementController> {
  const DriverManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground, // Light grey background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Text('Driver Management', style: AppTextStyles.h3),
        // Using an arrow_back so the vendor can return to the home screen
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryDark),
          onPressed: () => Get.back(),
        ),
        // Profile icon excluded as requested
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Header Section
              Text(
                'Fleet Management',
                style: AppTextStyles.h1.copyWith(color: AppColors.primaryDark, fontSize: 24),
              ),
              const SizedBox(height: 8),
              Text(
                'Monitor and manage your professional driving\npartners.',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.secondaryGreyBlue),
              ),
              const SizedBox(height: 24),

              // 2. Add Driver Button
              ElevatedButton(
                onPressed: controller.addDriver,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryAccent,
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                  shadowColor: AppColors.primaryAccent.withOpacity(0.4),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add, color: AppColors.white, size: 20),
                    const SizedBox(width: 8),
                    Text('Add Driver', style: AppTextStyles.buttonText.copyWith(fontSize: 16)),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward, color: AppColors.white, size: 18),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 3. Stats Cards
              _buildStatCard(
                title: 'TOTAL DRIVERS',
                value: controller.totalDrivers.toString(),
                icon: Icons.people_alt_outlined,
                iconColor: AppColors.primaryAccent,
                bgColor: AppColors.primaryAccent.withOpacity(0.1),
              ),
              const SizedBox(height: 12),
              _buildStatCard(
                title: 'ACTIVE NOW',
                value: controller.activeDrivers.toString(),
                icon: Icons.check_circle_outline,
                iconColor: Colors.green.shade600,
                bgColor: Colors.green.shade50,
              ),
              const SizedBox(height: 12),
              _buildStatCard(
                title: 'ON TRIP',
                value: controller.onTripDrivers.toString(),
                icon: Icons.local_shipping_outlined,
                iconColor: Colors.blue.shade600,
                bgColor: Colors.blue.shade50,
              ),
              const SizedBox(height: 32),

              // 4. Drivers List
              Obx(() => Column(
                    children: controller.drivers.map((driver) => _buildDriverCard(driver)).toList(),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  // --- Sub-Widgets ---

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryGreyBlue.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: AppTextStyles.h2.copyWith(fontSize: 22, color: AppColors.primaryDark),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDriverCard(Map<String, dynamic> driver) {
    bool isActive = driver['status'] == 'ACTIVE';
    Color statusColor = isActive ? Colors.green.shade600 : Colors.blue.shade600;
    Color statusBgColor = isActive ? Colors.green.shade50 : Colors.blue.shade50;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Side: Avatar and Status Dot
          Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  driver['image'],
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 60,
                    height: 60,
                    color: AppColors.secondaryGreyBlue.withOpacity(0.1),
                    child: const Icon(Icons.person, color: AppColors.secondaryGreyBlue),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),

          // Middle: Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        driver['name'],
                        style: AppTextStyles.h3.copyWith(fontSize: 16),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusBgColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        driver['status'],
                        style: AppTextStyles.caption.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 9,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.phone_outlined, size: 14, color: AppColors.secondaryGreyBlue),
                    const SizedBox(width: 6),
                    Text(
                      driver['phone'],
                      style: AppTextStyles.caption.copyWith(color: AppColors.secondaryGreyBlue),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2.0),
                      child: Icon(Icons.badge_outlined, size: 14, color: AppColors.secondaryGreyBlue),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'DL-\n${driver['dl']}',
                        style: AppTextStyles.caption.copyWith(color: AppColors.secondaryGreyBlue, height: 1.2),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Right Side: Options & Details
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => controller.showDriverOptions(driver['id']),
                child: const Icon(Icons.more_vert, color: AppColors.primaryDark),
              ),
              const SizedBox(height: 32),
              GestureDetector(
                onTap: () => controller.viewDriverDetails(driver['id']),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Details',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primaryAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(Icons.chevron_right, color: AppColors.primaryAccent, size: 16),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}