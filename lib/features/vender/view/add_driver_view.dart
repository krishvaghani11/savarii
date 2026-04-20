import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:savarii/core/theme/app_colors.dart';
import 'package:savarii/core/theme/app_text_styles.dart';

import '../controllers/add_driver_controller.dart';

class AddDriverView extends GetView<AddDriverController> {
  const AddDriverView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFF4F6F9,
      ), // Light greyish-blue background from mockup
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Text('Add New Driver', style: AppTextStyles.h3),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryDark),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Texts
                Text(
                  'Add driver details here',
                  style: AppTextStyles.h1.copyWith(
                    fontSize: 24,
                    color: const Color(0xFF1E202C),
                  ), // Dark Navy
                ),
                const SizedBox(height: 8),
                Text(
                  'Fill in the professional profile of your fleet operative.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.secondaryGreyBlue,
                  ),
                ),
                const SizedBox(height: 24),

                // 1. Personal Details Card
                _buildSectionCard(
                  title: 'Personal Details',
                  icon: Icons.contact_mail,
                  iconColor: AppColors.primaryAccent,
                  iconBgColor: AppColors.primaryAccent.withOpacity(0.1),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInputField(
                        label: 'Full Name',
                        hint: 'John Doe',
                        controller: controller.nameController,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please enter name'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      _buildInputField(
                        label: 'Email Address',
                        hint: 'john.doe@logistics.com',
                        controller: controller.emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) =>
                            value != null &&
                                value.isNotEmpty &&
                                !GetUtils.isEmail(value)
                            ? 'Enter valid email'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      _buildInputField(
                        label: 'Mobile Number',
                        hint: '+91 98765 43210',
                        controller: controller.mobileController,
                        keyboardType: TextInputType.phone,
                        validator: (value) => value == null || value.length < 10
                            ? 'Enter valid phone number'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      _buildInputField(
                        label: 'Alternate Number',
                        hint: 'Optional',
                        controller: controller.altMobileController,
                        keyboardType: TextInputType.phone,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 2. Identification & License Card
                _buildSectionCard(
                  title: 'Identification & License',
                  icon: Icons.badge_outlined,
                  iconColor: const Color(0xFF2A2D3E), // Dark Navy
                  iconBgColor: AppColors.secondaryGreyBlue.withOpacity(0.1),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInputField(
                        label: 'DL Number',
                        hint: 'DL-XXXXXXXXXXXXX',
                        controller: controller.dlController,
                      ),
                      const SizedBox(height: 16),
                      _buildInputField(
                        label: 'Aadhar Number',
                        hint: 'XXXX-XXXX-XXXX',
                        controller: controller.aadharController,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 20),

                      Obx(
                        () => _buildUploadBox(
                          title: 'Upload Driving License',
                          subtitle: controller.dlFile.value != null
                              ? 'Selected: ${controller.dlFile.value!.path.split('/').last}'
                              : 'PDF or JPG up to 5MB',
                          icon: Icons.file_upload_outlined,
                          isSelected: controller.dlFile.value != null,
                          onTap: controller.uploadDrivingLicense,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Obx(
                        () => _buildUploadBox(
                          title: 'Upload Aadhar Card',
                          subtitle: controller.aadharFile.value != null
                              ? 'Selected: ${controller.aadharFile.value!.path.split('/').last}'
                              : 'Front and back preferred',
                          icon: Icons.badge_outlined,
                          isSelected: controller.aadharFile.value != null,
                          onTap: controller.uploadAadharCard,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 3. Address Details Card
                _buildSectionCard(
                  title: 'Address Details',
                  icon: Icons.location_on_outlined,
                  iconColor: const Color(0xFF2A2D3E),
                  iconBgColor: AppColors.secondaryGreyBlue.withOpacity(0.1),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInputField(
                        label: 'Street Address',
                        hint: 'Building, Street, Area',
                        controller: controller.streetController,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildInputField(
                              label: 'City',
                              hint: 'City',
                              controller: controller.cityController,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildInputField(
                              label: 'State',
                              hint: 'State',
                              controller: controller.stateController,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildInputField(
                        label: 'PIN Code',
                        hint: '123456',
                        controller: controller.pinCodeController,
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 4. Driver Image Card
                _buildSectionCard(
                  title: 'Driver Image',
                  icon: Icons.camera_alt_outlined,
                  iconColor: const Color(0xFF2A2D3E),
                  iconBgColor: AppColors.secondaryGreyBlue.withOpacity(0.1),
                  child: SizedBox(
                    width: double
                        .infinity, // This forces the column to span full width
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment
                          .center, // This perfectly centers the items
                      children: [
                        Obx(
                          () => Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                              color: AppColors.secondaryGreyBlue.withOpacity(
                                0.2,
                              ),
                              shape: BoxShape.circle,
                              image: controller.profileImage.value != null
                                  ? DecorationImage(
                                      image: FileImage(
                                        controller.profileImage.value!,
                                      ),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: controller.profileImage.value == null
                                ? const Icon(
                                    Icons.person,
                                    size: 60,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Upload Driver Photo',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Clear passport-sized photo for fleet ID and security\nverification. Max size 2MB.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.secondaryGreyBlue,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Photo Action Buttons
                        ElevatedButton.icon(
                          onPressed: controller.selectPhoto,
                          icon: const Icon(
                            Icons.photo_camera_back,
                            color: AppColors.white,
                            size: 18,
                          ),
                          label: Text(
                            'Select Photo',
                            style: AppTextStyles.buttonText.copyWith(
                              fontSize: 14,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(
                              0xFF2A2D3E,
                            ), // Dark Navy
                            minimumSize: const Size(200, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: controller.takeLivePhoto,
                          icon: const Icon(
                            Icons.camera_alt,
                            color: Color(0xFF2A2D3E),
                            size: 18,
                          ),
                          label: Text(
                            'Take Live Photo',
                            style: AppTextStyles.buttonText.copyWith(
                              color: const Color(0xFF2A2D3E),
                              fontSize: 14,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(200, 48),
                            side: const BorderSide(color: Color(0xFF2A2D3E)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // 5. Save Button
                Obx(
                  () => ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.saveDriverProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryAccent,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: controller.isLoading.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'SAVE DRIVER PROFILE',
                                style: AppTextStyles.buttonText.copyWith(
                                  fontSize: 14,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.arrow_forward,
                                color: AppColors.white,
                                size: 18,
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 40), // Buffer for scrolling
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Sub-Widgets ---

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Text(title, style: AppTextStyles.h3.copyWith(fontSize: 16)),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.primaryDark,
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.primaryDark,
          ),
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.secondaryGreyBlue.withOpacity(0.6),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.secondaryGreyBlue.withOpacity(0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primaryAccent),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadBox({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: DashedBorderPainter(
          color: isSelected
              ? Colors.green
              : AppColors.secondaryGreyBlue.withOpacity(0.5),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.green : const Color(0xFF2A2D3E),
                size: 20,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.secondaryGreyBlue,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.green.withOpacity(0.2)
                      : AppColors.secondaryGreyBlue.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isSelected ? Icons.check : Icons.add,
                  color: isSelected ? Colors.green : AppColors.white,
                  size: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom Painter for dashed borders
class DashedBorderPainter extends CustomPainter {
  final Color color;
  DashedBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    double dashWidth = 6, dashSpace = 4;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Draw a simplified rounded dashed rect
    RRect rRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(12),
    );
    Path path = Path()..addRRect(rRect);

    Path dashPath = Path();
    for (PathMetric measurePath in path.computeMetrics()) {
      double distance = 0;
      while (distance < measurePath.length) {
        dashPath.addPath(
          measurePath.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
