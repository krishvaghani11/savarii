import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:savarii/core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../controllers/role_selection_controller.dart';

class RoleSelectionView extends GetView<RoleSelectionController> {
  const RoleSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Row: App Name & Help Icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [Text('Savarii', style: AppTextStyles.h3)],
              ),
              const SizedBox(height: 40),

              // Title Section
              Text(
                'Continue as',
                style: AppTextStyles.h1.copyWith(fontSize: 32),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Select your account type to proceed',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.secondaryGreyBlue,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Customer Card
              _buildRoleCard(
                roleId: 'customer',
                title: 'Customer',
                subtitle:
                    'Book rides for your daily commute and send parcels easily across the city.',
                iconData: Icons.person,
              ),

              const SizedBox(height: 20),

              // Vendor Card
              _buildRoleCard(
                roleId: 'vendor',
                title: 'Vendor',
                subtitle:
                    'Drive with us, manage your fleet, or handle delivery logistics efficiently.',
                iconData: Icons.local_shipping,
              ),

              const Spacer(),

              // Bottom Continue Button
              ElevatedButton(
                onPressed: controller.continueToNextScreen,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Continue',
                      style: AppTextStyles.buttonText.copyWith(fontSize: 18),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward,
                      color: AppColors.white,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Reusable widget for the selection cards
  Widget _buildRoleCard({
    required String roleId,
    required String title,
    required String subtitle,
    required IconData iconData,
  }) {
    return Obx(() {
      final isSelected = controller.selectedRole.value == roleId;

      return GestureDetector(
        onTap: () => controller.selectRole(roleId),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? AppColors.primaryAccent
                  : AppColors.secondaryGreyBlue.withOpacity(0.2),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.secondaryGreyBlue.withOpacity(0.05),
                blurRadius: 10,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Circular Icon Background
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryAccent.withOpacity(0.1)
                          : AppColors.lightBackground,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      iconData,
                      color: isSelected
                          ? AppColors.primaryAccent
                          : AppColors.secondaryGreyBlue,
                      size: 24,
                    ),
                  ),

                  // Checkmark indicator
                  Icon(
                    isSelected ? Icons.check_circle : Icons.circle_outlined,
                    color: isSelected
                        ? AppColors.primaryAccent
                        : AppColors.secondaryGreyBlue.withOpacity(0.3),
                    size: 28,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(title, style: AppTextStyles.h3.copyWith(fontSize: 18)),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.secondaryGreyBlue,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
