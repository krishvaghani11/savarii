import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:savarii/core/theme/app_colors.dart';
import 'package:savarii/core/theme/app_text_styles.dart';
import 'package:savarii/features/customer/home/controller/customer_select_points_controller.dart';

class CustomerSelectPointsView extends GetView<CustomerSelectPointsController> {
  const CustomerSelectPointsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Select Points',
          style: AppTextStyles.h1.copyWith(
            color: AppColors.primaryAccent,
            fontSize: 24,
          ),
        ),
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
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                child: Stack(
                  children: [
                    // The dotted line connecting the two icons
                    Positioned(
                      left: 27, // Aligned precisely under the prefix icons
                      top: 75,
                      bottom: 75,
                      child: _buildDottedLine(),
                    ),
                    
                    // The main content column
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- BOARDING POINT SECTION ---
                        Text(
                          'Select Boarding Point',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.secondaryGreyBlue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildDropdown(
                          icon: _buildBoardingIcon(),
                          items: controller.boardingPoints,
                          selectedValue: controller.selectedBoardingPoint,
                          onChanged: (val) => controller.selectedBoardingPoint.value = val!,
                        ),
                        
                        const SizedBox(height: 40), // Space for the dotted line

                        // --- DROPPING POINT SECTION ---
                        Text(
                          'Select Dropping Point',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.secondaryGreyBlue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildDropdown(
                          icon: _buildDroppingIcon(),
                          items: controller.droppingPoints,
                          selectedValue: controller.selectedDroppingPoint,
                          onChanged: (val) => controller.selectedDroppingPoint.value = val!,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // --- BOTTOM CONFIRM BUTTON ---
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondaryGreyBlue.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: controller.confirmPoints,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryAccent,
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                  shadowColor: AppColors.primaryAccent.withOpacity(0.3),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Confirm Points',
                      style: AppTextStyles.buttonText.copyWith(fontSize: 16),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.chevron_right, color: AppColors.white, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Sub-Widgets ---

  Widget _buildDropdown({
    required Widget icon,
    required RxList<String> items,
    required RxString selectedValue,
    required void Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.secondaryGreyBlue.withOpacity(0.05), // Light grey fill
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          icon,
          const SizedBox(width: 12),
          Expanded(
            child: Obx(
              () {
                // Safely default if the item list changes underneath
                String currentVal = selectedValue.value;
                if (!items.contains(currentVal) && items.isNotEmpty) {
                  currentVal = items.first;
                }

                return DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: currentVal,
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
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: value == 'Choose location'
                                ? AppColors.primaryDark.withOpacity(0.7)
                                : AppColors.primaryDark,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: onChanged,
                  ),
                );
              }
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoardingIcon() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.primaryAccent.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primaryAccent, width: 2.5),
        ),
      ),
    );
  }

  Widget _buildDroppingIcon() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.secondaryGreyBlue.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.location_on,
        color: AppColors.primaryDark,
        size: 14,
      ),
    );
  }

  Widget _buildDottedLine() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxHeight = constraints.maxHeight;
        // Each dot is 4 height + 5 margin (2.5 top/bottom) = 9
        int dotCount = maxHeight > 0 ? (maxHeight / 9.0).floor() : 0;
        
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            dotCount,
            (index) => Container(
              width: 2,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 2.5),
              decoration: BoxDecoration(
                color: AppColors.primaryAccent.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        );
      },
    );
  }
}