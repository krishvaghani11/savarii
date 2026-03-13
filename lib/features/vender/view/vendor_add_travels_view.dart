import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:savarii/core/theme/app_colors.dart';
import 'package:savarii/core/theme/app_text_styles.dart';
import '../controllers/vendor_add_travels_controller.dart';

class VendorAddTravelsView extends GetView<VendorAddTravelsController> {
  const VendorAddTravelsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Text('Add a Travels', style: AppTextStyles.h3),
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
                  horizontal: 20.0,
                  vertical: 16.0,
                ),
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. BUSINESS INFORMATION
                      _buildSectionCard(
                        icon: Icons.domain,
                        title: 'Business Information',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Travels Name'),
                            _buildTextField(
                              'Enter agency name',
                              controller.travelsNameController,
                            ),
                            const SizedBox(height: 16),
                            _buildLabel('Business Reg. No.'),
                            _buildTextField(
                              'BRN123456',
                              controller.regNoController,
                            ),
                            const SizedBox(height: 16),
                            _buildLabel('GST Number'),
                            _buildTextField(
                              '22AAAAA0000A1Z5',
                              controller.gstController,
                            ),
                            const SizedBox(height: 16),
                            _buildLabel('Business Type'),
                            _buildDropdown(
                              items: controller.businessTypes,
                              selectedValue: controller.selectedBusinessType,
                              onChanged: (val) =>
                                  controller.selectedBusinessType.value = val!,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 2. PRIMARY CONTACT
                      _buildSectionCard(
                        icon: Icons.contact_mail,
                        title: 'Primary Contact',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Primary Contact Person'),
                            _buildTextField(
                              'Full name of contact person',
                              controller.contactPersonController,
                            ),
                            const SizedBox(height: 16),
                            _buildLabel('Primary Mobile Number'),
                            _buildTextField(
                              '9876543210',
                              controller.mobileController,
                              isPhone: true,
                            ),
                            const SizedBox(height: 16),
                            _buildLabel('Support Email'),
                            _buildTextField(
                              'support@travels.com',
                              controller.emailController,
                              keyboardType: TextInputType.emailAddress,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 3. OFFICE ADDRESS
                      _buildSectionCard(
                        icon: Icons.location_on,
                        title: 'Office Address',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Address Line'),
                            _buildTextField(
                              'Plot No, Building, Street name...',
                              controller.addressController,
                              maxLines: 3,
                            ),
                            const SizedBox(height: 16),
                            _buildLabel('City'),
                            _buildTextField(
                              'Enter city',
                              controller.cityController,
                            ),
                            const SizedBox(height: 16),
                            _buildLabel('State'),
                            _buildDropdown(
                              items: controller.states,
                              selectedValue: controller.selectedState,
                              onChanged: (val) =>
                                  controller.selectedState.value = val!,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),

            // 4. Sticky Bottom Button
            _buildStickyRegisterButton(),
          ],
        ),
      ),
    );
  }

  // --- Sub-Widgets ---

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
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
              Icon(icon, color: AppColors.primaryAccent, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.primaryDark,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTextField(
    String hint,
    TextEditingController textController, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    bool isPhone = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA), // Light grey input background
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.secondaryGreyBlue.withOpacity(0.1)),
      ),
      child: TextFormField(
        controller: textController,
        maxLines: maxLines,
        keyboardType: isPhone ? TextInputType.phone : keyboardType,
        validator: (value) => value!.isEmpty ? 'Required' : null,
        style: AppTextStyles.bodyMedium,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.secondaryGreyBlue.withOpacity(0.6),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: maxLines > 1 ? 16 : 14,
          ),
          prefixIcon: isPhone
              ? Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 12.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '+91',
                        style: AppTextStyles.bodyMedium.copyWith(
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

  Widget _buildDropdown({
    required List<String> items,
    required RxString selectedValue,
    required void Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.secondaryGreyBlue.withOpacity(0.1)),
      ),
      child: Obx(
        () => DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selectedValue.value,
            isExpanded: true,
            icon: const Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.secondaryGreyBlue,
            ),
            items: items.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: value.startsWith('Select')
                        ? AppColors.secondaryGreyBlue.withOpacity(0.6)
                        : AppColors.primaryDark,
                  ),
                ),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }

  Widget _buildStickyRegisterButton() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: AppColors.lightBackground),
      child: ElevatedButton(
        onPressed: controller.registerTravels,
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
              'Register Travels',
              style: AppTextStyles.buttonText.copyWith(fontSize: 16),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.how_to_reg, color: AppColors.white, size: 20),
          ],
        ),
      ),
    );
  }
}
