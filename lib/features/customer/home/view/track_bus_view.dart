import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:savarii/core/constants/app_assets.dart';
import 'package:savarii/core/theme/app_colors.dart';
import 'package:savarii/core/theme/app_text_styles.dart';
import 'package:savarii/features/customer/home/controller/track_bus_controller.dart';

class TrackBusView extends GetView<TrackBusController> {
  const TrackBusView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      // We use a Stack to layer the UI over the map
      body: Stack(
        children: [
          // 1. The Zoomable Map Background
          Positioned.fill(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.asset(
                AppAssets.mapImage,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFFE8ECEF), // Map-like grey color
                  child: const Center(
                    child: Icon(Icons.map, size: 100, color: Colors.grey),
                  ),
                ),
              ),
            ),
          ),

          // 2. Top App Bar & Search
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Column(
                children: [
                  // Top Row (Back, Title, Share)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildFloatingButton(Icons.arrow_back, () => Get.back()),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Bus Tracking',
                          style: AppTextStyles.h3.copyWith(fontSize: 16),
                        ),
                      ),
                      _buildFloatingButton(
                        Icons.share,
                        controller.shareLiveLocation,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: controller.searchController,
                      decoration: InputDecoration(
                        hintText: 'Search destination',
                        hintStyle: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.secondaryGreyBlue,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: AppColors.primaryAccent,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Right Side Map Controls (Zoom & Location)
          Positioned(
            right: 16,
            top: 200,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: controller.zoomIn,
                      ),
                      Container(
                        height: 1,
                        width: 30,
                        color: Colors.grey.shade300,
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: controller.zoomOut,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildFloatingButton(
                  Icons.my_location,
                  controller.recenterMap,
                  color: AppColors.primaryAccent,
                ),
              ],
            ),
          ),

          // 4. Movable Bottom Sheet (DraggableScrollableSheet)
          DraggableScrollableSheet(
            initialChildSize: 0.35, // Starts partially open
            minChildSize: 0.15, // How far it can slide down
            maxChildSize: 0.85, // How far it can slide up
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: CustomScrollView(
                  controller: scrollController,
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Drag Handle
                            Center(
                              child: Container(
                                width: 40,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Header Status
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'ON ITS WAY',
                                      style: AppTextStyles.caption.copyWith(
                                        color: AppColors.primaryAccent,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      controller.status,
                                      style: AppTextStyles.h2,
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Next Stop',
                                      style: AppTextStyles.caption.copyWith(
                                        color: AppColors.secondaryGreyBlue,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      controller.nextStop,
                                      style: AppTextStyles.bodyLarge.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Driver Info Card
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.lightBackground,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 24,
                                    backgroundColor: Colors.teal.shade300,
                                    child: const Icon(
                                      Icons.person,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              controller.driverName,
                                              style: AppTextStyles.bodyLarge
                                                  .copyWith(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                            const SizedBox(width: 8),
                                            const Icon(
                                              Icons.star,
                                              color: Colors.orange,
                                              size: 14,
                                            ),
                                            Text(
                                              controller.driverRating,
                                              style: AppTextStyles.caption
                                                  .copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          controller.driverPhone,
                                          style: AppTextStyles.bodyMedium
                                              .copyWith(
                                                color: AppColors.primaryAccent,
                                              ),
                                        ),
                                        Text(
                                          'Bus: ${controller.busNumber}',
                                          style: AppTextStyles.caption.copyWith(
                                            color: AppColors.secondaryGreyBlue,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Call Button
                                  GestureDetector(
                                    onTap: controller.callDriver,
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: const BoxDecoration(
                                        color: AppColors.primaryAccent,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.phone,
                                        color: AppColors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Upcoming Stops Timeline
                            Text(
                              'UPCOMING STOPS',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.secondaryGreyBlue,
                                letterSpacing: 1,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),

                            _buildTimelineStop(
                              'Central Station',
                              'Departed',
                              isPast: true,
                            ),
                            _buildTimelineStop(
                              'MG Road',
                              'On Time',
                              isCurrent: true,
                            ),
                            _buildTimelineStop(
                              'Indiranagar',
                              '6:45 PM',
                              isFuture: true,
                              isLast: true,
                            ),

                            const SizedBox(height: 32),

                            // Share Location Button
                            ElevatedButton.icon(
                              onPressed: controller.shareLiveLocation,
                              icon: const Icon(
                                Icons.my_location,
                                color: AppColors.white,
                                size: 18,
                              ),
                              label: Text(
                                'Share Live Location',
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
                          ],
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

  Widget _buildFloatingButton(
    IconData icon,
    VoidCallback onTap, {
    Color color = AppColors.primaryDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }

  Widget _buildTimelineStop(
    String title,
    String time, {
    bool isPast = false,
    bool isCurrent = false,
    bool isFuture = false,
    bool isLast = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: isPast
                      ? AppColors.secondaryGreyBlue
                      : isCurrent
                          ? AppColors.primaryAccent
                          : AppColors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isFuture
                        ? AppColors.secondaryGreyBlue.withValues(alpha: 0.3)
                        : isCurrent
                            ? AppColors.primaryAccent
                            : AppColors.secondaryGreyBlue,
                    width: 2,
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isPast
                        ? AppColors.secondaryGreyBlue.withValues(alpha: 0.3)
                        : AppColors.secondaryGreyBlue.withValues(alpha: 0.1),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Stop details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: isFuture
                          ? AppColors.secondaryGreyBlue.withValues(alpha: 0.7)
                          : AppColors.primaryDark,
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                  Text(
                    time,
                    style: AppTextStyles.caption.copyWith(
                      color: isCurrent
                          ? AppColors.primaryAccent
                          : AppColors.secondaryGreyBlue,
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
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
}
