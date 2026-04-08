import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:savarii/core/theme/app_colors.dart';
import 'package:savarii/core/theme/app_text_styles.dart';
import 'package:savarii/features/customer/home/controller/search_results_controller.dart';
import 'package:savarii/models/bus_model.dart';

class SearchResultsView extends GetView<SearchResultsController> {
  const SearchResultsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: _buildAppBar(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primaryAccent));
        }

        if (controller.buses.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.search_off, size: 64, color: AppColors.secondaryGreyBlue),
                const SizedBox(height: 16),
                Text('No buses found for this route', style: AppTextStyles.h3),
                const SizedBox(height: 8),
                Text('Try a different date or route', style: AppTextStyles.bodyMedium),
              ],
            ),
          );
        }

        return Column(
          children: [
            // 1. Date Selector Strip
            _buildDateSelector(),
            const SizedBox(height: 16),

            // 2. Filter Strip
            _buildFilterStrip(),
            const SizedBox(height: 16),

            // 3. Scrollable Content (Bus List + Banner)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    // List Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Showing ${controller.buses.length} buses',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.secondaryGreyBlue,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              'Sort by: Price',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.primaryAccent,
                              ),
                            ),
                            const Icon(
                              Icons.keyboard_arrow_down,
                              color: AppColors.primaryAccent,
                              size: 16,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Bus Cards List
                    ...controller.buses.map((bus) => _buildBusCard(bus)),

                    const SizedBox(height: 16),

                    // Promo Banner
                    _buildPromoBanner(),

                    const SizedBox(height: 30), // Bottom padding
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  // --- Sub-Widgets ---

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.lightBackground,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.primaryDark),
        onPressed: () => Get.back(),
      ),
      centerTitle: true,
      title: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(controller.fromCity, style: AppTextStyles.h3),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Icon(
                  Icons.arrow_forward,
                  color: AppColors.primaryAccent,
                  size: 18,
                ),
              ),
              Text(controller.toCity, style: AppTextStyles.h3),
            ],
          ),
          Text(
            controller.travelDetails,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.secondaryGreyBlue,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.tune, color: AppColors.primaryDark),
          onPressed: () {}, // Open detailed filters
        ),
      ],
    );
  }

  Widget _buildDateSelector() {
    // Dummy dates for the top bar
    final dates = [
      {'day': 'Tue', 'date': '14'},
      {'day': 'Wed', 'date': '15'},
      {'day': 'Thu', 'date': '16'},
      {'day': 'Fri', 'date': '17'},
      {'day': 'Sat', 'date': '18'},
    ];

    return SizedBox(
      height: 70,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: dates.length,
        itemBuilder: (context, index) {
          return Obx(() {
            final isSelected = controller.selectedDateIndex.value == index;
            return GestureDetector(
              onTap: () => controller.selectDate(index),
              child: Container(
                width: 60,
                margin: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryAccent : AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primaryAccent.withValues(alpha: 0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: AppColors.secondaryGreyBlue.withValues(alpha: 0.05),
                            blurRadius: 5,
                          ),
                        ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      dates[index]['day']!,
                      style: AppTextStyles.caption.copyWith(
                        color: isSelected
                            ? AppColors.white.withValues(alpha: 0.9)
                            : AppColors.secondaryGreyBlue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dates[index]['date']!,
                      style: AppTextStyles.h3.copyWith(
                        color: isSelected
                            ? AppColors.white
                            : AppColors.primaryDark,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            );
          });
        },
      ),
    );
  }

  Widget _buildFilterStrip() {
    final filters = [
      {'label': 'AC', 'icon': Icons.ac_unit},
      {'label': 'Sleeper', 'icon': Icons.airline_seat_flat},
      {'label': 'Seater', 'icon': Icons.airline_seat_recline_normal},
      {'label': 'Top Rated', 'icon': Icons.star},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: filters.map((f) {
          return Obx(() {
            final isSelected = controller.selectedFilter.value == f['label'];
            return GestureDetector(
              onTap: () => controller.selectFilter(f['label'] as String),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryAccent.withValues(alpha: 0.1)
                      : AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryAccent
                        : AppColors.secondaryGreyBlue.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      f['icon'] as IconData,
                      size: 16,
                      color: isSelected
                          ? AppColors.primaryAccent
                          : AppColors.secondaryGreyBlue,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      f['label'] as String,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isSelected
                            ? AppColors.primaryAccent
                            : AppColors.secondaryGreyBlue,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          });
        }).toList(),
      ),
    );
  }

  Widget _buildBusCard(BusModel bus) {
    return Obx(() {
      final availability = controller.seatAvailabilityMap[bus.id];
      final booked = availability?['booked'] ?? 0;
      final available = availability?['available'] ?? 0;

      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondaryGreyBlue.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Row 1: Icon, Name, Rating, Price
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bus Icon
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryAccent.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.directions_bus,
                    color: AppColors.primaryAccent,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),

                // Name & Rating
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bus.busName,
                        style: AppTextStyles.h3.copyWith(fontSize: 16),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  '4.5',
                                  style: AppTextStyles.caption.copyWith(
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 2),
                                Icon(
                                  Icons.star,
                                  color: Colors.green.shade700,
                                  size: 12,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '(120 ratings)',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.secondaryGreyBlue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Pricing
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${bus.price}',
                      style: AppTextStyles.h3.copyWith(
                        color: AppColors.primaryAccent,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Row 2: Timeline
            Row(
              children: [
                // Departure
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bus.departureTime,
                      style: AppTextStyles.h3.copyWith(fontSize: 16),
                    ),
                    Text(
                      controller.fromCity,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.secondaryGreyBlue,
                      ),
                    ),
                  ],
                ),

                // Center Dotted Line with Duration
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        Text(
                          'Estimated',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.secondaryGreyBlue,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: AppColors.secondaryGreyBlue.withValues(alpha: 0.5),
                                shape: BoxShape.circle,
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                child: CustomPaint(
                                  size: const Size(double.infinity, 1),
                                  painter: DottedLinePainter(),
                                ),
                              ),
                            ),
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: AppColors.secondaryGreyBlue.withValues(alpha: 0.5),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Arrival
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      bus.arrivalTime,
                      style: AppTextStyles.h3.copyWith(fontSize: 16),
                    ),
                    Text(
                      controller.toCity,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.secondaryGreyBlue,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),
            Divider(
              color: AppColors.secondaryGreyBlue.withValues(alpha: 0.1),
              height: 1,
            ),
            const SizedBox(height: 16),

            // Row 3: Bottom Action
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.airline_seat_recline_normal,
                      color: AppColors.secondaryGreyBlue,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$available seats available • $booked booked',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.secondaryGreyBlue,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () => controller.bookBus(bus),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryAccent,
                    minimumSize: const Size(0, 0),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: Text('Select', style: AppTextStyles.buttonText),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildPromoBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryAccent,
            Colors.pinkAccent.shade200,
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryAccent.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Get 20% OFF',
                style: AppTextStyles.h2.copyWith(color: AppColors.white),
              ),
              const SizedBox(height: 4),
              Text(
                'Use code SAVARII20',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_forward, color: AppColors.white),
          ),
        ],
      ),
    );
  }
}

class DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double dashWidth = 3, dashSpace = 3, startX = 0;
    final paint = Paint()
      ..color = AppColors.secondaryGreyBlue.withValues(alpha: 0.3)
      ..strokeWidth = 1;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
