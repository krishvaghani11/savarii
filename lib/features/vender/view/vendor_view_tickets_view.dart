import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:savarii/core/theme/app_colors.dart';
import 'package:savarii/core/theme/app_text_styles.dart';
import 'package:savarii/core/utils/locale_utils.dart';
import '../controllers/vendor_view_tickets_controller.dart';

class VendorViewTicketsView extends GetView<VendorViewTicketsController> {
  const VendorViewTicketsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text('tickets.title'.tr(), style: AppTextStyles.h3),

        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: AppColors.primaryDark),
            onPressed: controller.openFilters,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 2. Stats Cards
              Row(
                children: [
                  Expanded(
                    child: Obx(() => _buildStatCard(
                      title: 'tickets.total'.tr(),
                      value: LocaleUtils.formatCount(context, controller.totalTickets),
                      bgColor: const Color(0xFFFFEBEB),
                      // Light Pink
                      borderColor: const Color(0xFFFFD6D6),
                      textColor: AppColors.primaryAccent,
                    )),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Obx(() => _buildStatCard(
                      title: 'tickets.confirmed_count'.tr(),
                      value: LocaleUtils.formatCount(context, controller.confirmedTickets),
                      bgColor: const Color(0xFFEBFFF4),
                      // Light Green
                      borderColor: const Color(0xFFD6FFE8),
                      textColor: const Color(0xFF00A65A), // Green
                    )),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // NEW: Type Toggle (Tickets vs Parcels)
              _buildTypeToggle(),
              const SizedBox(height: 16),

              // NEW: 1. Date Selector Layout
              _buildDateSelector(context),
              const SizedBox(height: 16),

              // 3. List Header
              Text(
                'tickets.recent'.tr(),
                style: AppTextStyles.h3.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 16),

              // 4. Ticket List
              Obx(() => controller.tickets.isEmpty
                  ? Center(child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text("tickets.no_tickets".tr()),
                    ))
                  : Column(
                      children: controller.tickets.map(
                        (ticket) => _buildTicketListItem(context, ticket),
                      ).toList(),
                    )),
            ],
          ),
        ),
      ),
    );
  }

  // --- Sub-Widgets ---

  Widget _buildDateSelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Select Date',
              style: AppTextStyles.h2.copyWith(fontSize: 18),
            ),
            IconButton(
              icon: const Icon(Icons.calendar_month, color: AppColors.primaryAccent),
              onPressed: () => controller.pickDate(context),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 80,
          child: Obx(() {
            final days = controller.currentWeekDays;
            final selected = controller.selectedDate.value;

            return ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: days.length,
              itemBuilder: (context, index) {
                final date = days[index];
                final isSelected =
                    date.year == selected.year &&
                    date.month == selected.month &&
                    date.day == selected.day;

                return GestureDetector(
                  onTap: () => controller.selectDate(date),
                  child: Container(
                    width: 65,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primaryAccent : AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _getWeekDayLabel(date.weekday),
                          style: AppTextStyles.caption.copyWith(
                            color: isSelected ? AppColors.white.withOpacity(0.9) : AppColors.secondaryGreyBlue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          date.day.toString(),
                          style: AppTextStyles.h2.copyWith(
                            color: isSelected ? AppColors.white : AppColors.primaryDark,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildTypeToggle() {
    return Obx(() {
      final currentTab = controller.currentMainTab.value;
      return Container(
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFFF7F8FA),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => controller.switchMainTab(0),
                child: Container(
                  decoration: BoxDecoration(
                    color: currentTab == 0 ? AppColors.primaryAccent : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Bus Tickets',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: currentTab == 0 ? Colors.white : AppColors.secondaryGreyBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => controller.switchMainTab(1),
                child: Container(
                  decoration: BoxDecoration(
                    color: currentTab == 1 ? AppColors.primaryAccent : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Parcels',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: currentTab == 1 ? Colors.white : AppColors.secondaryGreyBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  String _getWeekDayLabel(int weekday) {
    switch (weekday) {
      case 1: return 'MON';
      case 2: return 'TUE';
      case 3: return 'WED';
      case 4: return 'THU';
      case 5: return 'FRI';
      case 6: return 'SAT';
      case 7: return 'SUN';
      default: return '';
    }
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color bgColor,
    required Color borderColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.secondaryGreyBlue,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.h1.copyWith(color: textColor, fontSize: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketListItem(BuildContext context, VendorTicketModel ticket) {
    return GestureDetector(
      onTap: () => _showTicketDetailsBottomSheet(context, ticket),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.secondaryGreyBlue.withOpacity(0.15),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Name and Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  controller.currentMainTab.value == 0 
                      ? ticket.passengerName 
                      : 'Sender: ${ticket.passengerName}',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Builder(builder: (context) {
                  final isCancelled = ticket.status.toLowerCase() == 'cancelled';
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isCancelled
                          ? const Color(0xFFFFE5E5)
                          : const Color(0xFFD6FFE8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isCancelled ? 'Cancelled' : 'tickets.success_status'.tr(),
                      style: AppTextStyles.caption.copyWith(
                        color: isCancelled
                            ? const Color(0xFFE82E59)
                            : const Color(0xFF00A65A),
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  );
                }),
              ],
            ),
            const SizedBox(height: 4),
            // Row 2: Phone, Ticket ID, Seat
            Text(
              LocaleUtils.formatNumber(context, ticket.passengerPhone),
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.secondaryGreyBlue,
              ),
            ),
            Text(
              '${ticket.bookingId} • ${ticket.busAndSeat}',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.secondaryGreyBlue,
              ),
            ),
            const SizedBox(height: 12),
            Divider(
              color: AppColors.secondaryGreyBlue.withOpacity(0.1),
              height: 1,
            ),
            const SizedBox(height: 12),
            // Row 3: Route
            Row(
              children: [
                const Icon(
                  Icons.route,
                  color: AppColors.primaryAccent,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    ticket.route,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.secondaryGreyBlue,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Row 4: Boarding Point
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  color: AppColors.secondaryGreyBlue,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  LocaleUtils.formatCurrency(context, ticket.totalPaid),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    ticket.origin,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.secondaryGreyBlue,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- Bottom Sheet ---

  void _showTicketDetailsBottomSheet(
    BuildContext context,
    VendorTicketModel ticket,
  ) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
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

              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ticket.passengerName,
                        style: AppTextStyles.h2.copyWith(fontSize: 22),
                      ),
                      Text(
                        'tickets.ticket_details'.tr(),
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.secondaryGreyBlue,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryGreyBlue.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: AppColors.primaryDark,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Contact Info
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'tickets.mobile'.tr(),
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.secondaryGreyBlue,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          LocaleUtils.formatNumber(context, ticket.passengerPhone),
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Ticket Info Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.secondaryGreyBlue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'tickets.ticket_id'.tr(),
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.secondaryGreyBlue,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            ticket.bookingId,
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'tickets.booking_date'.tr(),
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.secondaryGreyBlue,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(LocaleUtils.formatDate(context, ticket.journeyDate), style: AppTextStyles.bodyMedium),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            controller.currentMainTab.value == 0 ? 'tickets.bus_seat'.tr() : 'Weight',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.secondaryGreyBlue,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            ticket.busAndSeat,
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'tickets.status'.tr(),
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.secondaryGreyBlue,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.circle,
                                color: Color(0xFF00A65A),
                                size: 10,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'tickets.success_label'.tr(),
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: const Color(0xFF00A65A),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Route Timeline
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          border: Border.all(
                            color: AppColors.primaryAccent,
                            width: 3,
                          ),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Container(
                        width: 2,
                        height: 30,
                        color: AppColors.secondaryGreyBlue.withOpacity(0.3),
                      ),
                      // Ideally use dotted line
                      const Icon(
                        Icons.location_on,
                        color: AppColors.secondaryGreyBlue,
                        size: 16,
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'tickets.route'.tr(),
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.secondaryGreyBlue,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          ticket.route,
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          controller.currentMainTab.value == 0 ? 'tickets.boarding_point'.tr() : 'Pickup Point',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.secondaryGreyBlue,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          ticket.origin,
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Get.back();
                        controller.downloadTicket(ticket);
                      },
                      icon: const Icon(
                        Icons.download,
                        color: AppColors.primaryDark,
                        size: 18,
                      ),
                      label: Text(
                        'tickets.download'.tr(),
                        style: AppTextStyles.buttonText.copyWith(
                          color: AppColors.primaryDark,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(
                          color: AppColors.secondaryGreyBlue.withOpacity(0.2),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Get.back();
                        controller.shareTicket(ticket.bookingId);
                      },
                      icon: const Icon(
                        Icons.share,
                        color: AppColors.white,
                        size: 18,
                      ),
                      label: Text('tickets.share'.tr(), style: AppTextStyles.buttonText),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryAccent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      isScrollControlled:
          true, // Allows the bottom sheet to size itself properly
    );
  }
}
