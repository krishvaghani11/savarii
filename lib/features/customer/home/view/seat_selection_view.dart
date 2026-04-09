import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:savarii/core/theme/app_colors.dart';
import 'package:savarii/core/theme/app_text_styles.dart';
import 'package:savarii/features/customer/home/controller/seat_selection_controller.dart';

class SeatSelectionView extends GetView<SeatSelectionController> {
  const SeatSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          // 1. The Main Scrollable Content (Header + Seat Grid)
          // Padding bottom to ensure the seat grid doesn't get completely hidden by the slider
          Positioned.fill(
            bottom: 60,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeaderCard(),
                  const SizedBox(height: 24),
                  _buildDeckToggle(),
                  const SizedBox(height: 24),
                  _buildLegend(),
                  const SizedBox(height: 32),
                  _buildSeatGrid(),
                  const SizedBox(height: 100),
                  // Extra buffer for scrolling above the slider
                ],
              ),
            ),
          ),

          // 2. The Draggable Bottom Sheet (Slider)
          _buildDraggableSlider(),
        ],
      ),
      // 3. Fixed Bottom Action Bar
      bottomNavigationBar: _buildBottomActionBar(),
    );
  }

  // --- Header & AppBar Widgets ---

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.lightBackground,
      elevation: 0,
      centerTitle: false,
      title: Text('Select Seats', style: AppTextStyles.h3),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.primaryDark),
        onPressed: () => Get.back(),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 20, top: 12, bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.star_border, color: Colors.green.shade700, size: 14),
              const SizedBox(width: 4),
              Text(
                '4.2',
                style: AppTextStyles.caption.copyWith(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryGreyBlue.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryAccent.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.directions_bus,
              color: AppColors.primaryAccent,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.busName,
                  style: AppTextStyles.h3.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 4),
                Obx(() {
                  String combined = controller.busType.value;
                  if (controller.durationInfo.value.isNotEmpty) {
                    combined += ' • ${controller.durationInfo.value}';
                  }
                  return Text(
                    combined,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.secondaryGreyBlue,
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeckToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.secondaryGreyBlue.withOpacity(0.2)),
      ),
      child: Obx(
        () => Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => controller.toggleDeck(true),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: controller.isLowerDeck.value
                        ? AppColors.white
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: controller.isLowerDeck.value
                        ? [
                            BoxShadow(
                              color: AppColors.secondaryGreyBlue.withOpacity(
                                0.1,
                              ),
                              blurRadius: 5,
                            ),
                          ]
                        : [],
                  ),
                  child: Center(
                    child: Text(
                      'LOWER DECK',
                      style: AppTextStyles.caption.copyWith(
                        color: controller.isLowerDeck.value
                            ? AppColors.primaryAccent
                            : AppColors.secondaryGreyBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => controller.toggleDeck(false),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: !controller.isLowerDeck.value
                        ? AppColors.white
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: !controller.isLowerDeck.value
                        ? [
                            BoxShadow(
                              color: AppColors.secondaryGreyBlue.withOpacity(
                                0.1,
                              ),
                              blurRadius: 5,
                            ),
                          ]
                        : [],
                  ),
                  child: Center(
                    child: Text(
                      'UPPER DECK',
                      style: AppTextStyles.caption.copyWith(
                        color: !controller.isLowerDeck.value
                            ? AppColors.primaryAccent
                            : AppColors.secondaryGreyBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendItem(
          AppColors.secondaryGreyBlue.withOpacity(0.2),
          'Booked',
          hasBorder: false,
        ),
        const SizedBox(width: 16),
        _legendItem(AppColors.white, 'Available', hasBorder: true),
        const SizedBox(width: 16),
        _legendItem(
          AppColors.primaryAccent,
          'Selected',
          hasBorder: false,
          isWhiteText: true,
        ),
      ],
    );
  }

  Widget _legendItem(
    Color color,
    String label, {
    required bool hasBorder,
    bool isWhiteText = false,
  }) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: hasBorder
                ? Border.all(
                    color: AppColors.secondaryGreyBlue.withOpacity(0.5),
                  )
                : null,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.secondaryGreyBlue,
          ),
        ),
      ],
    );
  }

  // --- Seat Grid Widgets ---

  Widget _buildSeatGrid() {
    return Obx(() {
      final isLower = controller.isLowerDeck.value;
      final prefixL = isLower ? 'L' : 'UL';
      final prefixR = isLower ? 'R' : 'UR';

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left Column (Single Seats) 1 to 5
          Column(
            children: List.generate(5, (index) {
              return _buildSleeperSeat('$prefixL${index + 1}');
            }),
          ),

          // Right Column (Double Seats)
          Row(
            children: [
              // Inner Column 1 to 5
              Column(
                children: List.generate(5, (index) {
                  return _buildSleeperSeat('$prefixR${index + 1}');
                }),
              ),
              const SizedBox(width: 10),
              // Outer Column 6 to 10
              Column(
                children: List.generate(5, (index) {
                  return _buildSleeperSeat('$prefixR${index + 6}');
                }),
              ),
            ],
          ),
        ],
      );
    });
  }

  Widget _buildSleeperSeat(String seatId) {
    return Obx(() {
      final isBooked = controller.bookedSeats.contains(seatId);
      final isSelected = controller.selectedSeats.contains(seatId);

      Color bgColor = AppColors.white;
      Color borderColor = AppColors.secondaryGreyBlue.withOpacity(0.5);
      Color textColor = AppColors.secondaryGreyBlue;

      if (isBooked) {
        bgColor = AppColors.secondaryGreyBlue.withOpacity(0.15);
        borderColor = Colors.transparent;
        textColor = AppColors.secondaryGreyBlue.withOpacity(0.5);
      } else if (isSelected) {
        bgColor = AppColors.primaryAccent.withOpacity(0.1);
        borderColor = AppColors.primaryAccent;
        textColor = AppColors.primaryAccent;
      }

      return GestureDetector(
        onTap: () => controller.toggleSeat(seatId),
        child: Container(
          width: 50,
          height: 80,
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
          ),
          child: Stack(
            children: [
              Center(
                child: Text(
                  seatId,
                  style: AppTextStyles.caption.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (isSelected)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.primaryAccent,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: AppColors.white,
                      size: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }

  // --- Draggable Slider Widgets ---

  Widget _buildDraggableSlider() {
    return DraggableScrollableSheet(
      initialChildSize: 0.15, // Starts small at the bottom
      minChildSize: 0.15, // Minimum height
      maxChildSize: 0.6, // Expands up to 60% of the screen
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.secondaryGreyBlue.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: ListView(
            controller: scrollController,
            // Important: Links the drag gesture to this list
            padding: EdgeInsets.zero,
            children: [
              // 1. Drag Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 16),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.secondaryGreyBlue.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              // 2. Tabs Row
              _buildSliderTabs(),
              Divider(
                color: AppColors.secondaryGreyBlue.withOpacity(0.2),
                height: 1,
              ),

              // 3. Tab Content
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Obx(() {
                  switch (controller.selectedTab.value) {
                    case 'Bus Info':
                      return _buildBusInfoContent();
                    case 'Boarding':
                      return _buildBoardingContent();
                    case 'Dropping':
                      return _buildDroppingContent();
                    case 'Rest Stops':
                      return _buildRestStopsContent();
                    case 'Rating':
                      return _buildRatingContent();
                    default:
                      return _buildBusInfoContent();
                  }
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSliderTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: controller.bottomTabs.map((tab) {
          return Obx(() {
            final isSelected = controller.selectedTab.value == tab;
            return GestureDetector(
              onTap: () => controller.selectTab(tab),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected
                          ? AppColors.primaryAccent
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  tab,
                  style: AppTextStyles.caption.copyWith(
                    color: isSelected
                        ? AppColors.primaryAccent
                        : AppColors.secondaryGreyBlue,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ),
            );
          });
        }).toList(),
      ),
    );
  }

  Widget _buildBusInfoContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Amenities Grid
        Row(
          children: [
            Expanded(child: _amenityItem(Icons.wifi, 'Free Wi-Fi')),
            Expanded(
              child: _amenityItem(Icons.electrical_services, 'Charging Point'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _amenityItem(Icons.ac_unit, 'Central A/C')),
            Expanded(
              child: _amenityItem(Icons.water_drop_outlined, 'Water Bottle'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Divider(color: AppColors.secondaryGreyBlue.withOpacity(0.2)),
        const SizedBox(height: 16),
        
        // Dynamic Driver & Bus Specifics
        Text(
          'Driver & Bus Details',
          style: AppTextStyles.h3.copyWith(fontSize: 16),
        ),
        const SizedBox(height: 12),
        
        Obx(() => _buildInfoRow(Icons.person_outline, 'Driver Name', controller.driverName.value)),
        const SizedBox(height: 10),
        Obx(() => _buildInfoRow(Icons.phone_outlined, 'Contact Number', controller.driverMobile.value)),
        const SizedBox(height: 10),
        Obx(() => _buildInfoRow(Icons.directions_bus_outlined, 'Bus License Plate', controller.busNumber.value)),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.secondaryGreyBlue),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.secondaryGreyBlue,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.primaryDark,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _amenityItem(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryAccent, size: 20),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  // --- Dynamic Tab Display Widgets ---

  Widget _buildPointList(List<Map<String, dynamic>> points, String titleKey, String subtitleKey, IconData icon) {
    if (points.isEmpty) {
      return Text('No details found.', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.secondaryGreyBlue));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: points.length,
      itemBuilder: (context, index) {
        final pt = points[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: AppColors.primaryAccent, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pt[titleKey]?.toString() ?? 'Unknown',
                      style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      pt[subtitleKey]?.toString() ?? '--',
                      style: AppTextStyles.caption.copyWith(color: AppColors.secondaryGreyBlue),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBoardingContent() => _buildPointList(controller.boardingPoints, 'pointName', 'time', Icons.my_location);

  Widget _buildDroppingContent() => _buildPointList(controller.droppingPoints, 'pointName', 'time', Icons.location_on_outlined);

  Widget _buildRestStopsContent() => _buildPointList(controller.restStops, 'stopName', 'duration', Icons.restaurant_menu);

  Widget _buildRatingContent() =>
      Text('4.2/5 based on 124 user reviews.', style: AppTextStyles.bodyMedium);

  // --- Bottom Action Bar ---

  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryGreyBlue.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Obx(() {
          final hasSelection = controller.selectedSeats.isNotEmpty;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Selection Info Row
              if (hasSelection)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SELECTED SEATS',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.secondaryGreyBlue,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          RichText(
                            text: TextSpan(
                              text: controller.selectedSeats.join(', '),
                              style: AppTextStyles.h3.copyWith(
                                color: AppColors.primaryDark,
                              ),
                              children: [
                                TextSpan(
                                  text:
                                      '  |  ₹${controller.totalPrice.toInt()}',
                                  style: AppTextStyles.h3.copyWith(
                                    color: AppColors.primaryDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      // Small seat circle badge
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.lightBackground,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          controller.selectedSeats.first,
                          style: AppTextStyles.caption.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Proceed Button
              ElevatedButton(
                onPressed: hasSelection
                    ? controller.proceedToPay
                    : () =>
                          Get.snackbar('Notice', 'Please select a seat first.'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: hasSelection
                      ? AppColors.primaryAccent
                      : AppColors.secondaryGreyBlue.withOpacity(0.3),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: hasSelection ? 4 : 0,
                ),
                child: Text('Proceed to Pay', style: AppTextStyles.buttonText),
              ),
            ],
          );
        }),
      ),
    );
  }
}
