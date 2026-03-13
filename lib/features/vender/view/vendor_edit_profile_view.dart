import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
        title: Text('Edit Profile', style: AppTextStyles.h3),
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
                      _buildLabel('Full Name'),
                      _buildTextField(
                        controller.fullNameController,
                        hint: 'Enter your name',
                      ),
                      const SizedBox(height: 20),

                      _buildLabel('Mobile Number'),
                      _buildTextField(
                        controller.mobileController,
                        hint: 'Enter mobile number',
                        isPhone: true,
                      ),
                      const SizedBox(height: 20),

                      _buildLabel('Email Address'),
                      _buildTextField(
                        controller.emailController,
                        hint: 'Enter email address',
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 20),

                      _buildLabel('Travels Name'),
                      _buildTextField(
                        controller.travelsNameController,
                        hint: 'Enter travels name',
                      ),
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
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondaryGreyBlue.withOpacity(0.1),
                image: const DecorationImage(
                  image: AssetImage('assets/images/vendor_profile.png'),
                  // Replace with actual asset if available
                  fit: BoxFit.cover,
                ),
              ),
              child: const Icon(
                Icons.person,
                size: 50,
                color: Colors.transparent,
              ), // Fallback
            ),
            // Red Camera Icon
            Positioned(
              bottom: 0,
              right: 0,
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
              'Change Photo',
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
        validator: (value) => value!.isEmpty ? 'This field is required' : null,
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
      child: ElevatedButton(
        onPressed: controller.saveChanges,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryAccent,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Text(
          'Save Changes',
          style: AppTextStyles.buttonText.copyWith(fontSize: 16),
        ),
      ),
    );
  }
}
