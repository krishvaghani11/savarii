import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:savarii/core/theme/app_colors.dart';
import 'package:savarii/core/theme/app_text_styles.dart';

import '../controllers/vendor_add_travels_controller.dart';

class VendorAddTravelsView extends GetView<VendorAddTravelsController> {
  const VendorAddTravelsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground, // Light greyish background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Text('travels.add_title'.tr(), style: AppTextStyles.h3),
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
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. BUSINESS INFORMATION
                      _buildSectionCard(
                        icon: Icons.domain,
                        title: 'travels.business_info'.tr(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('travels.agency_name'.tr()),
                            _buildTextField('travels.agency_name_hint'.tr(), controller.travelsNameController),
                            const SizedBox(height: 16),
                            
                            _buildLabel('travels.gst'.tr()),
                            _buildTextField('22AAAAA0000A1Z5', controller.gstController),
                            const SizedBox(height: 16),
                            
                            _buildLabel('travels.business_type'.tr()),
                            _buildDropdown(
                              items: controller.businessTypes,
                              selectedValue: controller.selectedBusinessType,
                              onChanged: (val) => controller.selectedBusinessType.value = val!,
                            ),
                            const SizedBox(height: 16),
                            
                            _buildLabel('travels.established_date'.tr()),
                            _buildDatePickerField(context),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 2. PRIMARY CONTACT
                      _buildSectionCard(
                        icon: Icons.contact_mail,
                        title: 'travels.primary_contact'.tr(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('travels.contact_person'.tr()),
                            _buildTextField('travels.contact_person_hint'.tr(), controller.contactPersonController),
                            const SizedBox(height: 16),
                            
                            _buildLabel('travels.primary_mobile'.tr()),
                            _buildMobileField(),
                            const SizedBox(height: 16),
                            
                            _buildLabel('travels.support_email'.tr()),
                            _buildTextField(
                              'support@travels.com', 
                              controller.emailController, 
                              keyboardType: TextInputType.emailAddress
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 3. PRIMARY ROUTES (Dynamic List)
                      _buildSectionCard(
                        icon: Icons.route_outlined,
                        title: 'travels.primary_routes'.tr(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('travels.add_route'.tr()),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    'From - To (e.g., Delhi - Jaipur)', 
                                    controller.routeInputController
                                  ),
                                ),
                                const SizedBox(width: 12),
                                GestureDetector(
                                  onTap: controller.addRoute,
                                  child: Container(
                                    height: 52,
                                    width: 52,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryAccent.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.add, color: AppColors.primaryAccent),
                                  ),
                                )
                              ],
                            ),
                            
                            // Added Routes List
                            Obx(() => Column(
                                  children: List.generate(
                                    controller.savedRoutes.length,
                                    (index) => _buildSavedRoute(index),
                                  ),
                                )),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 4. OFFICE ADDRESS
                      _buildSectionCard(
                        icon: Icons.location_on,
                        title: 'travels.office_address'.tr(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('travels.address_line'.tr()),
                            _buildTextField(
                              'Plot No, Building, Street name...', 
                              controller.addressController, 
                              maxLines: 3
                            ),
                            const SizedBox(height: 16),
                            
                            _buildLabel('travels.city'.tr()),
                            _buildTextField('travels.city_hint'.tr(), controller.cityController),
                            const SizedBox(height: 16),
                            
                            _buildLabel('travels.state'.tr()),
                            _buildDropdown(
                              items: controller.states,
                              selectedValue: controller.selectedState,
                              onChanged: (val) => controller.selectedState.value = val!,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 5. TRAVELS IMAGES
                      _buildSectionCard(
                        icon: Icons.image,
                        title: 'travels.images_title'.tr(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                // "Add Image" Box
                                Expanded(
                                  child: GestureDetector(
                                    onTap: controller.pickImage,
                                    child: Container(
                                      height: 100,
                                      decoration: BoxDecoration(
                                        color: AppColors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        // A custom dashed border effect or subtle solid border
                                        border: Border.all(
                                          color: AppColors.secondaryGreyBlue.withOpacity(0.3),
                                          width: 1.5,
                                          style: BorderStyle.solid, 
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.add_photo_alternate, color: AppColors.secondaryGreyBlue.withOpacity(0.8), size: 28),
                                          const SizedBox(height: 8),
                                          Text(
                                            'travels.add_image'.tr(), 
                                            style: AppTextStyles.caption.copyWith(color: AppColors.secondaryGreyBlue.withOpacity(0.8))
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // "Placeholder/Added Image" Box
                                Expanded(
                                  child: Obx(() {
                                    final file = controller.selectedImage.value;
                                    final existingUrl = controller.existingImageUrl.value;
                                    
                                    ImageProvider? imageProvider;
                                    if (file != null) {
                                      imageProvider = FileImage(file);
                                    } else if (existingUrl.isNotEmpty) {
                                      imageProvider = NetworkImage(existingUrl);
                                    }
                                    
                                    return Container(
                                      height: 100,
                                      decoration: BoxDecoration(
                                        color: AppColors.secondaryGreyBlue.withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(16),
                                        image: imageProvider != null
                                            ? DecorationImage(
                                                image: imageProvider,
                                                fit: BoxFit.cover,
                                              )
                                            : null,
                                      ),
                                      child: imageProvider == null
                                          ? const Center(
                                              child: Icon(Icons.image, color: AppColors.secondaryGreyBlue, size: 28),
                                            )
                                          : null,
                                    );
                                  }),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'travels.upload_hint'.tr(),
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.secondaryGreyBlue,
                                fontSize: 11,
                                height: 1.4,
                              ),
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

            // Sticky Bottom Button
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
              const SizedBox(width: 10),
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
        keyboardType: keyboardType,
        style: AppTextStyles.bodyMedium,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.secondaryGreyBlue.withOpacity(0.6),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: maxLines > 1 ? 16 : 15,
          ),
        ),
      ),
    );
  }

  Widget _buildMobileField() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.secondaryGreyBlue.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          // Grey +91 block
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            decoration: BoxDecoration(
              color: AppColors.secondaryGreyBlue.withOpacity(0.08),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12), 
                bottomLeft: Radius.circular(12)
              ),
            ),
            child: Text(
              '+91',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.secondaryGreyBlue),
            ),
          ),
          // Input field
          Expanded(
            child: TextFormField(
              controller: controller.mobileController,
              keyboardType: TextInputType.phone,
              style: AppTextStyles.bodyMedium,
              decoration: InputDecoration(
                hintText: '9876543210',
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.secondaryGreyBlue.withOpacity(0.6),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePickerField(BuildContext context) {
    return GestureDetector(
      onTap: () => controller.pickDate(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F8FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.secondaryGreyBlue.withOpacity(0.1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Obx(() => Text(
                  controller.establishedDate.value.isEmpty 
                      ? 'mm/dd/yyyy' 
                      : controller.establishedDate.value,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: controller.establishedDate.value.isEmpty
                        ? AppColors.secondaryGreyBlue.withOpacity(0.6)
                        : AppColors.primaryDark,
                  ),
                )),
            const Icon(Icons.calendar_today_outlined, color: AppColors.secondaryGreyBlue, size: 18),
          ],
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
            icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.secondaryGreyBlue),
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

  Widget _buildSavedRoute(int index) {
    final route = controller.savedRoutes[index];
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.secondaryGreyBlue.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              route,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primaryDark),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GestureDetector(
            onTap: () => controller.removeRoute(index),
            child: const Icon(Icons.close, color: AppColors.secondaryGreyBlue, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildStickyRegisterButton() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.lightBackground,
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryGreyBlue.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Obx(() => ElevatedButton(
        onPressed: controller.isLoading.value ? null : controller.registerTravels,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryAccent,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: controller.isLoading.value 
          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('travels.register_travels'.tr(), style: AppTextStyles.buttonText.copyWith(fontSize: 16)),
                const SizedBox(width: 8),
                const Icon(Icons.person_add_alt_1, color: AppColors.white, size: 20), // Matches mockup icon
              ],
            ),
      )),
    );
  }
}   