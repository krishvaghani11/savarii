import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:savarii/core/theme/app_colors.dart';
import 'package:savarii/core/theme/app_text_styles.dart';
import 'package:savarii/features/vender/home/widgets/vendor_drawer.dart';

import '../controllers/vendor_home_controller.dart';

class VendorHomeView extends GetView<VendorHomeController> {
  const VendorHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      // 1. ATTACH THE DRAWER TO THE SCAFFOLD
      drawer: const VendorDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // 2. USE A BUILDER TO GET THE SCAFFOLD CONTEXT TO OPEN THE DRAWER
        leading: Builder(
          builder: (context) => Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
            child: GestureDetector(
              onTap: () => Scaffold.of(context).openDrawer(),
              child: Obx(() {
                final imageUrl = controller.vendorProfileImageUrl.value;
                ImageProvider? imageProvider;
                if (imageUrl.isNotEmpty) {
                  imageProvider = NetworkImage(imageUrl);
                }

                return CircleAvatar(
                  backgroundColor: AppColors.primaryDark, // Dark circle
                  backgroundImage: imageProvider,
                  child: imageProvider == null
                      ? const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 20,
                        )
                      : null, // User Icon
                );
              }),
            ),
          ),
        ),
        title: Obx(() => Text(controller.vendorName, style: AppTextStyles.h3)),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications, color: AppColors.primaryDark),
                Positioned(
                  right: 2,
                  top: 2,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            onPressed: controller.openNotifications,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Red Welcome Card
              _buildWelcomeCard(),
              const SizedBox(height: 24),

              // 2. Today's Summary
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Today's Summary",
                    style: AppTextStyles.h3.copyWith(fontSize: 16),
                  ),
                  Text(
                    controller.date,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.secondaryGreyBlue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      Icons.directions_bus,
                      controller.activeBuses,
                      'Buses Active',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSummaryCard(
                      Icons.confirmation_num,
                      controller.ticketsSold,
                      'Tickets Sold',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSummaryCard(
                      Icons.payments,
                      controller.earnings,
                      'Earnings',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 3. Main Options
              Text(
                "Main Options",
                style: AppTextStyles.h3.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 16),
              _buildOptionCard(
                Icons.add_road,
                'Add Bus & Route',
                'Register new vehicles and schedules',
                controller.addBusAndRoute,
              ),
              const SizedBox(height: 12),
              _buildOptionCard(
                Icons.local_activity,
                'View Bus Tickets',
                'Manage bookings and passenger lists',
                controller.viewBusTickets,
              ),
              const SizedBox(height: 12),
              _buildOptionCard(
                Icons.event_seat,
                'Book Ticket',
                'Manual booking for counter walk-ins',
                controller.bookTicket,
              ),
              const SizedBox(height: 12),
              _buildOptionCard(
                Icons.map,
                'Bus Tracking',
                'Track your fleet in real-time',
                controller.busTracking,
              ),
              const SizedBox(height: 24),

              // 4. Weekly Performance Chart
              _buildWeeklyPerformanceCard(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // --- Sub-Widgets ---

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryAccent, Color(0xFFE82E59)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryAccent.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background Decorative Circles
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            right: 40,
            bottom: -40,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          // Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back,',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 4),
              Obx(() => Text(
                controller.vendorName,
                style: AppTextStyles.h1.copyWith(
                  color: Colors.white,
                  fontSize: 24,
                ),
              )),
              const SizedBox(height: 16),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primaryAccent, size: 24),
          const SizedBox(height: 12),
          Text(value, style: AppTextStyles.h2.copyWith(fontSize: 20)),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.secondaryGreyBlue,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: AppColors.primaryAccent, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.secondaryGreyBlue,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.secondaryGreyBlue),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyPerformanceCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Weekly Performance',
                style: AppTextStyles.h3.copyWith(fontSize: 16),
              ),
              Text(
                'Details',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primaryAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildChartBar('Mon', 40),
              _buildChartBar('Tue', 60),
              _buildChartBar('Wed', 45),
              _buildChartBar('Thu', 85),
              _buildChartBar('Fri', 100, isHighlight: true),
              _buildChartBar('Sat', 65),
              _buildChartBar('Sun', 55),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartBar(
    String day,
    double heightPercentage, {
    bool isHighlight = false,
  }) {
    // Arbitrary max height for the chart area
    const double maxBarHeight = 100.0;

    return Column(
      children: [
        Container(
          width: 30,
          height: (heightPercentage / 100) * maxBarHeight,
          decoration: BoxDecoration(
            color: isHighlight
                ? AppColors.primaryAccent
                : AppColors.primaryAccent.withOpacity(0.2),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          day,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.secondaryGreyBlue,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
