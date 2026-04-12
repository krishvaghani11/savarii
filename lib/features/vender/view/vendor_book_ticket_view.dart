import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:savarii/core/theme/app_colors.dart';
import 'package:savarii/core/theme/app_text_styles.dart';
import 'package:savarii/core/utils/locale_utils.dart';
import 'package:savarii/core/widgets/bus_seat_layout.dart';
import '../controllers/vendor_book_ticket_controller.dart';

class VendorBookTicketView extends GetView<VendorBookTicketController> {
  const VendorBookTicketView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground, // Light grey background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Text('booking.title'.tr(), style: AppTextStyles.h3),
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
                      // 1. SELECT JOURNEY DETAILS
                      _buildSectionCard(
                        title: 'booking.select_journey'.tr(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('booking.select_bus'.tr()),
                            _buildBusSelectionDropdown(),
                            const SizedBox(height: 16),
                            Obx(
                              () => Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _buildLabel('booking.boarding_point'.tr()),
                                        _buildPointDropdown(
                                          hint: 'booking.select_boarding'.tr(),
                                          items:
                                              controller.currentBoardingPoints,
                                          selectedValue: controller
                                              .selectedBoardingPoint
                                              .value,
                                          onChanged:
                                              controller.selectBoardingPoint,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _buildLabel('booking.dropping_point'.tr()),
                                        _buildPointDropdown(
                                          hint: 'booking.select_dropping'.tr(),
                                          items:
                                              controller.currentDroppingPoints,
                                          selectedValue: controller
                                              .selectedDroppingPoint
                                              .value,
                                          onChanged:
                                              controller.selectDroppingPoint,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildTimeDetails(),
                            const SizedBox(height: 16),
                            _buildLabel('booking.journey_date'.tr()),
                            _buildDatePicker(context),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 2. SELECT SEATS
                      _buildSectionCard(
                        title: 'booking.select_seats'.tr(),
                        trailing: Obx(
                          () => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryAccent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${LocaleUtils.formatCount(context, controller.passengerCount.value)} ${"booking.passengers_selected".tr()}',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.primaryAccent,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        child: Column(
                          children: [
                            _buildDeckToggle(),
                            const SizedBox(height: 24),
                            _buildSeatLegend(),
                            const SizedBox(height: 24),
                            _buildPassengerCountControl(),
                            const SizedBox(height: 24),
                            _buildSeatMapContainer(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 3. PASSENGER DETAILS
                      _buildSectionCard(
                        title: 'booking.passenger_details'.tr(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('booking.passenger_name'.tr()),
                            _buildTextField(
                              'booking.passenger_name_hint'.tr(),
                              controller.nameController,
                            ),
                            const SizedBox(height: 16),
                            _buildLabel('booking.passenger_phone'.tr()),
                            _buildMobileField(),
                            const SizedBox(height: 16),
                            _buildLabel('booking.gender'.tr()),
                            _buildGenderSelection(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),

            // 4. Sticky Bottom Checkout Bar
            _buildCheckoutBar(context),
          ],
        ),
      ),
    );
  }

  // --- Sub-Widgets ---

  Widget _buildSectionCard({
    required String title,
    Widget? trailing,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.secondaryGreyBlue.withOpacity(0.1)),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.secondaryGreyBlue.withOpacity(0.8),
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 16),
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

  Widget _buildTextField(String hint, TextEditingController textController) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.secondaryGreyBlue.withOpacity(0.2)),
      ),
      child: TextFormField(
        controller: textController,
        style: AppTextStyles.bodyMedium,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.secondaryGreyBlue.withOpacity(0.6),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildPointDropdown({
    required String hint,
    required List<Map<String, dynamic>> items,
    required Map<String, dynamic>? selectedValue,
    required Function(Map<String, dynamic>?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.secondaryGreyBlue.withOpacity(0.2)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Map<String, dynamic>>(
          isExpanded: true,
          hint: Text(
            hint,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.secondaryGreyBlue.withOpacity(0.6),
            ),
          ),
          value: items.contains(selectedValue) ? selectedValue : null,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: AppColors.primaryDark,
          ),
          items: items.map((point) {
            final String name = point['pointName'] ?? 'Unknown';
            final String time = point['time'] ?? '';
            return DropdownMenuItem<Map<String, dynamic>>(
              value: point,
              child: Text(
                time.isEmpty ? name : '$name ($time)',
                style: AppTextStyles.bodyMedium,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildBusSelectionDropdown() {
    return Obx(() {
      if (controller.availableBuses.isEmpty) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.secondaryGreyBlue.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.secondaryGreyBlue.withOpacity(0.2),
            ),
          ),
          child: Text(
            'booking.no_buses'.tr(),
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.secondaryGreyBlue,
            ),
          ),
        );
      }

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.secondaryGreyBlue.withOpacity(0.2),
          ),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true,
            hint: Text(
              'booking.select_route'.tr(),
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.secondaryGreyBlue.withOpacity(0.6),
              ),
            ),
            value: controller.selectedBusId.value,
            icon: const Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.primaryDark,
            ),
            items: controller.availableBuses.map((bus) {
              final route = bus['route'] ?? {};
              String busName = bus['busName'] ?? 'Unknown Bus';
              String from = route['from'] ?? 'Unknown';
              String to = route['to'] ?? 'Unknown';
              String busId = bus['id'] ?? '';
              return DropdownMenuItem<String>(
                value: busId,
                child: Text(
                  '$busName ($from - $to)',
                  style: AppTextStyles.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) {
                controller.selectBus(val);
              }
            },
          ),
        ),
      );
    });
  }

  Widget _buildTimeDetails() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryAccent.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryAccent.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'booking.departure'.tr(),
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.secondaryGreyBlue,
                  ),
                ),
                Obx(
                  () => Text(
                    controller.departureTime.value,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              const Icon(
                Icons.arrow_forward_outlined,
                color: AppColors.primaryAccent,
                size: 18,
              ),
              Obx(
                () => Text(
                  controller.journeyDuration.value,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primaryAccent,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'booking.arrival'.tr(),
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.secondaryGreyBlue,
                  ),
                ),
                Obx(
                  () => Text(
                    controller.arrivalTime.value,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
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

  Widget _buildMobileField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.secondaryGreyBlue.withOpacity(0.2)),
      ),
      child: TextFormField(
        controller: controller.phoneController,
        keyboardType: TextInputType.phone,
        style: AppTextStyles.bodyMedium,
        decoration: InputDecoration(
          hintText: '00000 00000',
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.secondaryGreyBlue.withOpacity(0.6),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          prefixIcon: Padding(
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
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 0,
            minHeight: 0,
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return GestureDetector(
      onTap: () => controller.pickDate(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.secondaryGreyBlue.withOpacity(0.2),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Obx(
              () => Text(
                controller.journeyDate.value,
                style: AppTextStyles.bodyMedium,
              ),
            ),
            const Icon(
              Icons.calendar_today_outlined,
              color: AppColors.primaryDark,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeckToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.secondaryGreyBlue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Obx(
        () => Row(
          children: [
            Expanded(child: _buildDeckButton('LOWER DECK')),
            Expanded(child: _buildDeckButton('UPPER DECK')),
          ],
        ),
      ),
    );
  }

  Widget _buildDeckButton(String deck) {
    bool isSelected = controller.selectedDeck.value == deck;
    return GestureDetector(
      onTap: () => controller.setDeck(deck),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                  ),
                ]
              : [],
        ),
        child: Center(
          child: Text(
            deck,
            style: AppTextStyles.caption.copyWith(
              color: isSelected
                  ? AppColors.primaryAccent
                  : AppColors.secondaryGreyBlue,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSeatLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem(
          color: AppColors.secondaryGreyBlue.withOpacity(0.2),
          label: 'booking.booked_seats'.tr(),
        ),
        const SizedBox(width: 16),
        _buildLegendItem(
          color: AppColors.white,
          borderColor: AppColors.secondaryGreyBlue.withOpacity(0.3),
          label: 'booking.available_seats'.tr(),
        ),
        const SizedBox(width: 16),
        _buildLegendItem(color: AppColors.primaryAccent, label: 'booking.selected'.tr()),
      ],
    );
  }

  Widget _buildLegendItem({
    required Color color,
    Color? borderColor,
    required String label,
  }) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: borderColor != null ? Border.all(color: borderColor) : null,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.secondaryGreyBlue,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildPassengerCountControl() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'booking.select_passengers_num'.tr(),
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.primaryDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        Row(
          children: [
            GestureDetector(
              onTap: controller.decrementPassenger,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.secondaryGreyBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.remove,
                  color: AppColors.primaryDark,
                  size: 18,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Obx(
              () => Text(
                '${controller.passengerCount.value}',
                style: AppTextStyles.h3.copyWith(fontSize: 18),
              ),
            ),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: controller.incrementPassenger,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryAccent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.add, color: AppColors.white, size: 18),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSeatMapContainer() {
    return Obx(
      () => BusSeatLayout(
        bookedSeats: controller.bookedSeats.toList(),
        selectedSeats: controller.selectedSeats.toList(),
        isUpperDeck: controller.selectedDeck.value == 'UPPER DECK',
        onSeatTap: controller.toggleSeat,
      ),
    );
  }

  Widget _buildGenderSelection() {
    return Obx(
      () => Row(
        children: [
          Expanded(child: _buildGenderButton('booking.male'.tr())),
          const SizedBox(width: 12),
          Expanded(child: _buildGenderButton('booking.female'.tr())),
          const SizedBox(width: 12),
          Expanded(child: _buildGenderButton('booking.other'.tr())),
        ],
      ),
    );
  }

  Widget _buildGenderButton(String gender) {
    bool isSelected = controller.selectedGender.value == gender;
    return GestureDetector(
      onTap: () => controller.selectedGender.value = gender,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryAccent.withOpacity(0.08)
              : AppColors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryAccent
                : AppColors.secondaryGreyBlue.withOpacity(0.2),
          ),
        ),
        child: Center(
          child: Text(
            gender,
            style: AppTextStyles.caption.copyWith(
              color: isSelected
                  ? AppColors.primaryAccent
                  : AppColors.primaryDark,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckoutBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(color: AppColors.secondaryGreyBlue.withOpacity(0.1)),
        ),
      ),
      child: Row(
        children: [
          // Amount & Seats Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'booking.total_amount'.tr(),
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.secondaryGreyBlue,
                    fontSize: 11,
                  ),
                ),
                Obx(
                  () => Text(
                    LocaleUtils.formatCurrency(context, (controller.selectedSeats.length * controller.pricePerSeat.value).toDouble()),
                    style: AppTextStyles.h2.copyWith(fontSize: 20),
                  ),
                ),
                const SizedBox(height: 2),
                Obx(
                  () => Text(
                    controller.selectedSeats.isEmpty
                        ? 'booking.no_seats'.tr()
                        : '${LocaleUtils.formatCount(context, controller.selectedSeats.length)} ${"booking.seats_selected".tr()} (${controller.selectedSeats.join(', ')})',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primaryAccent,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // Confirm Button
          ElevatedButton(
            onPressed: controller.confirmBooking,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryAccent,
              minimumSize: const Size(0, 0),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: Text(
              'booking.confirm_booking'.tr(),
              style: AppTextStyles.buttonText.copyWith(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
