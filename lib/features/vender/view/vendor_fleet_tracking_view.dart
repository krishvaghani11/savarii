import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:savarii/core/theme/app_colors.dart';
import 'package:savarii/core/theme/app_text_styles.dart';
import 'package:savarii/core/utils/locale_utils.dart';
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
              'tracking.title'.tr(),
              style: AppTextStyles.h3.copyWith(fontSize: 18),
            ),
            Text(
              'tracking.buses_active'.tr(),
              style: AppTextStyles.caption.copyWith(
                color: AppColors.secondaryGreyBlue,
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // 1. Zoomable Map Background
          Positioned.fill(
            child: Obx(
              () => GoogleMap(
                onMapCreated: controller.onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: controller.busPosition.value,
                  zoom: 15.0,
                ),
                markers: controller.markers,
                myLocationEnabled: false,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                compassEnabled: true,
                mapToolbarEnabled: false,
                trafficEnabled: false,
                buildingsEnabled: true,
                mapType: MapType.normal,
              ),
            ),
          ),

          // 3. Map Controls (Right Side)
          Positioned(
            right: 16,
            top: 16, // Positioned at the top right
            child: Column(
              children: [
                _buildFloatingButton(Icons.my_location, controller.recenterMap),
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
                                  child: _buildFilterChip('Active', 'Active'),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildFilterChip(
                                    'Is Running',
                                    'Is Running',
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildFilterChip('Offline', 'Offline'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Scrollable List of Buses
                    Expanded(
                      child: Obx(
                        () => ListView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          itemCount: controller.fleet.length,
                          itemBuilder: (context, index) =>
                              _buildBusCard(context, controller.fleet[index]),
                        ),
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

  Widget _buildBusCard(BuildContext context, FleetBusModel bus) {
    return Obx(
      () => GestureDetector(
        onTap: () => controller.selectBus(bus.id),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: controller.selectedBusId.value == bus.id
                ? AppColors.primaryAccent.withOpacity(0.05)
                : AppColors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: controller.selectedBusId.value == bus.id
                  ? AppColors.primaryAccent
                  : AppColors.secondaryGreyBlue.withOpacity(0.15),
              width: controller.selectedBusId.value == bus.id ? 2 : 1,
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
                  color: bus.isDelayed
                      ? Colors.orange
                      : AppColors.primaryAccent,
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
                        Flexible(
                          child: Text(
                            bus.busNumber,
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
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
                    const SizedBox(height: 4),
                    Text(
                      bus.driverName,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      bus.driverPhone,
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        LocaleUtils.formatNumber(context, bus.speed),
                        style: AppTextStyles.h2.copyWith(
                          fontSize: 20,
                          height: 1.0,
                        ),
                      ),
                      Text(
                        'tracking.speed_unit'.tr(),
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.secondaryGreyBlue,
                          fontSize: 10,
                          height: 1.0,
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
        ),
      ),
    );
  }
}
