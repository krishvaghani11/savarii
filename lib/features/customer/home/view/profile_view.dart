import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:savarii/core/theme/app_colors.dart';
import 'package:savarii/core/theme/app_text_styles.dart';
import 'package:savarii/features/customer/home/controller/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text('My Profile', style: AppTextStyles.h3),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.primaryDark),
            onPressed: controller.goToEditProfile,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          children: [
            // 1. Profile Image & Info
            _buildProfileHeader(),
            const SizedBox(height: 32),

            // 2. Account Sections
            _buildProfileSection(
              title: 'Account Settings',
              items: [
                _buildProfileItem(
                  icon: Icons.person_outline,
                  label: 'Personal Information',
                  onTap: controller.goToEditProfile,
                ),
                _buildProfileItem(
                  icon: Icons.history,
                  label: 'Trip History',
                  onTap: controller.goToTicketHistory,
                ),
                _buildProfileItem(
                  icon: Icons.bookmark_border,
                  label: 'Saved Routes',
                  onTap: controller.goToSavedRoutes,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 3. App Settings
            _buildProfileSection(
              title: 'Preferences',
              items: [
                _buildProfileItem(
                  icon: Icons.notifications_none,
                  label: 'Notifications',
                  onTap: () => Get.toNamed('/notification-settings'),
                ),
                _buildProfileItem(
                  icon: Icons.language,
                  label: 'Language',
                  onTap: () => Get.toNamed('/language'),
                ),
                _buildProfileItem(
                  icon: Icons.settings_outlined,
                  label: 'Settings',
                  onTap: controller.goToSettings,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 4. Logout Button
            _buildLogoutButton(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Stack(
          children: [
            Obx(() => CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.secondaryGreyBlue.withValues(
                alpha: 0.1,
              ),
              backgroundImage: controller.profileImageUrl.value.isNotEmpty
                  ? NetworkImage(controller.profileImageUrl.value)
                  : null,
              child: controller.profileImageUrl.value.isEmpty
                  ? const Icon(
                      Icons.person,
                      size: 50,
                      color: AppColors.primaryDark,
                    )
                  : null,
            )),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: controller.editProfilePicture,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: AppColors.primaryAccent,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: AppColors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Obx(() => Text(controller.userName.value, style: AppTextStyles.h2)),
        const SizedBox(height: 4),
        Obx(
          () => Text(
            controller.phoneNumber.value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.secondaryGreyBlue,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileSection({
    required String title,
    required List<Widget> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.h3.copyWith(fontSize: 16)),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.secondaryGreyBlue.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildProfileItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryDark, size: 22),
      title: Text(label, style: AppTextStyles.bodyLarge),
      trailing: const Icon(
        Icons.chevron_right,
        color: AppColors.secondaryGreyBlue,
        size: 20,
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  Widget _buildLogoutButton() {
    return ElevatedButton.icon(
      onPressed: controller.logOut,
      icon: const Icon(Icons.logout, color: AppColors.dangerRed),
      label: Text(
        'Log Out',
        style: AppTextStyles.buttonText.copyWith(color: AppColors.dangerRed),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.white,
        minimumSize: const Size(double.infinity, 54),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.dangerRed.withValues(alpha: 0.2)),
        ),
        elevation: 0,
      ),
    );
  }
}
