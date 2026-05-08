import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:savarii/features/vender/controllers/customize_layout_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/seat_model.dart';
import '../../../core/widgets/bus_seat_layout.dart';

class CustomizeLayoutView extends GetView<CustomizeLayoutController> {
  const CustomizeLayoutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Customize Layout',
          style: AppTextStyles.h3.copyWith(color: AppColors.white),
        ),
        actions: const [
          // Removed logo per user request
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Deck Toggle
                    Row(
                      children: [
                        Expanded(child: _buildDeckToggle('Lower Deck', true)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildDeckToggle('Upper Deck', false)),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Dimensions & Type Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Seat Type',
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildSeatTypeCard(
                                  'Seater',
                                  Icons.event_seat,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildSeatTypeCard('Sleeper', Icons.bed),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          _buildSectionTitle(Icons.flash_on, 'Quick Presets'),
                          const SizedBox(height: 16),

                          // Type-aware presets
                          Obx(() {
                            final isSeater =
                                controller.seatType.value == 'seater';
                            final presets = isSeater
                                ? [
                                    ('2x1', 'BUSINESS'),
                                    ('2x2', 'STANDARD'),
                                    ('3x2', 'EXECUTIVE')
                                  ]
                                : [
                                    ('2x1', 'SEMI-SLEEPER'),
                                    ('2x2', 'FULL SLEEPER'),
                                  ];

                            return Row(
                              children: presets.map((p) {
                                final presetKey = p.$1;
                                final presetLabel = presetKey.replaceAll(
                                  'x',
                                  ' x ',
                                );
                                final subtitle = p.$2;
                                return Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: _buildPresetCard(
                                      presetLabel,
                                      subtitle,
                                      presetKey,
                                    ),
                                  ),
                                );
                              }).toList(),
                            );
                          }),

                          const SizedBox(height: 16),

                          // Capacity info chip
                          Obx(() {
                            final cap = controller.currentDeckCapacity;
                            return Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryAccent.withOpacity(
                                  0.08,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Expected capacity: $cap seats per deck',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.primaryAccent,
                                ),
                              ),
                            );
                          }),

                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: controller.confirmCurrentDeck,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryAccent,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Obx(
                                () => Text(
                                  controller.isLowerDeck.value
                                      ? 'Confirm Lower Deck'
                                      : 'Confirm Upper Deck',
                                  style: AppTextStyles.buttonText,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Bus Visual Representation
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 32,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryGreyBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(
                          color: AppColors.secondaryGreyBlue.withOpacity(0.2),
                          width: 4,
                        ),
                      ),
                      child: Column(
                        children: [
                          // Driver Section — always RIGHT side
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                width: 80,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: AppColors.secondaryGreyBlue
                                      .withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(width: 24),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryDark,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  children: [
                                    const Icon(
                                      Icons.person,
                                      color: AppColors.white,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'DRIVER',
                                      style: AppTextStyles.caption.copyWith(
                                        color: AppColors.white,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Divider(
                            color: AppColors.secondaryGreyBlue.withOpacity(0.2),
                          ),
                          const SizedBox(height: 16),

                          // Grid Area
                          Obx(() {
                            return GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: controller.cols.value,
                                    crossAxisSpacing: 8,
                                    mainAxisSpacing: 16,
                                    childAspectRatio: controller.seatType.value == 'sleeper'
                                        ? (0.45 * 5 / controller.cols.value)
                                        : (0.65 * 5 / controller.cols.value),
                                  ),
                              itemCount: controller.seats.length,
                              itemBuilder: (context, index) {
                                final seat = controller.seats[index];
                                return GestureDetector(
                                  onTap: () {
                                    _showSeatOptionsDialog(
                                      context,
                                      index,
                                      seat,
                                    );
                                  },
                                  child: seat.isSpace
                                      ? Container(
                                          color: Colors.transparent,
                                          alignment: Alignment.center,
                                          child: const Icon(
                                            Icons.add,
                                            size: 20,
                                            color: Colors.black12,
                                          ),
                                        )
                                      : Column(
                                          children: [
                                            Expanded(
                                              child: SeatTileWidget(
                                                seatId: seat.id,
                                                isBooked: false,
                                                isSelected: false,
                                                type: seat.type,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '₹${seat.price.toStringAsFixed(0)}',
                                              style: AppTextStyles.caption
                                                  .copyWith(
                                                    fontSize: 10,
                                                    color: AppColors
                                                        .secondaryGreyBlue,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                          ],
                                        ),
                                );
                              },
                            );
                          }),

                          const SizedBox(height: 32),
                          // Engine
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(
                                255,
                                24,
                                39,
                                65,
                              ).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'REAR ENGINE BAY',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.secondaryGreyBlue,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),
                    // Legend
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(width: 16),
                        _buildLegendItem(
                          AppColors.secondaryGreyBlue.withOpacity(0.2),
                          'Empty Space',
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Detailed Photo Instruction Legend
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.secondaryGreyBlue.withOpacity(0.1),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SEAT STATUS LEGEND',
                            style: AppTextStyles.caption.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildExtendedLegendRow(
                            Colors.green,
                            'Available',
                            null,
                          ),
                          _buildExtendedLegendRow(
                            AppColors.secondaryGreyBlue.withOpacity(0.2),
                            'Already booked',
                            null,
                          ),
                          _buildExtendedLegendRow(
                            const Color(0xFFFF69B4),
                            'Available only for female',
                            Icons.person,
                          ),
                          _buildExtendedLegendRow(
                            const Color(0xFFFFE4E1).withOpacity(0.8),
                            'Booked by female passenger',
                            null,
                          ),
                          _buildExtendedLegendRow(
                            const Color(0xFF1E90FF),
                            'Available only for male',
                            Icons.person,
                          ),
                          _buildExtendedLegendRow(
                            const Color(0xFFE0F7FA).withOpacity(0.8),
                            'Booked by male passenger',
                            null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Save Bar
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CAPACITY',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.secondaryGreyBlue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Obx(
                            () => Text(
                              '${controller.totalCapacity} Seats',
                              style: AppTextStyles.h3.copyWith(
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'EST. REVENUE',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.secondaryGreyBlue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Obx(
                            () => Text(
                              '₹${controller.estimatedRevenue.toStringAsFixed(0)} / Trip',
                              style: AppTextStyles.h3.copyWith(
                                color: AppColors.primaryAccent,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: controller.discardChanges,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: const BorderSide(
                              color: AppColors.secondaryGreyBlue,
                            ),
                          ),
                          child: Text(
                            'Discard\nChanges',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.buttonText.copyWith(
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: controller.saveLayout,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryAccent,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Save Layout'
                                '',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.buttonText,
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.save_alt,
                                color: AppColors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSeatOptionsDialog(BuildContext context, int index, SeatModel seat) {
    double tempPrice = seat.price;
    String tempId = seat.id;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Seat ${seat.id} Settings', style: AppTextStyles.h3),
                const SizedBox(height: 24),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    seat.isSpace
                        ? Icons.add_circle_outline
                        : Icons.remove_circle_outline,
                    color: AppColors.primaryAccent,
                  ),
                  title: Text(
                    seat.isSpace
                        ? 'Convert to Active Seat'
                        : 'Convert to Empty Space',
                  ),
                  onTap: () {
                    controller.toggleSeatSpace(index);
                    Get.back();
                  },
                ),
                if (!seat.isSpace) ...[
                  const SizedBox(height: 16),
                  Text('Seat Number / ID', style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: tempId,
                    decoration: InputDecoration(
                      hintText: 'Enter seat number',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (val) {
                      tempId = val;
                    },
                  ),
                  const SizedBox(height: 16),
                  Text('Custom Seat Price', style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: tempPrice.toString(),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      prefixText: '₹ ',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (val) {
                      tempPrice = double.tryParse(val) ?? 0.0;
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        controller.updateSeatDetails(index, tempId, tempPrice);
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryAccent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Update Details'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDeckToggle(String label, bool isLower) {
    return Obx(() {
      final isSelected = controller.isLowerDeck.value == isLower;
      return GestureDetector(
        onTap: () => controller.toggleDeck(isLower),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryAccent : AppColors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? AppColors.primaryAccent
                  : AppColors.secondaryGreyBlue.withOpacity(0.2),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isSelected ? AppColors.white : AppColors.primaryDark,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildSectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryAccent, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildSeatTypeCard(String label, IconData icon) {
    return Obx(() {
      final isSelected = controller.seatType.value == label.toLowerCase();
      return GestureDetector(
        onTap: () => controller.setSeatType(label.toLowerCase()),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryAccent.withOpacity(0.05)
                : AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppColors.primaryAccent
                  : AppColors.secondaryGreyBlue.withOpacity(0.2),
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? AppColors.primaryAccent
                    : AppColors.secondaryGreyBlue,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isSelected
                      ? AppColors.primaryDark
                      : AppColors.secondaryGreyBlue,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildPresetCard(String title, String subtitle, String presetKey) {
    return Obx(() {
      final isSelected = controller.selectedPreset.value == presetKey;
      return GestureDetector(
        onTap: () => controller.applyPreset(presetKey),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.secondaryGreyBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primaryAccent : Colors.transparent,
              width: 2,
            ),
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.primaryAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
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
      );
    });
  }

  Widget _buildExtendedLegendRow(Color color, String label, IconData? icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: label.contains('Booked') ? color : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
              border: label.contains('Booked')
                  ? null
                  : Border.all(color: color, width: 1.5),
            ),
            child: icon != null ? Icon(icon, size: 14, color: color) : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.primaryDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}
