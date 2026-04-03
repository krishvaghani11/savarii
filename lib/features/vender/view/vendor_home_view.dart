import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:savarii/core/theme/app_colors.dart';
import 'package:savarii/core/theme/app_text_styles.dart';
import 'package:savarii/core/utils/locale_utils.dart';
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
                    'home.todays_summary'.tr(),
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
              Obx(() => Row(
                children: [
                  Expanded(
                      child: _buildSummaryCard(
                        Icons.directions_bus,
                        LocaleUtils.formatCount(context, int.tryParse(controller.activeBuses.value) ?? 0),
                        'home.buses_active'.tr(),
                      ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _buildSummaryCard(
                        Icons.confirmation_num,
                        LocaleUtils.formatCount(context, int.tryParse(controller.ticketsSold.value) ?? 0),
                        'home.tickets_sold'.tr(),
                      ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _buildSummaryCard(
                        Icons.payments,
                        LocaleUtils.formatCurrency(context, controller.totalEarnings.value),
                        'home.earnings'.tr(),
                      ),
                  ),
                ],
              )),
              const SizedBox(height: 24),

              // 3. Main Options
              Text(
                'home.main_options'.tr(),
                style: AppTextStyles.h3.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 16),
              _buildOptionCard(
                Icons.add_road,
                'home.add_bus_route'.tr(),
                'home.add_bus_subtitle'.tr(),
                controller.addBusAndRoute,
              ),
              const SizedBox(height: 12),
              _buildOptionCard(
                Icons.local_activity,
                'home.view_tickets'.tr(),
                'home.view_tickets_subtitle'.tr(),
                controller.viewBusTickets,
              ),
              const SizedBox(height: 12),
              _buildOptionCard(
                Icons.event_seat,
                'home.book_ticket'.tr(),
                'home.book_ticket_subtitle'.tr(),
                controller.bookTicket,
              ),
              const SizedBox(height: 12),
              _buildOptionCard(
                Icons.map,
                'home.bus_tracking'.tr(),
                'home.bus_tracking_subtitle'.tr(),
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
                'home.welcome_back'.tr(),
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
                'Daily Tickets',
                style: AppTextStyles.h3.copyWith(fontSize: 16),
              ),
              GestureDetector(
                onTap: controller.viewBusTickets,
                child: Text(
                  'home.details'.tr(),
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primaryAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 180,
            child: Obx(() {
              final totals = controller.weeklyTicketCounts;
              
              // Find max count to scale Y-axis properly
              final maxTickets = totals.isEmpty ? 0 : totals.reduce((a, b) => a > b ? a : b);
              final yMax = (maxTickets > 5 ? maxTickets.toDouble() + 2 : 5.0);

              return BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceEvenly,
                  maxY: yMax,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) => AppColors.primaryAccent,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '${rod.toY.toInt()} Tickets\n',
                          const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx > 6) return const SizedBox.shrink();
                          // Calculate date for this bar
                          final daysAgo = 6 - idx;
                          final date = DateTime.now().subtract(Duration(days: daysAgo));
                          final dayStr = "${date.day} ${_getMonthShort(date.month)}";
                          
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              dayStr,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.secondaryGreyBlue,
                                fontSize: 10,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          if (value == 0 || value % 1 != 0) return const SizedBox.shrink();
                          return Text(
                            value.toInt().toString(),
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.secondaryGreyBlue,
                              fontSize: 10,
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: yMax / 5 > 0 ? yMax / 5 : 1,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: AppColors.secondaryGreyBlue.withOpacity(0.1),
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(7, (i) {
                    final isToday = i == 6;
                    return BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: totals.length > i ? totals[i].toDouble() : 0.0,
                          color: isToday
                              ? AppColors.primaryAccent
                              : AppColors.primaryAccent.withOpacity(0.4),
                          width: 16,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    );
                  }),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  String _getMonthShort(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}
