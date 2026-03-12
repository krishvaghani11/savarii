import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:savarii/core/theme/app_colors.dart';
import 'package:savarii/core/theme/app_text_styles.dart';

import '../controllers/vendor_registration_controller.dart';

class VendorRegistrationView extends GetView<VendorRegistrationController> {
  const VendorRegistrationView({super.key});

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text('Vendor Registration', style: AppTextStyles.h3),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryDark),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        // The SingleChildScrollView now wraps EVERYTHING, including the footer
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 1. The Form Content (with padding)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 16.0,
                ),
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Create Vendor Account',
                        style: AppTextStyles.h2.copyWith(fontSize: 22),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please fill in the details below to register your travel agency with Savarii.',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.secondaryGreyBlue,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 32),

                      _buildTextField(
                        label: 'Travels Name',
                        hint: 'Enter agency name',
                        icon: Icons.directions_bus_outlined,
                        controller: controller.travelsNameController,
                      ),
                      const SizedBox(height: 16),

                      _buildTextField(
                        label: 'Full Name',
                        hint: 'Enter owner name',
                        icon: Icons.person_outline,
                        controller: controller.fullNameController,
                      ),
                      const SizedBox(height: 16),

                      Text(
                        'Mobile Number',
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildMobileField(),
                      const SizedBox(height: 16),

                      _buildTextField(
                        label: 'Email Address',
                        hint: 'name@agency.com',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        controller: controller.emailController,
                      ),
                      const SizedBox(height: 16),

                      _buildTextField(
                        label: 'Current Office Address',
                        hint: 'Enter current office location',
                        icon: Icons.location_on_outlined,
                        controller: controller.currentAddressController,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),

                      _buildTextField(
                        label: 'Permanent Address',
                        hint: 'As per legal documents',
                        icon: Icons.home_outlined,
                        controller: controller.permanentAddressController,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 32),

                      ElevatedButton(
                        onPressed: controller.completeRegistration,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryAccent,
                          minimumSize: const Size(double.infinity, 54),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Complete Registration',
                              style: AppTextStyles.buttonText.copyWith(
                                fontSize: 16,
                              ),
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
                      const SizedBox(height: 16),

                      Text(
                        "By registering, you agree to Savarii's Terms of Service and\nPrivacy Policy.",
                        textAlign: TextAlign.center,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.secondaryGreyBlue,
                        ),
                      ),
                      const SizedBox(height: 24), // Buffer before the footer
                    ],
                  ),
                ),
              ),

              // 2. Trust Badges Footer (Now scrolls with the rest of the page!)
              _buildTrustBadgesFooter(),
            ],
          ),
        ),
      ),
    );
  }

  // --- Sub-Widgets ---

  Widget _buildTextField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.secondaryGreyBlue.withOpacity(0.2),
            ),
          ),
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            style: AppTextStyles.bodyLarge,
            validator: (value) =>
                value!.isEmpty ? 'This field is required' : null,
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
              prefixIcon: Padding(
                padding: EdgeInsets.only(bottom: maxLines > 1 ? 40.0 : 0),
                // Aligns icon to top for multiline
                child: Icon(icon, color: AppColors.secondaryGreyBlue, size: 20),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secondaryGreyBlue.withOpacity(0.2)),
      ),
      child: TextFormField(
        controller: controller.mobileController,
        keyboardType: TextInputType.phone,
        style: AppTextStyles.bodyLarge,
        validator: (value) =>
            value!.isEmpty ? 'Mobile number is required' : null,
        decoration: InputDecoration(
          hintText: 'Enter mobile number',
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.secondaryGreyBlue.withOpacity(0.6),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          prefixIcon: Container(
            width: 90, // Fixed width for the prefix section
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🇮🇳', style: TextStyle(fontSize: 18)),
                // Indian Flag Emoji
                const SizedBox(width: 4),
                Text(
                  '+91',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 1,
                  height: 20,
                  color: AppColors.secondaryGreyBlue.withOpacity(0.3),
                ),
                // Divider
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTrustBadgesFooter() {
    return Container(
      width: double.infinity,
      // Ensures full width
      padding: const EdgeInsets.symmetric(vertical: 24),
      // Adjusted padding for better look
      decoration: BoxDecoration(
        color: AppColors.lightBackground,
        // Keep this slightly different background color
        border: Border(
          top: BorderSide(color: AppColors.secondaryGreyBlue.withOpacity(0.1)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildBadge(Icons.verified_user, 'SECURE'),
          _buildBadge(Icons.support_agent, '24/7 SUPPORT'),
          _buildBadge(Icons.speed, 'FAST APPROVAL'),
        ],
      ),
    );
  }

  Widget _buildBadge(IconData icon, String text) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.primaryAccent, size: 20),
        const SizedBox(height: 6),
        Text(
          text,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.primaryDark,
            fontSize: 9,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
