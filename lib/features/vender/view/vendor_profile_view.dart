import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:savarii/core/theme/app_colors.dart';
import 'package:savarii/core/theme/app_text_styles.dart';
import '../controllers/vendor_profile_controller.dart';

class VendorProfileView extends GetView<VendorProfileController> {
  const VendorProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white, // Using white background as per mockup
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text('Vendor Profile', style: AppTextStyles.h3),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppColors.primaryDark),
            onPressed: controller.openMenu,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 1. Profile Avatar & Name
              const SizedBox(height: 16),
              _buildProfileHeader(),
              const SizedBox(height: 24),
              Divider(
                color: AppColors.secondaryGreyBlue.withOpacity(0.1),
                height: 1,
              ),

              // 2. Stats Row (Trips, Rating, Vehicles)
              _buildStatsRow(),
              Divider(
                color: AppColors.secondaryGreyBlue.withOpacity(0.1),
                height: 1,
              ),

              // 3. Info Cards (Email & Travels Name)
              Container(
                color: AppColors.lightBackground.withOpacity(0.5),
                // Slight grey background for this section
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Column(
                  children: [
                    Obx(
                      () => _buildInfoCard(
                        icon: Icons.email,
                        label: 'EMAIL ADDRESS',
                        value: controller.vendorEmail,
                        trailing: const Icon(
                          Icons.verified,
                          color: Colors.green,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Obx(() {
                      return _buildInfoCard(
                        icon: Icons.directions_bus,
                        label: 'TRAVELS NAME',
                        value: controller.vendorBusinessName,
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: AppColors.secondaryGreyBlue,
                        ),
                      );
                    }),
                  ],
                ),
              ),
              Divider(
                color: AppColors.secondaryGreyBlue.withOpacity(0.1),
                height: 1,
              ),

              // 4. Menu List Options
              _buildMenuItem(
                Icons.edit_document,
                'Edit Profile Information',
                onTap: controller.editProfileInfo,
              ),
              Divider(
                color: AppColors.secondaryGreyBlue.withOpacity(0.1),
                height: 1,
                indent: 64,
              ),

              _buildMenuItem(
                Icons.add_business,
                'Add a Travels',
                onTap: controller.addTravels,
              ),
              Divider(
                color: AppColors.secondaryGreyBlue.withOpacity(0.1),
                height: 1,
                indent: 64,
              ),

              _buildMenuItem(
                Icons.business,
                'Travels Detail',
                onTap: controller.goToTravelsDetail,
              ),
              Divider(
                color: AppColors.secondaryGreyBlue.withOpacity(0.1),
                height: 1,
                indent: 64,
              ),

              _buildMenuItem(
                Icons.settings,
                'Settings',
                onTap: controller.goToSettings,
              ),
              Divider(
                color: AppColors.secondaryGreyBlue.withOpacity(0.1),
                height: 1,
                indent: 64,
              ),

              // Logout Button
              ListTile(
                onTap: controller.logout,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 4,
                ),
                leading: const Icon(
                  Icons.logout,
                  color: AppColors.primaryAccent,
                ),
                title: Text(
                  'Logout',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.primaryAccent,
                    fontWeight: FontWeight.bold,
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

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Stack(
          children: [
            // Profile Picture
            Obx(() {
              final imageUrl = controller.profileImageUrl.value;
                  
              ImageProvider? imageProvider;
              if (imageUrl.isNotEmpty) {
                imageProvider = NetworkImage(imageUrl);
              } else {
                imageProvider = const AssetImage('assets/images/person1.png');
              }
              
              return Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primaryAccent.withOpacity(0.2),
                    width: 3,
                  ),
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
                child: imageUrl.isEmpty
                    ? const Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.transparent,
                      )
                    : null,
              );
            }),
            // Edit Badge
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: controller.editProfileImage,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryAccent,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.edit,
                    color: AppColors.white,
                    size: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Obx(
          () => Text(
            controller.vendorName,
            style: AppTextStyles.h2.copyWith(fontSize: 22),
          ),
        ),
        const SizedBox(height: 4),
        Obx(
          () => Text(
            controller.vendorPhone,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.secondaryGreyBlue,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatItem('TRIPS', controller.trips),
            VerticalDivider(
              color: AppColors.secondaryGreyBlue.withOpacity(0.2),
              thickness: 1,
            ),
            _buildStatItem('RATING', '${controller.rating} ★'),
            VerticalDivider(
              color: AppColors.secondaryGreyBlue.withOpacity(0.2),
              thickness: 1,
            ),
            _buildStatItem('VEHICLES', controller.vehicles),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.secondaryGreyBlue,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTextStyles.h2.copyWith(
            color: AppColors.primaryAccent,
            fontSize: 18,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Widget trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primaryAccent, size: 20),
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
                    fontSize: 10,
                    letterSpacing: 0.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title, {
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: Icon(icon, color: AppColors.secondaryGreyBlue, size: 24),
      title: Text(
        title,
        style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: AppColors.secondaryGreyBlue,
      ),
    );
  }
}
