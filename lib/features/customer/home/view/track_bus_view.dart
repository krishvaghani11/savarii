import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:savarii/core/theme/app_colors.dart';
import 'package:savarii/core/theme/app_text_styles.dart';
import 'package:savarii/features/customer/home/controller/track_bus_controller.dart';

class TrackBusView extends GetView<TrackBusController> {
  const TrackBusView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: Stack(
        children: [
          // ── 1. Full-Screen Google Map ──────────────────────────────────────
          // Intentionally NOT inside Obx — the map itself is never rebuilt.
          // Only the marker set changes via markers.obs.
          _GoogleMapLayer(controller: controller),

          // ── 2. Top Bar ────────────────────────────────────────────────────
          _TopBar(controller: controller),

          // ── 3. Centre Status Overlay ──────────────────────────────────────
          _StatusOverlay(controller: controller),

          // ── 4. Recenter FAB ───────────────────────────────────────────────
          _RecenterFab(controller: controller),

          // ── 5. Bottom Info Panel ──────────────────────────────────────────
          _BottomPanel(controller: controller),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Google Map Layer
// ══════════════════════════════════════════════════════════════════════════════

class _GoogleMapLayer extends StatelessWidget {
  const _GoogleMapLayer({required this.controller});
  final TrackBusController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Only re-renders when markers set changes — not on every Obx rebuild
      return GoogleMap(
        onMapCreated: controller.onMapCreated,
        initialCameraPosition: CameraPosition(
          target: controller.busPosition.value,
          zoom: 15.0,
        ),
        markers: controller.markers,
        myLocationEnabled:
            false, // Disabled so it doesn't overlap with the bus marker during testing
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
        compassEnabled: true,
        mapToolbarEnabled: false,
        trafficEnabled: false,
        buildingsEnabled: true,
        mapType: MapType.normal,
      );
    });
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Top Bar
// ══════════════════════════════════════════════════════════════════════════════

class _TopBar extends StatelessWidget {
  const _TopBar({required this.controller});
  final TrackBusController controller;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Back button
            _FloatingIconButton(
              icon: Icons.arrow_back_rounded,
              onTap: () => Get.back(),
            ),

            // Title pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Obx(() {
                    final isActive =
                        controller.trackingStatus.value ==
                        TrackingStatus.active;
                    return Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isActive ? Colors.green : Colors.orange,
                        shape: BoxShape.circle,
                      ),
                    );
                  }),
                  const SizedBox(width: 8),
                  Text(
                    'Live Tracking',
                    style: AppTextStyles.h3.copyWith(fontSize: 15),
                  ),
                ],
              ),
            ),

            // Bus number badge
            Obx(() {
              final number = controller.busNumber.value;
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.10),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Text(
                  number.isEmpty ? '---' : number,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryAccent,
                    fontSize: 12,
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Status Overlay (centre of screen for non-active states)
// ══════════════════════════════════════════════════════════════════════════════

class _StatusOverlay extends StatelessWidget {
  const _StatusOverlay({required this.controller});
  final TrackBusController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final status = controller.trackingStatus.value;
      if (status == TrackingStatus.active || status == TrackingStatus.loading) {
        return const SizedBox.shrink();
      }

      IconData icon;
      String title;
      String subtitle;
      Color iconColor;

      switch (status) {
        case TrackingStatus.waitingForBus:
          icon = Icons.directions_bus_rounded;
          title = 'Waiting for Bus';
          subtitle =
              'The bus hasn\'t started yet.\nWe\'ll show location once it departs.';
          iconColor = Colors.orange;
          break;
        case TrackingStatus.paused:
          icon = Icons.pause_circle_outline_rounded;
          title = 'Tracking Paused';
          subtitle =
              'No location update for 2+ minutes.\nWaiting for signal...';
          iconColor = Colors.orange;
          break;
        case TrackingStatus.completed:
          icon = Icons.check_circle_outline_rounded;
          title = 'Trip Completed';
          subtitle = 'This journey has ended.';
          iconColor = Colors.green;
          break;
        case TrackingStatus.tripNotFound:
          icon = Icons.error_outline_rounded;
          title = 'Trip Not Found';
          subtitle = 'No active trip linked to this booking yet.';
          iconColor = Colors.red;
          break;
        default:
          return const SizedBox.shrink();
      }

      return Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.97),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 52, color: iconColor),
              const SizedBox(height: 16),
              Text(
                title,
                style: AppTextStyles.h3.copyWith(fontSize: 17),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.secondaryGreyBlue,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    });
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Recenter FAB
// ══════════════════════════════════════════════════════════════════════════════

class _RecenterFab extends StatelessWidget {
  const _RecenterFab({required this.controller});
  final TrackBusController controller;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 16,
      bottom: 300,
      child: _FloatingIconButton(
        icon: Icons.my_location_rounded,
        onTap: controller.recenterMap,
        color: AppColors.primaryAccent,
        iconColor: Colors.white,
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Bottom Info Panel (DraggableScrollableSheet)
// ══════════════════════════════════════════════════════════════════════════════

class _BottomPanel extends StatelessWidget {
  const _BottomPanel({required this.controller});
  final TrackBusController controller;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.30,
      minChildSize: 0.12,
      maxChildSize: 0.60,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(color: Colors.black12, blurRadius: 16, spreadRadius: 2),
            ],
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            physics: const ClampingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag Handle
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Status + Speed Row
                  Obx(
                    () => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Status Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: controller.isRunning
                                ? Colors.green.withValues(alpha: 0.12)
                                : Colors.orange.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: controller.isRunning
                                      ? Colors.green
                                      : Colors.orange,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                controller.statusLabel,
                                style: AppTextStyles.caption.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: controller.isRunning
                                      ? Colors.green.shade700
                                      : Colors.orange.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Speed
                        Text(
                          controller.trackingStatus.value ==
                                  TrackingStatus.active
                              ? '${controller.busSpeed.value.toStringAsFixed(0)} km/h'
                              : '-- km/h',
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryDark,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Last Updated
                  Obx(
                    () => Text(
                      'Updated: ${controller.lastUpdatedText.value}',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.secondaryGreyBlue,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  Divider(color: Colors.grey.shade100, thickness: 1.5),
                  const SizedBox(height: 16),

                  // Driver Info Card
                  _DriverInfoCard(controller: controller),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Driver Info Card
// ══════════════════════════════════════════════════════════════════════════════

class _DriverInfoCard extends StatelessWidget {
  const _DriverInfoCard({required this.controller});
  final TrackBusController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.lightBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          children: [
            // Driver avatar
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryAccent.withValues(alpha: 0.8),
                    AppColors.primaryAccent,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),

            // Driver details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.driverName.value.isEmpty
                        ? 'Driver'
                        : controller.driverName.value,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.directions_bus_rounded,
                        size: 13,
                        color: AppColors.secondaryGreyBlue,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        controller.busNumber.value.isEmpty
                            ? 'Loading...'
                            : controller.busNumber.value,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.secondaryGreyBlue,
                        ),
                      ),
                    ],
                  ),
                  if (controller.driverPhone.value.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      controller.driverPhone.value,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primaryAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Call Button
            GestureDetector(
              onTap: controller.callDriver,
              child: Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(
                  color: AppColors.primaryAccent,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.phone_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Shared Floating Icon Button
// ══════════════════════════════════════════════════════════════════════════════

class _FloatingIconButton extends StatelessWidget {
  const _FloatingIconButton({
    required this.icon,
    required this.onTap,
    this.color = Colors.white,
    this.iconColor = AppColors.primaryDark,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
    );
  }
}
