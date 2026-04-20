import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:savarii/core/theme/app_colors.dart';
import 'package:savarii/core/theme/app_text_styles.dart';
import '../controllers/edit_driver_controller.dart';

class EditDriverView extends GetView<EditDriverController> {
  const EditDriverView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Edit Driver Profile', style: AppTextStyles.h3),
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
                Text(
                  'Update driver details',
                  style: AppTextStyles.h1.copyWith(fontSize: 24, color: const Color(0xFF1E202C)),
                ),
                const SizedBox(height: 24),

                // 1. Personal Details
                _buildSectionCard(
                  title: 'Personal Details',
                  icon: Icons.contact_mail,
                  iconColor: AppColors.primaryAccent,
                  iconBgColor: AppColors.primaryAccent.withOpacity(0.1),
                  child: Column(
                    children: [
                      _buildInputField(
                        label: 'Full Name',
                        hint: 'Full Name',
                        controller: controller.nameController,
                        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      _buildInputField(
                        label: 'Email Address',
                        hint: 'Email',
                        controller: controller.emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      _buildInputField(
                        label: 'Mobile Number',
                        hint: 'Mobile',
                        controller: controller.mobileController,
                        keyboardType: TextInputType.phone,
                        validator: (value) => value == null || value.length < 10 ? 'Invalid phone' : null,
                      ),
                      const SizedBox(height: 16),
                      _buildInputField(label: 'Alternate Number', hint: 'Optional', controller: controller.altMobileController, keyboardType: TextInputType.phone),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 2. ID & License
                _buildSectionCard(
                  title: 'Identification',
                  icon: Icons.badge_outlined,
                  iconColor: const Color(0xFF2A2D3E),
                  iconBgColor: AppColors.secondaryGreyBlue.withOpacity(0.1),
                  child: Column(
                    children: [
                      _buildInputField(
                        label: 'DL Number',
                        hint: 'DL Number',
                        controller: controller.dlController,
                        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      _buildInputField(
                        label: 'Aadhar Number',
                        hint: 'Aadhar Number',
                        controller: controller.aadharController,
                        keyboardType: TextInputType.number,
                        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 20),
                      Obx(() => _buildUploadBox(
                        title: 'Update Driving License',
                        subtitle: controller.newDlFile.value != null ? 'New file selected' : 'Change current document',
                        icon: Icons.file_upload_outlined,
                        isSelected: controller.newDlFile.value != null,
                        onTap: controller.pickDlImage,
                      )),
                      const SizedBox(height: 12),
                      Obx(() => _buildUploadBox(
                        title: 'Update Aadhar Card',
                        subtitle: controller.newAadharFile.value != null ? 'New file selected' : 'Change current document',
                        icon: Icons.badge_outlined,
                        isSelected: controller.newAadharFile.value != null,
                        onTap: controller.pickAadharImage,
                      )),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 3. Driver Image
                _buildSectionCard(
                  title: 'Driver Image',
                  icon: Icons.camera_alt_outlined,
                  iconColor: const Color(0xFF2A2D3E),
                  iconBgColor: AppColors.secondaryGreyBlue.withOpacity(0.1),
                  child: Column(
                    children: [
                      Obx(() => Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          color: AppColors.secondaryGreyBlue.withOpacity(0.2),
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: controller.newProfileImage.value != null
                                ? FileImage(controller.newProfileImage.value!)
                                : (controller.existingProfileImageUrl.isNotEmpty 
                                    ? NetworkImage(controller.existingProfileImageUrl) 
                                    : const AssetImage('assets/images/user_placeholder.png')) as ImageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      )),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: controller.pickProfilePhoto,
                        icon: const Icon(Icons.photo_camera_back, size: 18),
                        label: const Text('Change Photo'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2A2D3E),
                          minimumSize: const Size(200, 48),
                        ),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: controller.takeLivePhoto,
                        icon: const Icon(Icons.camera_alt, size: 18),
                        label: const Text('Take New Photo'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(200, 48),
                          side: const BorderSide(color: Color(0xFF2A2D3E)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 4. Address
                _buildSectionCard(
                  title: 'Address Details',
                  icon: Icons.location_on_outlined,
                  iconColor: const Color(0xFF2A2D3E),
                  iconBgColor: AppColors.secondaryGreyBlue.withOpacity(0.1),
                  child: Column(
                    children: [
                      _buildInputField(
                        label: 'Street Address',
                        hint: 'Street',
                        controller: controller.streetController,
                        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _buildInputField(
                            label: 'City',
                            hint: 'City',
                            controller: controller.cityController,
                            validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                          )),
                          const SizedBox(width: 16),
                          Expanded(child: _buildInputField(
                            label: 'State',
                            hint: 'State',
                            controller: controller.stateController,
                            validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                          )),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildInputField(
                        label: 'PIN Code',
                        hint: 'PIN Code',
                        controller: controller.pinCodeController,
                        keyboardType: TextInputType.number,
                        validator: (value) => value == null || value.length < 6 ? 'Invalid' : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Update Button
                Obx(() => ElevatedButton(
                  onPressed: controller.isLoading.value ? null : controller.updateDriverProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryAccent,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: controller.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('UPDATE PROFILE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                )),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Reuse logic from AddDriverView...
  Widget _buildSectionCard({required String title, required IconData icon, required Color iconColor, required Color iconBgColor, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: iconBgColor, borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: iconColor, size: 20)),
            const SizedBox(width: 12),
            Text(title, style: AppTextStyles.h3.copyWith(fontSize: 16)),
          ]),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildInputField({required String label, required String hint, required TextEditingController controller, TextInputType keyboardType = TextInputType.text, String? Function(String?)? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.primaryDark, fontWeight: FontWeight.bold, fontSize: 11)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller, validator: validator, keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.secondaryGreyBlue.withOpacity(0.3))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryAccent)),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadBox({required String title, required String subtitle, required IconData icon, required VoidCallback onTap, bool isSelected = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(border: Border.all(color: isSelected ? Colors.green : AppColors.secondaryGreyBlue.withOpacity(0.3)), borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          Icon(icon, color: isSelected ? Colors.green : const Color(0xFF2A2D3E), size: 20),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, fontSize: 13)),
            Text(subtitle, style: AppTextStyles.caption.copyWith(fontSize: 10)),
          ])),
          Icon(isSelected ? Icons.check_circle : Icons.add_circle_outline, color: isSelected ? Colors.green : AppColors.secondaryGreyBlue),
        ]),
      ),
    );
  }
}
