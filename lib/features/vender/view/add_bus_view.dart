import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:savarii/core/theme/app_colors.dart';
import 'package:savarii/core/theme/app_text_styles.dart';
import '../controllers/add_bus_controller.dart';

class AddBusView extends GetView<AddBusController> {
  const AddBusView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Text('Add Bus & Route', style: AppTextStyles.h3),
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
                      // 1. BUS DETAILS
                      _buildSectionHeader(Icons.directions_bus, 'BUS DETAILS'),
                      _buildCardContainer(
                        child: Column(
                          children: [
                            _buildInputField(
                              'Bus Name',
                              'e.g. Scania Touring',
                              controller.busNameController,
                            ),
                            const SizedBox(height: 16),
                            _buildInputField(
                              'Bus Number',
                              'e.g. MH 12 AB 1234',
                              controller.busNumberController,
                            ),
                            const SizedBox(height: 16),
                            _buildInputField(
                              'Total Seats',
                              'e.g. 45',
                              controller.totalSeatsController,
                              keyboardType: TextInputType.number,
                              suffixIcon: Icons.event_seat,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 2. BUS TYPE
                      _buildSectionHeader(Icons.category, 'BUS TYPE'),
                      _buildCardContainer(
                        child: Obx(
                          () => Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: controller.busTypes
                                .map((type) => _buildTypeChip(type))
                                .toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 3. ROUTE & SCHEDULE
                      _buildSectionHeader(Icons.alt_route, 'ROUTE & SCHEDULE'),
                      _buildCardContainer(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _buildInputField(
                                    'From',
                                    'Origin',
                                    controller.fromController,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildInputField(
                                    'To',
                                    'Destination',
                                    controller.toController,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTimePickerField(
                                    'Departure',
                                    true,
                                    context,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildTimePickerField(
                                    'Arrival',
                                    false,
                                    context,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildInputField(
                              'Ticket Price',
                              '0.00',
                              controller.priceController,
                              keyboardType: TextInputType.number,
                              prefixText: '₹ ',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 4. DRIVER DETAILS
                      _buildSectionHeader(
                        Icons.account_circle,
                        'DRIVER DETAILS',
                      ),
                      _buildCardContainer(
                        child: Column(
                          children: [
                            _buildInputField(
                              'Driver Name',
                              'e.g. John Doe',
                              controller.driverNameController,
                            ),
                            const SizedBox(height: 16),
                            _buildInputField(
                              'Driver Mobile Number',
                              'e.g. +91 9876543210',
                              controller.driverMobileController,
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: 16),
                            _buildInputField(
                              'License Number',
                              'e.g. ABC123456789',
                              controller.licenseController,
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

            // 5. Sticky Bottom Button
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.lightBackground,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondaryGreyBlue.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: controller.saveBusAndRoute,
                icon: const Icon(Icons.save, color: AppColors.white, size: 20),
                label: Text(
                  'Save Bus & Route',
                  style: AppTextStyles.buttonText,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryAccent,
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildSectionHeader(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, left: 4.0),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryAccent, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.primaryDark,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardContainer({required Widget child}) {
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
      child: child,
    );
  }

  Widget _buildInputField(
    String label,
    String hint,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    IconData? suffixIcon,
    String? prefixText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.primaryDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.secondaryGreyBlue.withOpacity(0.05),
            // Light grey input background
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            style: AppTextStyles.bodyMedium,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.secondaryGreyBlue.withOpacity(0.6),
              ),
              prefixText: prefixText,
              prefixStyle: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primaryDark,
                fontWeight: FontWeight.bold,
              ),
              suffixIcon: suffixIcon != null
                  ? Icon(
                      suffixIcon,
                      color: AppColors.secondaryGreyBlue,
                      size: 18,
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTypeChip(String type) {
    bool isSelected = controller.selectedBusType.value == type;
    return GestureDetector(
      onTap: () => controller.selectBusType(type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryAccent.withOpacity(0.05)
              : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryAccent
                : AppColors.secondaryGreyBlue.withOpacity(0.2),
          ),
        ),
        child: Text(
          type,
          style: AppTextStyles.caption.copyWith(
            color: isSelected
                ? AppColors.primaryAccent
                : AppColors.secondaryGreyBlue,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildTimePickerField(
    String label,
    bool isDeparture,
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.primaryDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => controller.pickTime(context, isDeparture),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.secondaryGreyBlue.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(
                  () => Text(
                    isDeparture
                        ? controller.departureTime.value
                        : controller.arrivalTime.value,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color:
                          (isDeparture
                                  ? controller.departureTime.value
                                  : controller.arrivalTime.value) ==
                              '--:-- --'
                          ? AppColors.secondaryGreyBlue.withOpacity(0.6)
                          : AppColors.primaryDark,
                    ),
                  ),
                ),
                const Icon(
                  Icons.access_time,
                  color: AppColors.secondaryGreyBlue,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
