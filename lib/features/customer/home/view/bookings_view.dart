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
              // Route back to Home tab if inside the bottom nav
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
        body: TabBarView(
          children: [
            // 1. Active Tab
            _buildActiveTab(),

            // 2. Completed Tab
            _buildCompletedTab(),

            // 3. Cancelled Tab (Placeholder)
            Center(
              child: Text(
                'No cancelled bookings.',
                style: AppTextStyles.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveTab() {
    return Obx(() {
      if (controller.activeBookings.isEmpty) {
        return Center(
          child: Text('No active bookings.', style: AppTextStyles.bodyMedium),
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: controller.activeBookings.length,
        itemBuilder: (context, index) {
          final booking = controller.activeBookings[index];
          return _buildBookingCard(booking);
        },
      );
    });
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryGreyBlue.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Row 1: Badge and SubInfo
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  booking['status'],
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                booking['subInfo'],
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.secondaryGreyBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Row 2: Main Details & Image
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking['title'],
                      style: AppTextStyles.h3.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          booking['from'],
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.secondaryGreyBlue,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Icon(
                            Icons.arrow_forward,
                            size: 14,
                            color: AppColors.secondaryGreyBlue,
                          ),
                        ),
                        Text(
                          booking['to'],
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.secondaryGreyBlue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      booking['datetime'],
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.secondaryGreyBlue,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Image Square
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  booking['image'],
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 80,
                    height: 80,
                    color: AppColors.lightBackground,
                    child: const Icon(
                      Icons.image,
                      color: AppColors.secondaryGreyBlue,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Row 3: Cancel Button
          TextButton.icon(
            onPressed: () => controller.cancelBooking(booking['id']),
            icon: const Icon(
              Icons.close,
              color: AppColors.primaryAccent,
              size: 18,
            ),
            label: Text(
              'Cancel Booking',
              style: AppTextStyles.buttonText.copyWith(
                color: AppColors.primaryAccent,
              ),
            ),
            style: TextButton.styleFrom(
              backgroundColor: AppColors.primaryAccent.withValues(alpha: 0.08),
              // Light red background
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- NEW: Completed Tab Builder ---
  Widget _buildCompletedTab() {
    return Obx(() {
      if (controller.completedBookings.isEmpty) {
        return Center(
          child: Text(
            'No completed bookings.',
            style: AppTextStyles.bodyMedium,
          ),
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: controller.completedBookings.length,
        itemBuilder: (context, index) {
          final booking = controller.completedBookings[index];
          return _buildCompletedBookingCard(booking);
        },
      );
    });
  }

  // --- NEW: Completed Booking Card ---
  Widget _buildCompletedBookingCard(Map<String, dynamic> booking) {
    final isBus = booking['type'] == 'bus';

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryGreyBlue.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Row 1: Badge and SubInfo
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  booking['status'],
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                booking['subInfo'],
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.secondaryGreyBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Row 2: Main Details & Image
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking['title'],
                      style: AppTextStyles.h3.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          booking['from'],
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.secondaryGreyBlue,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Icon(
                            Icons.arrow_forward,
                            size: 14,
                            color: AppColors.secondaryGreyBlue,
                          ),
                        ),
                        Text(
                          booking['to'],
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.secondaryGreyBlue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      booking['datetime'],
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.secondaryGreyBlue,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Image Square
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  booking['image'],
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 80,
                    height: 80,
                    color: AppColors.lightBackground,
                    child: const Icon(
                      Icons.image,
                      color: AppColors.secondaryGreyBlue,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Row 3: Action Buttons (Book Again & Rate Trip)
          Row(
            children: [
              // 1. New Report Button (Icon + Text)
              GestureDetector(
                onTap: () => controller.reportIssue(booking['id']),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error,
                      color: AppColors.primaryAccent,
                      size: 16,
                    ),
                    // Red circle with exclamation
                    const SizedBox(width: 4),
                    Text(
                      'Report',
                      style: AppTextStyles.buttonText.copyWith(
                        color: AppColors.primaryAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // 2. Center Button (Book / Send Again)
              Expanded(
                child: ElevatedButton(
                  onPressed: () => controller.bookAgain(booking['type']),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryAccent.withValues(alpha: 0.1),
                    // Light red
                    foregroundColor: AppColors.primaryAccent,
                    // Red text
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    isBus ? 'Book Again' : 'Send Again',
                    style: AppTextStyles.buttonText.copyWith(
                      color: AppColors.primaryAccent,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // 3. Right Button (Rate Trip / Service)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => controller.rateTrip(booking['id']),
                  icon: const Icon(
                    Icons.star,
                    color: AppColors.primaryDark,
                    size: 16,
                  ),
                  label: Text(
                    isBus ? 'Rate Trip' : 'Rate Service',
                    style: AppTextStyles.buttonText.copyWith(
                      color: AppColors.primaryDark,
                      fontSize: 13,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: AppColors.secondaryGreyBlue.withValues(alpha: 0.2),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
