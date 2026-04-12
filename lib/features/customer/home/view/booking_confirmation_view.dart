import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:savarii/core/theme/app_colors.dart';
import 'package:savarii/core/theme/app_text_styles.dart';
import 'package:savarii/features/customer/home/controller/booking_confirmation_controller.dart';

class BookingConfirmationView extends GetView<BookingConfirmationController> {
  const BookingConfirmationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground, // #F5F6F8 or similar
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text('Confirmation', style: AppTextStyles.h3),
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.primaryDark),
          onPressed: controller.closeAndGoHome,
        ),
        actions: [
          TextButton(
            onPressed: controller.closeAndGoHome,
            child: Text(
              'Done',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primaryAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Success Header
              _buildSuccessHeader(),
              const SizedBox(height: 24),

              // 2. The Ticket Card
              _buildTicketCard(),
              const SizedBox(height: 24),

              // 3. Need Help Button
              TextButton.icon(
                onPressed: controller.needHelp,
                icon: const Icon(
                  Icons.help_outline,
                  color: AppColors.primaryAccent,
                  size: 16,
                ),
                label: Text(
                  'Need help with this booking?',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primaryAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 100), // Buffer for bottom button
            ],
          ),
        ),
      ),
      // Sticky Bottom Button
      bottomNavigationBar: _buildBottomButton(),
    );
  }

  // --- Sub-Widgets ---

  Widget _buildSuccessHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primaryAccent.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: AppColors.primaryAccent,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: AppColors.white, size: 32),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Booking Confirmed!',
          style: AppTextStyles.h1.copyWith(fontSize: 24),
        ),
        const SizedBox(height: 8),
        Text(
          'Your trip is set. Details have been sent to email.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.secondaryGreyBlue,
          ),
        ),
        const SizedBox(height: 16),
        Obx(
          () => Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border:
                  Border.all(color: AppColors.primaryAccent.withOpacity(0.2)),
            ),
            child: Text(
              'Booking ID: ${controller.bookingId.value}',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.primaryAccent,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTicketCard() {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.secondaryGreyBlue.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              // Top Logo Area
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                decoration: const BoxDecoration(
                  color: AppColors.primaryAccent,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'UPCOMING TRIP',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.white.withOpacity(0.8),
                              letterSpacing: 1,
                              fontSize: 10,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Obx(
                            () => Text(
                              '${controller.fromCity.value} to ${controller.toCity.value}',
                              style: AppTextStyles.h2.copyWith(
                                color: AppColors.white,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.directions_bus,
                        color: AppColors.white,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),

              // Timeline Area
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 24.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Departure
                    Obx(
                      () => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            controller.departureTime.value,
                            style: AppTextStyles.h2.copyWith(
                              fontSize: 22,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            controller.fromCity.value,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.secondaryGreyBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Dashed Line & Duration
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          children: [
                            Obx(
                              () => Text(
                                controller.duration.value,
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.secondaryGreyBlue,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.circle,
                                  color: AppColors.primaryAccent,
                                  size: 8,
                                ),
                                Expanded(
                                  child: LayoutBuilder(
                                    builder: (context, constraints) {
                                      return Flex(
                                        direction: Axis.horizontal,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        mainAxisSize: MainAxisSize.max,
                                        children: List.generate(
                                          (constraints.constrainWidth() / 6)
                                              .floor(),
                                          (index) => SizedBox(
                                            width: 3,
                                            height: 1.5,
                                            child: DecoratedBox(
                                              decoration: BoxDecoration(
                                                color: AppColors
                                                    .secondaryGreyBlue
                                                    .withOpacity(0.3),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                Icon(
                                  Icons.circle,
                                  color: AppColors.secondaryGreyBlue
                                      .withOpacity(0.3),
                                  size: 8,
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Non-stop',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.primaryAccent,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Arrival
                    Obx(
                      () => Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            controller.arrivalTime.value,
                            style: AppTextStyles.h2.copyWith(
                              fontSize: 22,
                              height: 1.1,
                            ),
                            textAlign: TextAlign.right,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            controller.toCity.value,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.secondaryGreyBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Divider Line
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Divider(
                  color: AppColors.secondaryGreyBlue.withOpacity(0.1),
                  height: 1,
                ),
              ),

              // 2x2 Grid Area
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Obx(() => _buildGridItem(
                                Icons.calendar_today,
                                'DATE',
                                controller.date.value,
                              )),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Obx(() => _buildGridItem(
                                Icons.airline_seat_recline_normal,
                                'SEAT',
                                controller.seat.value,
                              )),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Obx(() => _buildGridItem(
                                Icons.people,
                                'PASSENGERS',
                                controller.passengers.value,
                              )),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Obx(() => _buildGridItem(
                                Icons.star,
                                'CLASS',
                                controller.travelClass.value,
                              )),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Obx(() => _buildGridItem(
                                Icons.person,
                                'PRIMARY PASSENGER',
                                controller.passengerName.value,
                              )),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Obx(() => _buildGridItem(
                                Icons.phone,
                                'CONTACT NUMBER',
                                controller.passengerPhone.value,
                              )),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Left Cutout (Punch hole effect)
        Positioned(
          left: -12,
          top: 200, // Adjust based on where timeline lands
          child: Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: AppColors.lightBackground,
              shape: BoxShape.circle,
            ),
          ),
        ),
        // Right Cutout (Punch hole effect)
        Positioned(
          right: -12,
          top: 200,
          child: Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: AppColors.lightBackground,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGridItem(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.lightBackground.withOpacity(0.5),
        // Very light grey box
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primaryAccent, size: 14),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primaryAccent,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.primaryDark,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      decoration: const BoxDecoration(color: AppColors.lightBackground),
      child: SafeArea(
        child: ElevatedButton.icon(
          onPressed: controller.downloadETicket,
          icon: const Icon(
            Icons.download_outlined,
            color: AppColors.white,
            size: 20,
          ),
          label: Text(
            'Download E-Ticket',
            style: AppTextStyles.buttonText.copyWith(fontSize: 16),
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
      ),
    );
  }
}
