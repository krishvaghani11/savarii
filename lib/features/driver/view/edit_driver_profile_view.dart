import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:savarii/core/theme/app_colors.dart';
import 'package:savarii/core/theme/app_text_styles.dart';
import 'package:savarii/features/driver/controller/edit_driver_profile_controller.dart';


class EditDriverProfileView extends GetView<EditDriverProfileController> {
  const EditDriverProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Title is placed in the center per standard platform guidelines, 
        // though the mockup shows it on the left.
        centerTitle: true,
        title: Text(
          'Edit Profile',
          style: AppTextStyles.h3.copyWith(color: AppColors.primaryDark),
        ),
        // Overriding leading to remove the default back arrow
        leading: const SizedBox.shrink(),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.primaryAccent), // Red close icon
            onPressed: controller.closeScreen,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Profile Picture Section
                _buildProfilePictureSection(),
                const SizedBox(height: 40),

                // 2. Input Fields Section
                _buildInputField(
                  controller: controller.nameController,
                  labelText: 'Full Name',
                  hintText: 'John Doe',
                ),
                const SizedBox(height: 24),

                // Phone field is special due to the country prefix
                _buildPhoneField(),
                const SizedBox(height: 24),

                _buildInputField(
                  controller: controller.emailController,
                  labelText: 'Email ID',
                  hintText: 'john.doe@logistics.com',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 48),

                // 3. Save Button
                Obx(() => ElevatedButton(
                  onPressed: controller.isLoading.value ? null : controller.saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryAccent,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28), // Pill shape
                    ),
                    elevation: 4,
                    shadowColor: AppColors.primaryAccent.withOpacity(0.4),
                  ),
                  child: controller.isLoading.value
                      ? const CircularProgressIndicator(color: AppColors.white)
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Save Changes',
                              style: AppTextStyles.buttonText.copyWith(fontSize: 16),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward, color: AppColors.white, size: 20),
                          ],
                        ),
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Sub-Widgets ---

  Widget _buildProfilePictureSection() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Obx(() {
                 ImageProvider? bgImage;
                 if (controller.localProfilePic.value != null) {
                    bgImage = FileImage(controller.localProfilePic.value!);
                 } else if (controller.profilePicUrl.value.isNotEmpty) {
                    bgImage = NetworkImage(controller.profilePicUrl.value);
                 }
                 
                 return CircleAvatar(
                    radius: 60,
                    backgroundColor: AppColors.secondaryGreyBlue.withOpacity(0.1),
                    backgroundImage: bgImage,
                    child: bgImage == null
                        ? const Icon(Icons.person, size: 60, color: AppColors.secondaryGreyBlue)
                        : null,
                 );
            }),
            // Circular camera icon for editing
            GestureDetector(
              onTap: controller.changeProfilePhoto,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.primaryAccent,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: AppColors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: controller.changeProfilePhoto,
          child: Text(
            'Change Profile Photo',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primaryAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primaryDark),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.secondaryGreyBlue),
        hintText: hintText,
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.secondaryGreyBlue.withOpacity(0.6),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.secondaryGreyBlue.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryAccent),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'This field is required';
        }
        return null;
      },
    );
  }

  Widget _buildPhoneField() {
    return TextFormField(
      controller: controller.phoneController,
      keyboardType: TextInputType.phone,
      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primaryDark),
      decoration: InputDecoration(
        labelText: 'Phone Number',
        labelStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.secondaryGreyBlue),
        hintText: '98765 43210',
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.secondaryGreyBlue.withOpacity(0.6),
        ),
        // Prefix for country code
        prefixText: '+91 ',
        prefixStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.secondaryGreyBlue),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.secondaryGreyBlue.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryAccent),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'This field is required';
        }
        return null;
      },
    );
  }
}