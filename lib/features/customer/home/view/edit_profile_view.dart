import 'package:flutter/material.dart';
import 'package:get/get.dart';

// import the asset path
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../controller/edit_profile_controller.dart';

class EditProfileView extends GetView<EditProfileController> {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text('Edit Profile', style: AppTextStyles.h3),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryDark),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: AppColors.primaryAccent),
            onPressed: controller
                .saveProfile, // Save icon triggers form validation and save
          ),
        ],
      ),
      body: SafeArea(
        child: Obx(() => Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Profile Picture Section
                  _buildHeader(context),
                  const SizedBox(height: 32),

                  // 2. Form Fields
                  _buildFormFields(),
                  const SizedBox(height: 32),

                  // 3. Bottom Action Buttons
                  _buildActionButtons(),

                  const SizedBox(height: 30), // Bottom buffer
                ],
              ),
            ),
            if (controller.isLoading.value) ...[
              Container(color: Colors.black.withOpacity(0.3)),
              const Center(child: CircularProgressIndicator(color: AppColors.primaryAccent))
            ]
          ],
        )),
      ),
    );
  }

  // --- Sub-Widgets for cleaner code ---

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            // Profile Picture Circle
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondaryGreyBlue.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Obx(() => CircleAvatar(
                radius: 60,
                backgroundColor: AppColors.secondaryGreyBlue.withOpacity(0.1),
                backgroundImage: controller.profileImageUrl.value.isNotEmpty
                    ? NetworkImage(controller.profileImageUrl.value)
                    : null,
                child: controller.profileImageUrl.value.isEmpty
                    ? const Icon(
                        Icons.person,
                        size: 60,
                        color: AppColors.primaryDark,
                      )
                    : null,
              )),
            ),

            // Edit Camera Icon Overlay
            GestureDetector(
              onTap: () => controller.changeProfilePicture(context),
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
      ],
    );
  }

  Widget _buildFormFields() {
    return Form(
      key: controller.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        // Align the Gender label to the left
        children: [
          _buildTextField(
            controller: controller.nameController,
            hint: 'Full Name',
            icon: Icons.person_outline,
            validator: (value) =>
                value!.isEmpty ? 'Please enter your name.' : null,
          ),
          const SizedBox(height: 16),

          _buildTextField(
            controller: controller.emailController,
            hint: 'Email Address',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (value) =>
                value!.isEmpty ? 'Please enter your email.' : null,
          ),
          const SizedBox(height: 16),

          _buildTextField(
            controller: controller.phoneController,
            hint: 'Phone Number',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            validator: (value) =>
                value!.isEmpty ? 'Please enter your phone number.' : null,
          ),
          const SizedBox(height: 16),

          _buildTextField(
            controller: controller.dobController,
            hint: 'Date of Birth',
            icon: Icons.calendar_today_outlined,
            validator: (value) =>
                value!.isEmpty ? 'Please enter your date of birth.' : null,
          ),

          // --- NEW: Gender Section ---
          const SizedBox(height: 24),
          Text('Gender', style: AppTextStyles.h3.copyWith(fontSize: 16)),
          const SizedBox(height: 12),
          _buildGenderSelection(),
          // ---------------------------
        ],
      ),
    );
  }

  // --- NEW: Gender Selection Widgets ---
  Widget _buildGenderSelection() {
    return Row(
      children: [
        _buildGenderOption('Male'),
        const SizedBox(width: 12),
        _buildGenderOption('Female'),
        const SizedBox(width: 12),
        _buildGenderOption('Other'),
      ],
    );
  }

  Widget _buildGenderOption(String gender) {
    return Obx(() {
      final isSelected = controller.selectedGender.value == gender;

      return Expanded(
        child: GestureDetector(
          onTap: () => controller.selectGender(gender),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryAccent : AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? AppColors.primaryAccent
                    : AppColors.secondaryGreyBlue.withOpacity(0.2),
              ),
              boxShadow: [
                if (!isSelected)
                  BoxShadow(
                    color: AppColors.secondaryGreyBlue.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                if (isSelected)
                  BoxShadow(
                    color: AppColors.primaryAccent.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
            child: Center(
              child: Text(
                gender,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isSelected
                      ? AppColors.white
                      : AppColors.secondaryGreyBlue,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  // -------------------------------------

  // Helper method to create a single styled text field
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Container(
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
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: AppTextStyles.bodyLarge,
        validator: validator,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.secondaryGreyBlue.withOpacity(0.6),
          ),
          prefixIcon: Icon(icon, color: AppColors.secondaryGreyBlue, size: 22),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Change Password Button
        ElevatedButton.icon(
          onPressed: controller.changePassword,
          icon: const Icon(
            Icons.lock_reset,
            color: AppColors.primaryAccent,
            size: 20,
          ),
          label: Text(
            'Change Password',
            style: AppTextStyles.buttonText.copyWith(
              color: AppColors.primaryAccent,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.white,
            foregroundColor: AppColors.primaryAccent,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 16),
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(
                color: AppColors.primaryAccent,
                width: 1,
              ), // Red outline
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Delete Account Button
        ElevatedButton.icon(
          onPressed: controller.deleteAccount,
          icon: const Icon(
            Icons.delete_forever,
            color: AppColors.white,
            size: 20,
          ),
          label: Text('Delete Account', style: AppTextStyles.buttonText),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryAccent, // Solid red
            padding: const EdgeInsets.symmetric(vertical: 16),
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ],
    );
  }
}
