import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:savarii/core/theme/app_colors.dart';
import 'package:savarii/core/theme/app_text_styles.dart';
import '../controllers/vendor_edit_profile_controller.dart';

class VendorEditProfileView extends GetView<VendorEditProfileController> {
  const VendorEditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Text('profile.edit_profile'.tr(), style: AppTextStyles.h3),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryDark),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 16.0,
                ),
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. Profile Picture Section
                      _buildProfilePhotoSection(),
                      const SizedBox(height: 32),

                      // 2. Form Fields
                      _buildLabel('profile.full_name'.tr()),
                      _buildTextField(
                        controller.fullNameController,
                        hint: 'profile.full_name_hint'.tr(),
                      ),
                      const SizedBox(height: 20),

                      _buildLabel('profile.mobile_number'.tr()),
                      _buildTextField(
                        controller.mobileController,
                        hint: 'profile.mobile_hint'.tr(),
                        isPhone: true,
                      ),
                      const SizedBox(height: 20),

                      _buildLabel('profile.email_address'.tr()),
                      _buildTextField(
                        controller.emailController,
                        hint: 'profile.email_hint'.tr(),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 20),

                      
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),

            // 3. Sticky Bottom Button
            _buildStickySaveButton(),
          ],
        ),
      ),
    );
  }

  // --- Sub-Widgets ---

  Widget _buildProfilePhotoSection() {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            // Avatar
            Obx(() {
              final selectedFile = controller.selectedImage.value;
              final existingUrl = controller.existingImageUrl.value;
              
              ImageProvider? imageProvider;
              if (selectedFile != null) {
                imageProvider = FileImage(selectedFile);
              } else if (existingUrl.isNotEmpty) {
                imageProvider = NetworkImage(existingUrl);
              } else {
                imageProvider = const AssetImage('assets/images/vendor_profile.png');
              }
              
              return Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.secondaryGreyBlue.withOpacity(0.1),
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
                child: (selectedFile == null && existingUrl.isEmpty)
                    ? const Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.transparent, // fallback handled by asset
                      )
                    : null,
              );
            }),
            // Red Camera Icon
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: controller.changePhoto,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryAccent,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: AppColors.white,
                    size: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Change Photo Pill Button
        GestureDetector(
          onTap: controller.changePhoto,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.secondaryGreyBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'profile.change_photo'.tr(),
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryDark,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: AppTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.primaryDark,
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController textController, {
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    bool isPhone = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA), // Light grey background like mockup
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextFormField(
        controller: textController,
        keyboardType: isPhone ? TextInputType.phone : keyboardType,
        validator: (value) => value!.isEmpty ? 'common.error'.tr() : null,
        style: AppTextStyles.bodyLarge,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.secondaryGreyBlue.withOpacity(0.6),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          // Prefix for Phone
          prefixIcon: isPhone
              ? Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 12.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '+91',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.secondaryGreyBlue,
                        ),
                      ),
                    ],
                  ),
                )
              : null,
          prefixIconConstraints: isPhone
              ? const BoxConstraints(minWidth: 0, minHeight: 0)
              : null,
        ),
      ),
    );
  }

  Widget _buildStickySaveButton() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(color: AppColors.secondaryGreyBlue.withOpacity(0.1)),
        ),
      ),
      child: Obx(() => ElevatedButton(
        onPressed: controller.isLoading.value ? null : controller.saveChanges,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryAccent,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: controller.isLoading.value
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: AppColors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                'profile.save_changes'.tr(),
                style: AppTextStyles.buttonText.copyWith(fontSize: 16),
              ),
      )),
    );
  }
}
