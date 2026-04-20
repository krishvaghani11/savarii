import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:savarii/core/theme/app_colors.dart';
import 'package:savarii/core/theme/app_text_styles.dart';
import 'package:savarii/features/driver/controller/driver_home_controller.dart';

class DriverHomeView extends GetView<DriverHomeController> {
  const DriverHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9), // Light greyish background
      body: SafeArea(
        child: Column(
          children: [
            // 1. Custom App Bar / Header
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Savarii',
                    style: AppTextStyles.h2.copyWith(
                      color: AppColors.primaryAccent,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 2. Greeting & Status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Obx(
                                () => Text(
                                  'Hello, ${controller.rxDriverName.value}!',
                                  style: AppTextStyles.h1.copyWith(
                                    fontSize: 28,
                                    color: const Color(0xFF2A2D3E),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Ready for your shift?',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.secondaryGreyBlue,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Obx(() => _buildStatusBadge()),
                      ],
                    ),
                    const SizedBox(height: 24),

                    Obx(() {
                      if (controller.isLoading.value) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      if (!controller.hasBusAssigned.value) {
                        return _buildEmptyBusCard();
                      }
                      return _buildAssignedBusCard();
                    }),
                    const SizedBox(height: 20),

                    Obx(
                      () => _buildInfoCard(
                        icon: Icons.history,
                        title: 'Last Trip',
                        value: controller.lastTrip.value,
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Sub-Widgets ---

  Widget _buildStatusBadge() {
    bool isOnline = controller.isOnline.value;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isOnline
            ? Colors.green.shade50
            : AppColors.secondaryGreyBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isOnline
                  ? Colors.green.shade600
                  : AppColors.secondaryGreyBlue,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isOnline ? 'ONLINE' : 'OFFLINE',
            style: AppTextStyles.caption.copyWith(
              color: isOnline
                  ? Colors.green.shade700
                  : AppColors.secondaryGreyBlue,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyBusCard() {
    return Container(
      padding: const EdgeInsets.all(32.0),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryGreyBlue.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.directions_bus_filled_outlined,
            size: 48,
            color: AppColors.secondaryGreyBlue,
          ),
          const SizedBox(height: 16),
          Text(
            "No Bus Assigned",
            style: AppTextStyles.h2.copyWith(color: AppColors.primaryDark),
          ),
          const SizedBox(height: 8),
          Text(
            "Please wait for your vendor to assign a bus to you.",
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.secondaryGreyBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignedBusCard() {
    return GestureDetector(
      onTap: controller.goToBusDetails,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24),
          border: const Border(
            top: BorderSide(
              color: AppColors.primaryAccent,
              width: 4,
            ), // Top red accent line
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondaryGreyBlue.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Row: Title, Bus Name & Icon
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ASSIGNED BUS',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primaryAccent,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          controller.rxBusName.value,
                          style: AppTextStyles.h2.copyWith(
                            fontSize: 20,
                            color: const Color(0xFF2A2D3E),
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryGreyBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            controller.rxBusNumber.value,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.primaryDark,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryAccent.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.directions_bus,
                      color: AppColors.primaryAccent,
                      size: 28,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Timeline Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dots and Lines
                  Column(
                    children: [
                      const SizedBox(height: 4),
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primaryAccent,
                            width: 2,
                          ),
                        ),
                      ),
                      Container(
                        height: 35,
                        width: 1.5,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: CustomPaint(painter: DottedLinePainter()),
                      ),
                      const Icon(
                        Icons.circle,
                        color: AppColors.primaryAccent,
                        size: 12,
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),

                  // Locations
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          controller.rxStartLocation.value,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2A2D3E),
                          ),
                        ),
                        const SizedBox(height: 35), // Spacing to match timeline
                        Text(
                          controller.rxEndLocation.value,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2A2D3E),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Times
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        controller.rxStartTime.value,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.secondaryGreyBlue,
                        ),
                      ),
                      const SizedBox(height: 35), // Spacing to match timeline
                      Text(
                        controller.rxEndTime.value,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.secondaryGreyBlue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Reporting Time & Vendor
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Reporting Time',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.secondaryGreyBlue,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          controller.rxReportingTime.value,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2A2D3E),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bus Number',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.secondaryGreyBlue,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          controller.rxBusNumber.value,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2A2D3E),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Activate Button
              Obx(
                () => ElevatedButton.icon(
                  onPressed: controller.toggleStatus,
                  icon: Icon(
                    controller.isOnline.value
                        ? Icons.stop_circle_outlined
                        : Icons.bolt,
                    color: AppColors.white,
                    size: 20,
                  ),
                  label: Text(
                    controller.isOnline.value ? 'End Shift' : 'Activate Bus',
                    style: AppTextStyles.buttonText.copyWith(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: controller.isOnline.value
                        ? const Color(0xFF2A2D3E)
                        : AppColors.primaryAccent,
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        20,
                      ), // Pill/Rounded shape
                    ),
                    elevation: 4,
                    shadowColor:
                        (controller.isOnline.value
                                ? const Color(0xFF2A2D3E)
                                : AppColors.primaryAccent)
                            .withOpacity(0.4),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.secondaryGreyBlue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.secondaryGreyBlue, size: 20),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.secondaryGreyBlue,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2A2D3E),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Custom Painter for the dotted vertical line in the timeline
class DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double dashHeight = 4, dashSpace = 4, startY = 0;
    final paint = Paint()
      ..color = AppColors.secondaryGreyBlue.withOpacity(0.3)
      ..strokeWidth = 1.5;
    while (startY < size.height) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashHeight), paint);
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
