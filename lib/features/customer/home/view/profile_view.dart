import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:savarii/features/customer/home/controller/main_layout_controller.dart';
import 'package:savarii/features/customer/home/controller/profile_controller.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    // Fallback injection just in case the binding isn't triggered during testing
    if (!Get.isRegistered<ProfileController>()) {
      Get.put(ProfileController());
    }

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text('Profile', style: AppTextStyles.h3),
        // A back arrow on a bottom nav tab usually isn't standard, but since it's in your
        // design, we can map it to return to the Home tab (index 0) of the dashboard.
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryDark),
          onPressed: () {
            // Assuming MainLayoutController is managing the tabs
            if (Get.isRegistered<MainLayoutController>()) {
              Get.find<MainLayoutController>().changeTab(0);
            } else {
              Get.back();
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppColors.primaryDark),
            onPressed: () {}, // 3-dots menu action
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Profile Picture & Edit Button
              _buildProfilePicture(),
              const SizedBox(height: 16),

              // 2. User Name & Phone Number
              Obx(
                () => Text(
                  controller.userName.value,
                  style: AppTextStyles.h2.copyWith(fontSize: 24),
                ),
              ),
              const SizedBox(height: 4),
              Obx(
                () => Text(
                  controller.phoneNumber.value,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.secondaryGreyBlue,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // 3. Menu Options Card
              _buildMenuCard(),
              const SizedBox(height: 32),

              // 4. Logout Button
              _buildLogoutButton(),

              const SizedBox(height: 40), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }

  // --- Sub-Widgets ---

  Widget _buildProfilePicture() {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        // Profile Avatar
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.secondaryGreyBlue.withOpacity(0.2),
            border: Border.all(color: AppColors.white, width: 4),
            boxShadow: [
              BoxShadow(
                color: AppColors.secondaryGreyBlue.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const ClipOval(
            child: Icon(Icons.person, size: 60, color: AppColors.primaryDark),
            // TODO: Replace with real image when ready
            // child: Image.asset('assets/images/user_profile.png', fit: BoxFit.cover),
          ),
        ),

        // Edit Icon
        GestureDetector(
          onTap: controller.editProfilePicture,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primaryAccent,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.white, width: 3),
            ),
            child: const Icon(Icons.edit, color: AppColors.white, size: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuCard() {
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
        children: [
          _buildMenuItem(
            icon: Icons.person_outline,
            title: 'Edit Profile',
            onTap: controller.goToEditProfile,
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.history, // A classic clock/history icon
            title: 'Ticket History',
            onTap: controller.goToTicketHistory,
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.map_outlined,
            title: 'Saved Routes',
            onTap: controller.goToSavedRoutes,
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.card_giftcard_outlined,
            title: 'My Rewards',
            onTap: controller.goToMyRewards,
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.settings_outlined,
            title: 'Settings',
            onTap: controller.goToSettings,
            isLast: true, // Removes bottom padding if needed
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.lightBackground, // Soft grey background for the icon
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.primaryDark, size: 22),
      ),
      title: Text(title, style: AppTextStyles.h3.copyWith(fontSize: 16)),
      trailing: const Icon(
        Icons.chevron_right,
        color: AppColors.secondaryGreyBlue,
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: AppColors.secondaryGreyBlue.withOpacity(0.1),
      height: 1,
      indent: 20,
      endIndent: 20,
    );
  }

  Widget _buildLogoutButton() {
    return ElevatedButton.icon(
      onPressed: controller.logOut,
      icon: const Icon(Icons.logout, color: AppColors.primaryAccent),
      // Red icon
      label: Text(
        'Log Out',
        style: AppTextStyles.buttonText.copyWith(
          color: AppColors.primaryAccent,
        ),
      ),
      // Red text
      style: ElevatedButton.styleFrom(
        // Soft red background exactly like the mockup
        backgroundColor: AppColors.primaryAccent.withOpacity(0.15),
        elevation: 0,
        // Flat design
        padding: const EdgeInsets.symmetric(vertical: 16),
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
