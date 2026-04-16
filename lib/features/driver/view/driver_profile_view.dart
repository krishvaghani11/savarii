import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:savarii/core/theme/app_colors.dart';
import 'package:savarii/core/theme/app_text_styles.dart';
import 'package:savarii/features/driver/controller/driver_profile_controller.dart';


class DriverProfileView extends GetView<DriverProfileController> {
  const DriverProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9), // Light greyish background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text('Profile', style: AppTextStyles.h3.copyWith(color: AppColors.primaryDark)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryDark),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppColors.primaryDark),
            onPressed: controller.showMoreOptions,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Avatar & Verification Badge
              _buildAvatarSection(),
              const SizedBox(height: 16),

              // 2. Name & Join Date
              Text(
                controller.driverName,
                style: AppTextStyles.h1.copyWith(fontSize: 24, color: const Color(0xFF2A2D3E)), // Dark Navy
              ),
              const SizedBox(height: 4),
              Text(
                'Driver ID: ${controller.driverId}',
                style: AppTextStyles.caption.copyWith(color: AppColors.secondaryGreyBlue),
              ),
              const SizedBox(height: 2),
              Text(
                controller.joinDate,
                style: AppTextStyles.caption.copyWith(color: AppColors.secondaryGreyBlue),
              ),
              const SizedBox(height: 32),

              // 3. Stats Row (Rating, Trips, Earnings)
              _buildStatsRow(),
              const SizedBox(height: 24),

              // 4. Details Card (Phone, Vehicle, DL)
              _buildDetailsCard(),
              const SizedBox(height: 24),

              // 5. Menu Items
              _buildMenuTile(
                icon: Icons.edit_note,
                title: 'Edit Profile',
                onTap: controller.editProfile,
              ),
              const SizedBox(height: 12),
              _buildMenuTile(
                icon: Icons.description_outlined,
                title: 'Vehicle Documents',
                onTap: controller.viewVehicleDocuments,
              ),
              const SizedBox(height: 12),
              _buildMenuTile(
                icon: Icons.headset_mic_outlined,
                title: 'Support',
                onTap: controller.openSupport,
              ),
              const SizedBox(height: 12),
              _buildMenuTile(
                icon: Icons.settings_outlined,
                title: 'Settings',
                onTap: controller.openSettings,
              ),
              const SizedBox(height: 32),

              // 6. Log Out Button
              ElevatedButton(
                onPressed: controller.logOut,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryAccent, // Red
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28), // Pill shape
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Log Out',
                  style: AppTextStyles.buttonText.copyWith(fontSize: 16),
                ),
              ),
              const SizedBox(height: 40), // Bottom Buffer
            ],
          ),
        ),
      ),
    );
  }

  // --- Sub-Widgets ---

  Widget _buildAvatarSection() {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          padding: const EdgeInsets.all(4), // Space for outer border
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primaryAccent.withOpacity(0.3), width: 2),
          ),
          child: const CircleAvatar(
            radius: 50,
            backgroundColor: Colors.transparent,
            backgroundImage: NetworkImage(
              'https://i.pravatar.cc/150?img=11', // Placeholder image matching the mockup vibe
            ),
          ),
        ),
        // Verification Badge
        Positioned(
          bottom: 4,
          right: 4,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.primaryAccent,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.white, width: 2),
            ),
            child: const Icon(
              Icons.verified, // Using a check/verified icon
              color: AppColors.white,
              size: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatCard(
          icon: Icons.star,
          value: controller.rating,
          label: 'RATING',
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          icon: Icons.swap_calls, // Closest match to the route icon
          value: controller.totalTrips,
          label: 'TRIPS',
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          icon: Icons.account_balance_wallet_outlined,
          value: controller.totalEarnings,
          label: 'EARNINGS',
        ),
      ],
    );
  }

  Widget _buildStatCard({required IconData icon, required String value, required String label}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
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
          children: [
            Icon(icon, color: AppColors.primaryAccent, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTextStyles.h2.copyWith(fontSize: 18, color: const Color(0xFF2A2D3E)),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.secondaryGreyBlue,
                fontSize: 9,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryGreyBlue.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildDetailRow(
            icon: Icons.phone_android,
            label: 'MOBILE NUMBER',
            value: controller.mobileNumber,
          ),
          const SizedBox(height: 24),
          _buildDetailRow(
            icon: Icons.directions_bus_outlined,
            label: 'VEHICLE DETAILS',
            value: controller.vehicleDetails,
          ),
          const SizedBox(height: 24),
          _buildDetailRow(
            icon: Icons.badge_outlined,
            label: 'DRIVING LICENSE',
            value: controller.drivingLicense,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({required IconData icon, required String label, required String value}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.secondaryGreyBlue.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.secondaryGreyBlue, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.secondaryGreyBlue,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2A2D3E), // Dark Navy
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuTile({required IconData icon, required String title, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondaryGreyBlue.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.secondaryGreyBlue, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2A2D3E), // Dark Navy
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.secondaryGreyBlue, size: 20),
          ],
        ),
      ),
    );
  }
}