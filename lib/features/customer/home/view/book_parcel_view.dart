import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:savarii/core/constants/app_assets.dart';
import 'package:savarii/core/theme/app_colors.dart';
import 'package:savarii/core/theme/app_text_styles.dart';
import 'package:savarii/features/customer/home/controller/book_parcel_controller.dart';

class BookParcelView extends GetView<BookParcelController> {
  const BookParcelView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text('Book a Parcel', style: AppTextStyles.h3),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryDark),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Top Stepper
              _buildStepper(),
              const SizedBox(height: 32),

              // 2. Pickup Location
              _buildInputLabel('Pickup Location'),
              _buildInputField(
                controller: controller.pickupController,
                hint: 'Enter pickup address',
                prefixIcon: Icons.location_on,
                prefixColor: AppColors.primaryAccent,
                suffixIcon: Icons.my_location,
                onSuffixTap: controller.useCurrentLocation,
                borderColor: AppColors.primaryAccent.withOpacity(
                  0.5,
                ), // Slightly red border like mockup
              ),
              const SizedBox(height: 20),

              // 3. Drop Location
              _buildInputLabel('Drop Location'),
              _buildInputField(
                controller: controller.dropController,
                hint: 'Enter drop address',
                prefixIcon: Icons.location_on_outlined,
              ),
              const SizedBox(height: 20),

              // 4. Map Preview
              _buildMapPreview(),
              const SizedBox(height: 24),

              // 5. Parcel Type Dropdown
              _buildInputLabel('Parcel Type'),
              _buildDropdown(),
              const SizedBox(height: 20),

              // 6. Weight
              _buildInputLabel('Weight'),
              _buildInputField(
                controller: controller.weightController,
                hint: '0',
                suffixText: 'kg',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),

              // 7. Notes
              _buildInputLabel('Notes for Driver (Optional)'),
              _buildInputField(
                controller: controller.notesController,
                hint: 'Any special instructions?',
                maxLines: 3,
              ),

              const SizedBox(height: 100), // Buffer for the bottom button
            ],
          ),
        ),
      ),
      // Sticky Bottom Button
      bottomNavigationBar: _buildBottomButton(),
    );
  }

  // --- Sub-Widgets ---

  Widget _buildStepper() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStepItem(step: '1', title: 'Details', isActive: true),
        _buildStepDivider(),
        _buildStepItem(step: '2', title: 'Review', isActive: false),
        _buildStepDivider(),
        _buildStepItem(step: '3', title: 'Pay', isActive: false),
      ],
    );
  }

  Widget _buildStepItem({
    required String step,
    required String title,
    required bool isActive,
  }) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primaryAccent : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive
                  ? AppColors.primaryAccent
                  : AppColors.secondaryGreyBlue.withOpacity(0.3),
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppColors.primaryAccent.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              step,
              style: AppTextStyles.caption.copyWith(
                color: isActive
                    ? AppColors.white
                    : AppColors.secondaryGreyBlue.withOpacity(0.5),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTextStyles.bodyMedium.copyWith(
            color: isActive
                ? AppColors.primaryAccent
                : AppColors.secondaryGreyBlue.withOpacity(0.5),
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStepDivider() {
    return Container(
      width: 30,
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      color: AppColors.secondaryGreyBlue.withOpacity(0.3),
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(label, style: AppTextStyles.h3.copyWith(fontSize: 14)),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    IconData? prefixIcon,
    Color prefixColor = AppColors.secondaryGreyBlue,
    IconData? suffixIcon,
    String? suffixText,
    VoidCallback? onSuffixTap,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    Color? borderColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor ?? AppColors.secondaryGreyBlue.withOpacity(0.2),
        ),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: AppTextStyles.bodyLarge,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.secondaryGreyBlue.withOpacity(0.6),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: prefixIcon == null ? 16 : 0,
            vertical: 16,
          ),
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon, color: prefixColor, size: 22)
              : null,
          suffixIcon: suffixIcon != null
              ? IconButton(
                  icon: Icon(suffixIcon, color: AppColors.primaryDark),
                  onPressed: onSuffixTap,
                )
              : (suffixText != null
                    ? Padding(
                        padding: const EdgeInsets.only(right: 16.0, top: 16.0),
                        // Align with text
                        child: Text(
                          suffixText,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.primaryDark,
                          ),
                        ),
                      )
                    : null),
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secondaryGreyBlue.withOpacity(0.2)),
      ),
      child: Obx(
        () => DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: controller.selectedParcelType.value,
            hint: Text(
              'Select Type',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.secondaryGreyBlue.withOpacity(0.6),
              ),
            ),
            isExpanded: true,
            icon: const Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.primaryDark,
            ),
            items: controller.parcelTypes.map((String type) {
              return DropdownMenuItem<String>(
                value: type,
                child: Text(type, style: AppTextStyles.bodyLarge),
              );
            }).toList(),
            onChanged: controller.selectParcelType,
          ),
        ),
      ),
    );
  }

  Widget _buildMapPreview() {
    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.lightBackground, // Fallback color
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secondaryGreyBlue.withOpacity(0.2)),
        image: const DecorationImage(
          // Assuming you have a map image, if not it will just show the button gracefully
          image: AssetImage(AppAssets.locationMapImage),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.white54, BlendMode.lighten),
        ),
      ),
      child: Center(
        child: InkWell(
          onTap: controller.viewRouteOnMap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.secondaryGreyBlue.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              'View Route on Map',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.primaryAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(color: AppColors.lightBackground),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: controller.continueToReview,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryAccent,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            shadowColor: AppColors.primaryAccent.withOpacity(0.4),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Continue',
                style: AppTextStyles.buttonText.copyWith(fontSize: 16),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward, color: AppColors.white, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
