import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:savarii/features/customer/home/controller/bookings_controller.dart';
import 'package:savarii/features/customer/home/controller/main_layout_controller.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class BookingsView extends GetView<BookingsController> {
  const BookingsView({super.key});

  @override
  Widget build(BuildContext context) {
    // Fallback injection for isolated testing
    if (!Get.isRegistered<BookingsController>()) {
      Get.put(BookingsController());
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.lightBackground,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          centerTitle: true,
          title: Text('My Bookings', style: AppTextStyles.h3),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.primaryDark),
            onPressed: () {
              if (Get.isRegistered<MainLayoutController>()) {
                Get.find<MainLayoutController>().changeTab(0);
              } else {
                Get.back();
              }
            },
          ),
          bottom: TabBar(
            labelColor: AppColors.primaryDark,
            unselectedLabelColor: AppColors.secondaryGreyBlue,
            labelStyle: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: AppTextStyles.bodyLarge,
            indicatorColor: AppColors.primaryAccent,
            indicatorWeight: 3,
            tabs: const [
              Tab(text: 'Active'),
              Tab(text: 'Completed'),
              Tab(text: 'Cancelled'),
            ],
          ),
        ),
        body: Column(
          children: [
            // Date Selector Row
            _buildDateSelector(context),

            // Tab Views
            Expanded(
              child: TabBarView(
                children: [
                  _buildActiveTab(),
                  _buildCompletedTab(),
                  _buildCancelledTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------
  // Date Selector
  // -------------------------------------------------------

  Widget _buildDateSelector(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.only(top: 12, bottom: 12, left: 20, right: 16),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 66,
              child: Obx(() => ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: controller.dateList.length,
                itemBuilder: (context, index) {
                  final date = controller.dateList[index];
                  final isSelected =
                      controller.selectedDate.value.year == date.year &&
                      controller.selectedDate.value.month == date.month &&
                      controller.selectedDate.value.day == date.day;

                  final weekDay = _weekdayStr(date.weekday);

                  return GestureDetector(
                    onTap: () => controller.selectDate(date),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 52,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryAccent
                            : AppColors.lightBackground,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.primaryAccent
                                      .withOpacity(0.35),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                )
                              ]
                            : [],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            weekDay,
                            style: AppTextStyles.caption.copyWith(
                              color: isSelected
                                  ? Colors.white.withOpacity(0.85)
                                  : AppColors.secondaryGreyBlue,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${date.day}',
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.primaryDark,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              )),
            ),
          ),

          const SizedBox(width: 8),

          // Calendar picker icon
          GestureDetector(
            onTap: () => controller.pickDate(context),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primaryAccent.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.calendar_month_outlined,
                color: AppColors.primaryAccent,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _weekdayStr(int weekday) {
    const days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    return days[weekday - 1];
  }

  // -------------------------------------------------------
  // Tabs
  // -------------------------------------------------------

  Widget _buildActiveTab() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryAccent));
      }
      if (controller.activeTickets.isEmpty) {
        return _buildEmptyState('No active trips on this date');
      }
      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        itemCount: controller.activeTickets.length,
        itemBuilder: (context, index) {
          return _buildActiveCard(controller.activeTickets[index]);
        },
      );
    });
  }

  Widget _buildCompletedTab() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryAccent));
      }
      if (controller.completedTickets.isEmpty) {
        return _buildEmptyState('No completed trips on this date');
      }
      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        itemCount: controller.completedTickets.length,
        itemBuilder: (context, index) {
          return _buildCompletedCard(controller.completedTickets[index]);
        },
      );
    });
  }

  Widget _buildCancelledTab() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryAccent));
      }
      if (controller.cancelledTickets.isEmpty) {
        return _buildEmptyState('No cancelled trips on this date');
      }
      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        itemCount: controller.cancelledTickets.length,
        itemBuilder: (context, index) {
          return _buildCancelledCard(controller.cancelledTickets[index]);
        },
      );
    });
  }

  // -------------------------------------------------------
  // Cards
  // -------------------------------------------------------

  Widget _buildActiveCard(Map<String, dynamic> ticket) {
    final ticketId = ticket['id']?.toString() ?? '';
    final from = ticket['origin']?.toString() ?? '-';
    final to = ticket['destination']?.toString() ?? '-';
    final travelsName = ticket['busName']?.toString() ?? 'Bus Journey';
    final journeyDate = ticket['journeyDate']?.toString() ?? '-';
    final busAndSeat = ticket['busAndSeat']?.toString() ?? '';
    final pnr = ticket['bookingId']?.toString() ?? '';
    final passengerName = ticket['passengerName']?.toString() ?? '';
    final passengerPhone = ticket['passengerPhone']?.toString() ?? '';
    final totalPaid = ticket['totalPaid'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryGreyBlue.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Status badge & seat info row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _statusBadge('Active', Colors.green),
                    if (busAndSeat.isNotEmpty)
                      Flexible(
                        child: Text(
                          busAndSeat.contains('|')
                              ? busAndSeat.split('|').last.trim()
                              : busAndSeat,
                          style: AppTextStyles.caption.copyWith(
                              color: AppColors.secondaryGreyBlue),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 14),

                // Main content row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bus icon
                    _busIconWidget(),
                    const SizedBox(width: 14),
                    // Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            travelsName,
                            style: AppTextStyles.h3.copyWith(fontSize: 15),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          // Route
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  from,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.secondaryGreyBlue),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 6),
                                child: Icon(Icons.arrow_forward,
                                    size: 13,
                                    color: AppColors.secondaryGreyBlue),
                              ),
                              Flexible(
                                child: Text(
                                  to,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.secondaryGreyBlue),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            journeyDate,
                            style: AppTextStyles.caption.copyWith(
                                color: AppColors.secondaryGreyBlue),
                          ),
                          if (busAndSeat.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              busAndSeat,
                              style: AppTextStyles.caption.copyWith(
                                  color: AppColors.secondaryGreyBlue),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          if (passengerName.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Passenger: $passengerName',
                              style: AppTextStyles.caption.copyWith(
                                  color: AppColors.secondaryGreyBlue),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          if (passengerPhone.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              'Phone: $passengerPhone',
                              style: AppTextStyles.caption.copyWith(
                                  color: AppColors.secondaryGreyBlue),
                            ),
                          ],
                          if (pnr.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              'PNR: $pnr',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.primaryAccent,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                          if (totalPaid != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Paid: ₹${totalPaid.toStringAsFixed(2)}',
                              style: AppTextStyles.caption.copyWith(
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Divider
          const Divider(height: 1, thickness: 1, color: Color(0xFFF4F4F4)),

          // Cancel button
          TextButton.icon(
            onPressed: () => controller.cancelBooking(ticket),
            icon: const Icon(Icons.close, color: AppColors.primaryAccent, size: 17),
            label: Text(
              'Cancel Booking',
              style: AppTextStyles.buttonText.copyWith(
                  color: AppColors.primaryAccent, fontSize: 14),
            ),
            style: TextButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: const RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      )),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedCard(Map<String, dynamic> ticket) {
    final ticketId = ticket['id']?.toString() ?? '';
    final from = ticket['origin']?.toString() ?? '-';
    final to = ticket['destination']?.toString() ?? '-';
    final travelsName = ticket['busName']?.toString() ?? 'Bus Journey';
    final journeyDate = ticket['journeyDate']?.toString() ?? '-';
    final busAndSeat = ticket['busAndSeat']?.toString() ?? '';
    final pnr = ticket['bookingId']?.toString() ?? '';
    final passengerName = ticket['passengerName']?.toString() ?? '';
    final passengerPhone = ticket['passengerPhone']?.toString() ?? '';
    final totalPaid = ticket['totalPaid'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryGreyBlue.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _statusBadge('Completed', Colors.blue),
                    if (busAndSeat.isNotEmpty)
                      Flexible(
                        child: Text(
                          busAndSeat.contains('|')
                              ? busAndSeat.split('|').last.trim()
                              : busAndSeat,
                          style: AppTextStyles.caption
                              .copyWith(color: AppColors.secondaryGreyBlue),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _busIconWidget(),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [                          Text(
                            travelsName,
                            style: AppTextStyles.h3.copyWith(fontSize: 15),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  from,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.secondaryGreyBlue),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 6),
                                child: Icon(Icons.arrow_forward,
                                    size: 13,
                                    color: AppColors.secondaryGreyBlue),
                              ),
                              Flexible(
                                child: Text(
                                  to,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.secondaryGreyBlue),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            journeyDate,
                            style: AppTextStyles.caption.copyWith(
                                color: AppColors.secondaryGreyBlue),
                          ),
                          if (busAndSeat.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              busAndSeat,
                              style: AppTextStyles.caption.copyWith(
                                  color: AppColors.secondaryGreyBlue),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          if (passengerName.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Passenger: $passengerName',
                              style: AppTextStyles.caption.copyWith(
                                  color: AppColors.secondaryGreyBlue),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          if (passengerPhone.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              'Phone: $passengerPhone',
                              style: AppTextStyles.caption.copyWith(
                                  color: AppColors.secondaryGreyBlue),
                            ),
                          ],
                          if (pnr.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              'PNR: $pnr',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.primaryAccent,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                          if (totalPaid != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Paid: ₹${totalPaid.toStringAsFixed(2)}',
                              style: AppTextStyles.caption.copyWith(
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],

                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1, thickness: 1, color: Color(0xFFF4F4F4)),

          // Action buttons
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                // Report
                GestureDetector(
                  onTap: () => controller.reportIssue(ticketId),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline,
                          color: AppColors.primaryAccent, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'Report',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primaryAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Book Again
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => controller.bookAgain('bus'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          AppColors.primaryAccent.withOpacity(0.1),
                      foregroundColor: AppColors.primaryAccent,
                      elevation: 0,
                      padding:
                          const EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      'Book Again',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primaryAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Rate Trip
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => controller.rateTrip(ticketId),
                    icon: const Icon(Icons.star_border,
                        color: AppColors.primaryDark, size: 15),
                    label: Text(
                      'Rate Trip',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                          color:
                              AppColors.secondaryGreyBlue.withOpacity(0.25)),
                      padding:
                          const EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCancelledCard(Map<String, dynamic> ticket) {
    final from = ticket['origin']?.toString() ?? '-';
    final to = ticket['destination']?.toString() ?? '-';
    final travelsName = ticket['busName']?.toString() ?? 'Bus Journey';
    final journeyDate = ticket['journeyDate']?.toString() ?? '-';
    final busAndSeat = ticket['busAndSeat']?.toString() ?? '';
    final pnr = ticket['bookingId']?.toString() ?? '';
    final passengerName = ticket['passengerName']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryGreyBlue.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _busIconWidget(greyed: true),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          travelsName,
                          style: AppTextStyles.h3.copyWith(fontSize: 15),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _statusBadge('Cancelled', Colors.red),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          from,
                          style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.secondaryGreyBlue),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: Icon(Icons.arrow_forward,
                            size: 13, color: AppColors.secondaryGreyBlue),
                      ),
                      Flexible(
                        child: Text(
                          to,
                          style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.secondaryGreyBlue),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    journeyDate,
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.secondaryGreyBlue),
                  ),
                  if (busAndSeat.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      busAndSeat,
                      style: AppTextStyles.caption.copyWith(
                          color: AppColors.secondaryGreyBlue),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (passengerName.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Passenger: $passengerName',
                      style: AppTextStyles.caption.copyWith(
                          color: AppColors.secondaryGreyBlue),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (pnr.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'PNR: $pnr',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.secondaryGreyBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------
  // Shared Widgets
  // -------------------------------------------------------

  /// Themed bus icon — replaces all constant asset images
  Widget _busIconWidget({bool greyed = false}) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: greyed
            ? LinearGradient(
                colors: [
                  AppColors.secondaryGreyBlue.withOpacity(0.15),
                  AppColors.secondaryGreyBlue.withOpacity(0.25),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : LinearGradient(
                colors: [
                  AppColors.primaryAccent.withOpacity(0.75),
                  AppColors.primaryAccent,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
      ),
      child: Icon(
        Icons.directions_bus_rounded,
        color: greyed ? AppColors.secondaryGreyBlue : Colors.white,
        size: 34,
      ),
    );
  }

  Widget _statusBadge(String label, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: color.shade700,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.directions_bus_rounded,
            size: 70,
            color: AppColors.secondaryGreyBlue.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.secondaryGreyBlue,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------
  // Helpers
  // -------------------------------------------------------

  String _formatSeats(Map<String, dynamic> ticket) {
    final seats = ticket['selectedSeats'];
    if (seats == null) return '';
    if (seats is List && seats.isNotEmpty) {
      return 'Seat: ${seats.join(', ')}';
    }
    if (seats is String && seats.isNotEmpty) return 'Seat: $seats';
    return '';
  }

}