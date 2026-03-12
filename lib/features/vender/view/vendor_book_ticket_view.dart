import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:savarii/core/theme/app_colors.dart';
import 'package:savarii/core/theme/app_text_styles.dart';
import '../controllers/vendor_book_ticket_controller.dart';

class VendorBookTicketView extends GetView<VendorBookTicketController> {
  const VendorBookTicketView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Text('Book Ticket', style: AppTextStyles.h3),
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
                      // 1. SELECT BUS & JOURNEY
                      _buildSectionCard(
                        title: 'SELECT BUS & JOURNEY',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Route / Bus Service'),
                            _buildDropdown(),
                            const SizedBox(height: 16),
                            _buildLabel('Journey Date'),
                            _buildDatePicker(context),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 2. SELECT SEATS
                      _buildSectionCard(
                        title: 'SELECT SEATS',
                        child: Column(
                          children: [
                            _buildDeckToggle(),
                            const SizedBox(height: 24),
                            _buildSeatLegend(),
                            const SizedBox(height: 32),
                            _buildSeatMap(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 3. PASSENGER DETAILS
                      _buildSectionCard(
                        title: 'PASSENGER DETAILS',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Full Name'),
                            _buildTextField(
                              'Enter passenger name',
                              controller.nameController,
                            ),
                            const SizedBox(height: 16),
                            _buildLabel('Mobile Number'),
                            _buildTextField(
                              '+91 00000 00000',
                              controller.phoneController,
                              isPhone: true,
                            ),
                            const SizedBox(height: 16),
                            _buildLabel('Gender'),
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
            _buildCheckoutBar(),
          ],
        ),
      ),
    );
  }

  // --- Sub-Widgets ---

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.secondaryGreyBlue.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryGreyBlue.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.secondaryGreyBlue,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
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

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.secondaryGreyBlue.withValues(alpha: 0.3)),
      ),
      child: Obx(
        () => DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: controller.selectedRoute.value,
            isExpanded: true,
            icon: const Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.secondaryGreyBlue,
            ),
            items: controller.availableRoutes.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  style: AppTextStyles.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: (newValue) => controller.selectedRoute.value = newValue!,
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
            color: AppColors.secondaryGreyBlue.withValues(alpha: 0.3),
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
              Icons.calendar_today,
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
        color: AppColors.secondaryGreyBlue.withValues(alpha: 0.05),
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
                    color: Colors.black.withValues(alpha: 0.05),
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
          color: AppColors.secondaryGreyBlue.withValues(alpha: 0.2),
          label: 'Booked',
        ),
        const SizedBox(width: 16),
        _buildLegendItem(
          color: AppColors.white,
          borderColor: AppColors.secondaryGreyBlue.withValues(alpha: 0.3),
          label: 'Available',
        ),
        const SizedBox(width: 16),
        _buildLegendItem(color: AppColors.primaryAccent, label: 'Selected'),
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
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildSeatMap() {
    return Column(
      children: [
        _buildSeatRow('L1', 'L2', 'R1'),
        const SizedBox(height: 16),
        _buildSeatRow('L3', 'L4', 'R3'),
        const SizedBox(height: 16),
        _buildSeatRow('L5', 'L6', 'R5'),
        const SizedBox(height: 16),
        _buildSeatRow('L7', 'L8', 'R7'),
      ],
    );
  }

  Widget _buildSeatRow(String left1, String left2, String right1) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSeat(left1),
        const SizedBox(width: 16),
        _buildSeat(left2),
        const SizedBox(width: 48), // The Aisle
        _buildSeat(right1),
      ],
    );
  }

  Widget _buildSeat(String seatId) {
    return Obx(() {
      bool isBooked = controller.bookedSeats.contains(seatId);
      bool isSelected = controller.selectedSeats.contains(seatId);

      Color bgColor = AppColors.white;
      Color borderColor = AppColors.secondaryGreyBlue.withValues(alpha: 0.3);
      Color textColor = AppColors.primaryDark;

      if (isBooked) {
        bgColor = AppColors.secondaryGreyBlue.withValues(alpha: 0.15);
        borderColor = Colors.transparent;
        textColor = AppColors.secondaryGreyBlue.withValues(alpha: 0.6);
      } else if (isSelected) {
        bgColor = AppColors.primaryAccent.withValues(alpha: 0.1);
        borderColor = AppColors.primaryAccent;
        textColor = AppColors.primaryAccent;
      }

      return GestureDetector(
        onTap: () => controller.toggleSeat(seatId),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 50,
              height: 65,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: borderColor,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Center(
                child: Text(
                  seatId,
                  style: AppTextStyles.caption.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // The little checkmark badge for selected seats
            if (isSelected)
              Positioned(
                right: -4,
                top: -4,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: AppColors.primaryAccent,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: AppColors.white,
                    size: 10,
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildTextField(
    String hint,
    TextEditingController textController, {
    bool isPhone = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.secondaryGreyBlue.withValues(alpha: 0.3)),
      ),
      child: TextFormField(
        controller: textController,
        keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
        validator: (value) => value!.isEmpty ? 'Required' : null,
        style: AppTextStyles.bodyMedium,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.secondaryGreyBlue.withValues(alpha: 0.6),
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

  Widget _buildGenderSelection() {
    return Obx(
      () => Row(
        children: [
          Expanded(child: _buildGenderButton('Male')),
          const SizedBox(width: 12),
          Expanded(child: _buildGenderButton('Female')),
          const SizedBox(width: 12),
          Expanded(child: _buildGenderButton('Other')),
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
              ? AppColors.primaryAccent.withValues(alpha: 0.1)
              : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryAccent
                : AppColors.secondaryGreyBlue.withValues(alpha: 0.3),
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

  Widget _buildCheckoutBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryGreyBlue.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
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
                  'Total Amount',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.secondaryGreyBlue,
                  ),
                ),
                Obx(
                  () => Text(
                    '₹${(controller.selectedSeats.length * controller.pricePerSeat).toStringAsFixed(2)}',
                    style: AppTextStyles.h2.copyWith(fontSize: 20),
                  ),
                ),
                const SizedBox(height: 2),
                Obx(
                  () => Text(
                    controller.selectedSeats.isEmpty
                        ? 'No seats selected'
                        : '${controller.selectedSeats.length} Seat(s) Selected (${controller.selectedSeats.join(', ')})',
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
              minimumSize: const Size(0, 0), // Fixes infinite width crash in Row
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: Text(
              'Confirm Booking',
              style: AppTextStyles.buttonText.copyWith(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
