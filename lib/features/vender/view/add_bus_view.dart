import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
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
        title: Text('add_bus.title'.tr(), style: AppTextStyles.h3),
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
                      _buildSectionHeader(Icons.directions_bus, 'add_bus.bus_details_section'.tr()),
                      _buildCardContainer(
                        child: Column(
                          children: [
                            _buildInputField(
                              'add_bus.bus_name'.tr(),
                              'e.g. Scania Touring',
                              controller.busNameController,
                              validator: controller.validateRequired,
                            ),
                            const SizedBox(height: 16),
                            _buildInputField(
                              'add_bus.bus_number'.tr(),
                              'e.g. MH 12 AB 1234',
                              controller.busNumberController,
                              validator: controller.validateRequired,
                            ),
                            const SizedBox(height: 16),
                            _buildInputField(
                              'add_bus.total_seats'.tr(),
                              'e.g. 45',
                              controller.totalSeatsController,
                              keyboardType: TextInputType.number,
                              suffixIcon: Icons.event_seat,
                              validator: controller.validateNumber,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 2. BUS TYPE
                      _buildSectionHeader(Icons.category, 'add_bus.bus_type_section'.tr()),
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
                      _buildSectionHeader(Icons.alt_route, 'add_bus.route_schedule_section'.tr()),
                      _buildCardContainer(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _buildInputField(
                                    'add_bus.from'.tr(),
                                    'Origin',
                                    controller.fromController,
                                    validator: controller.validateRequired,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildInputField(
                                    'add_bus.to'.tr(),
                                    'Destination',
                                    controller.toController,
                                    validator: controller.validateRequired,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTimePickerField(
                                    'add_bus.departure'.tr(),
                                    true,
                                    context,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildTimePickerField(
                                    'add_bus.arrival'.tr(),
                                    false,
                                    context,
                                  ),
                                ),
                              ],
                            ),

                            // --- DYNAMIC BOARDING POINTS ---
                            _buildSubHeaderWithAddButton(
                              'add_bus.boarding_points_section'.tr(),
                              controller.addBoardingPoint,
                            ),

                            // Input Row
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: _buildSimpleTextField(
                                    controller.bpNameController,
                                    'add_bus.point_name'.tr(),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  flex: 2,
                                  child: _buildSimpleTimePicker(
                                    controller.bpTime,
                                    () => controller.pickBpTime(context),
                                  ),
                                ),
                              ],
                            ),

                            // Saved List of Boarding Points
                            Obx(
                              () => Column(
                                children: List.generate(
                                  controller.savedBoardingPoints.length,
                                  (index) => _buildSavedPoint(
                                      controller.savedBoardingPoints[index],
                                      () => controller.removeBoardingPoint(index),
                                  ),
                                ),
                              ),
                            ),

                            // --- DYNAMIC DROPPING POINTS ---
                            _buildSubHeaderWithAddButton(
                              'add_bus.dropping_points_section'.tr(),
                              controller.addDroppingPoint,
                            ),

                            // Input Row
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: _buildSimpleTextField(
                                    controller.dpNameController,
                                    'add_bus.point_name'.tr(),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  flex: 2,
                                  child: _buildSimpleTimePicker(
                                    controller.dpTime,
                                    () => controller.pickDpTime(context),
                                  ),
                                ),
                              ],
                            ),

                            // Saved List of Dropping Points
                            Obx(
                              () => Column(
                                children: List.generate(
                                  controller.savedDroppingPoints.length,
                                  (index) => _buildSavedPoint(
                                      controller.savedDroppingPoints[index],
                                      () => controller.removeDroppingPoint(index),
                                  ),
                                ),
                              ),
                            ),

                            // --- DYNAMIC REST STOPS ---
                            _buildSubHeaderWithAddButton(
                              'add_bus.rest_stops_section'.tr(),
                              controller.addRestStop,
                            ),

                            // Inputs Column
                            _buildInputField(
                              'add_bus.rest_stop_name'.tr(),
                              'e.g. Highway Plaza, NH48',
                              controller.rsNameController,
                            ),
                            const SizedBox(height: 12),
                            _buildInputField(
                              'add_bus.rest_stop_duration'.tr(),
                              'e.g. 20 mins',
                              controller.rsDurationController,
                            ),

                            // Saved List of Rest Stops
                            Obx(
                              () => Column(
                                children: List.generate(
                                  controller.savedRestStops.length,
                                  (index) => _buildSavedRestStop(index),
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),
                            _buildInputField(
                              'add_bus.ticket_price'.tr(),
                              '0',
                              controller.priceController,
                              keyboardType: TextInputType.number,
                              prefixText: '₹ ',
                              validator: controller.validateNumber,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 4. DRIVER DETAILS
                      _buildSectionHeader(
                        Icons.account_circle,
                        'add_bus.driver_details_section'.tr(),
                      ),
                      _buildCardContainer(
                        child: Column(
                          children: [
                            _buildInputField(
                              'add_bus.driver_name'.tr(),
                              'e.g. John Doe',
                              controller.driverNameController,
                              validator: controller.validateRequired,
                            ),
                            const SizedBox(height: 16),
                            _buildInputField(
                              'add_bus.driver_mobile'.tr(),
                              'e.g. +1 234 567 890',
                              controller.driverMobileController,
                              keyboardType: TextInputType.phone,
                              validator: controller.validateRequired,
                            ),
                            const SizedBox(height: 16),
                            _buildInputField(
                              'add_bus.license_number'.tr(),
                              'e.g. ABC123456789',
                              controller.licenseController,
                              validator: controller.validateRequired,
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
                  'add_bus.save_bus'.tr(),
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

  Widget _buildSubHeaderWithAddButton(String title, VoidCallback onAdd) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.primaryDark,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          GestureDetector(
            onTap: onAdd,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryAccent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.add, color: AppColors.white, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    'Add',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleTextField(TextEditingController ctrl, String hint) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.secondaryGreyBlue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: ctrl,
        style: AppTextStyles.bodyMedium,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.secondaryGreyBlue.withOpacity(0.6),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildSimpleTimePicker(RxString timeVal, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: BoxDecoration(
          color: AppColors.secondaryGreyBlue.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Obx(
              () => Text(
                timeVal.value,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: timeVal.value == '--:-- --'
                      ? AppColors.secondaryGreyBlue.withOpacity(0.6)
                      : AppColors.primaryDark,
                ),
              ),
            ),
            const Icon(
              Icons.access_time,
              color: AppColors.secondaryGreyBlue,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  // Generic Row for showing Saved Boarding/Dropping Point
  Widget _buildSavedPoint(Map<String, String> point, VoidCallback onRemove) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              decoration: BoxDecoration(
                color: AppColors.secondaryGreyBlue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                point['pointName']!,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primaryDark,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 15,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryGreyBlue.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        point['time']!,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primaryDark,
                        ),
                      ),
                      const Icon(
                        Icons.access_time,
                        color: AppColors.secondaryGreyBlue,
                        size: 16,
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: -8,
                  top: -8,
                  child: GestureDetector(
                    onTap: onRemove,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.secondaryGreyBlue.withOpacity(0.2),
                        ),
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 12,
                        color: AppColors.secondaryGreyBlue,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedRestStop(int index) {
    final rs = controller.savedRestStops[index];
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              decoration: BoxDecoration(
                color: AppColors.secondaryGreyBlue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                rs['stopName']!,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primaryDark,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 15,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryGreyBlue.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    rs['duration']!,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
                Positioned(
                  right: -8,
                  top: -8,
                  child: GestureDetector(
                    onTap: () => controller.removeRestStop(index),
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.secondaryGreyBlue.withOpacity(0.2),
                        ),
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 12,
                        color: AppColors.secondaryGreyBlue,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(
    String label,
    String hint,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    IconData? suffixIcon,
    String? prefixText,
    FormFieldValidator<String>? validator,
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
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            style: AppTextStyles.bodyMedium,
            validator: validator,
            autovalidateMode: AutovalidateMode.onUserInteraction,
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
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 1),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 1.5),
              ),
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