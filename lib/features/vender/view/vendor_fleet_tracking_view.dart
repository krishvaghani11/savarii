import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:savarii/core/constants/app_assets.dart';
import 'package:savarii/core/theme/app_colors.dart';
import 'package:savarii/core/theme/app_text_styles.dart';
import '../controllers/vendor_fleet_tracking_controller.dart';

class VendorFleetTrackingView extends GetView<VendorFleetTrackingController> {
  const VendorFleetTrackingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      // The AppBar is white and sits above the map
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryDark),
          onPressed: () => Get.back(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Live Fleet Tracking',
              style: AppTextStyles.h3.copyWith(fontSize: 18),
            ),
            Text(
              '8 Buses Active • 2 Delayed',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.secondaryGreyBlue,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: controller.openOptions,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryAccent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.filter_list,
                  color: AppColors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // 1. Zoomable Map Background
          Positioned.fill(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.asset(
                AppAssets.locationMapImage2,
                // Ensure you have your map image in AppAssets
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFFE8ECEF),
                  child: const Center(
                    child: Icon(Icons.map, size: 100, color: Colors.grey),
                  ),
                ),
              ),
            ),
          ),

          // 2. Search Bar Overlay
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: controller.searchController,
                decoration: InputDecoration(
                  hintText: 'Search bus ID, driver or route...',
                  hintStyle: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.secondaryGreyBlue,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.secondaryGreyBlue,
                  ),
                  suffixIcon: const Icon(
                    Icons.mic,
                    color: AppColors.secondaryGreyBlue,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ),

          // 3. Map Controls (Right Side)
          Positioned(
            right: 16,
            top: 180, // Positioned above the bottom sheet
            child: Column(
              children: [
                _buildFloatingButton(Icons.my_location, controller.recenterMap),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.add,
                          color: AppColors.primaryDark,
                        ),
                        onPressed: controller.zoomIn,
                      ),
                      Container(
                        height: 1,
                        width: 30,
                        color: Colors.grey.shade300,
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.remove,
                          color: AppColors.primaryDark,
                        ),
                        onPressed: controller.zoomOut,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 4. Draggable Bottom Sheet (Bus List)
          DraggableScrollableSheet(
            initialChildSize: 0.45,
            minChildSize: 0.2,
            maxChildSize: 0.85,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.lightBackground,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Drag Handle & Filters (Fixed at top of sheet)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                      child: Column(
                        children: [
                          Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Obx(
                            () => Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: _buildFilterChip(
                                    'All Active (8)',
                                    'All Active',
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildFilterChip(
                                    'Delayed (2)',
                                    'Delayed',
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildFilterChip(
                                    'In Transit (6)',
                                    'In Transit',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Scrollable List of Buses
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemCount: controller.fleet.length,
                        itemBuilder: (context, index) =>
                            _buildBusCard(controller.fleet[index]),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // --- Sub-Widgets ---

  Widget _buildFloatingButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: AppColors.primaryDark, size: 20),
      ),
    );
  }

  Widget _buildFilterChip(String label, String filterValue) {
    bool isSelected = controller.selectedFilter.value == filterValue;
    return GestureDetector(
      onTap: () => controller.setFilter(filterValue),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryAccent : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryAccent
                : AppColors.secondaryGreyBlue.withOpacity(0.2),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: isSelected ? AppColors.white : AppColors.secondaryGreyBlue,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBusCard(FleetBusModel bus) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.secondaryGreyBlue.withOpacity(0.15),
        ),
      ),
      child: Row(
        children: [
          // Icon Container
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bus.isDelayed
                  ? Colors.orange.withOpacity(0.1)
                  : AppColors.primaryAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              bus.isDelayed
                  ? Icons.warning_amber_rounded
                  : Icons.directions_bus,
              color: bus.isDelayed ? Colors.orange : AppColors.primaryAccent,
            ),
          ),
          const SizedBox(width: 16),

          // Bus Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      bus.id,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: bus.isDelayed
                            ? Colors.orange.withOpacity(0.1)
                            : const Color(0xFFE8F8F0),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        bus.status,
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: bus.isDelayed
                              ? Colors.orange.shade800
                              : const Color(0xFF00A65A),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Next Stop: ${bus.nextStop}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.secondaryGreyBlue,
                  ),
                ),
              ],
            ),
          ),

          // Speed Info
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    bus.speed,
                    style: AppTextStyles.h2.copyWith(fontSize: 20),
                  ),
                  Text(
                    ' km/h',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.secondaryGreyBlue,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                bus.condition,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.secondaryGreyBlue,
                  fontSize: 8,
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
