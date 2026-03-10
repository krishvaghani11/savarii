import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:savarii/features/customer/home/controller/book_ticket_controller.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class BookTicketView extends GetView<BookTicketController> {
  const BookTicketView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text('Book Ticket', style: AppTextStyles.h3),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryDark),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Top Card: Input Section
              _buildInputCard(context),
              const SizedBox(height: 32),

              // 2. Recent Searches Section
              _buildRecentSearches(),
              const SizedBox(height: 32),

              // 3. Popular Routes Section
              Text('Popular Routes', style: AppTextStyles.h3),
              const SizedBox(height: 16),
              _buildPopularRoutes(),

              const SizedBox(height: 20), // Bottom buffer
            ],
          ),
        ),
      ),
    );
  }

  // --- Sub-Widgets for cleaner code ---

  Widget _buildInputCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24.0),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryGreyBlue.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Stack to position the sync button between the two location fields
          Stack(
            alignment: Alignment.center,
            children: [
              Column(
                children: [
                  // From field
                  _buildLocationInput(
                    title: 'From (Starting point)',
                    controller: controller.fromController,
                    icon: Icons.location_on,
                  ),
                  const SizedBox(height: 50),
                  // To field
                  _buildLocationInput(
                    title: 'To (Destination)',
                    controller: controller.toController,
                    icon: Icons.navigation,
                  ),
                ],
              ),
              // Swap locations icon - Centered vertically between the two input boxes
              Padding(
                padding: const EdgeInsets.only(right: 8.0, top: 25.0),
                child: _buildSwapLocationsIcon(),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Row: Date & Passengers
          Row(
            children: [
              // Date selection
              _buildDateSelection(context),
              const SizedBox(width: 16),

              // Passenger count
              _buildPassengerCount(),
            ],
          ),
          const SizedBox(height: 24),

          // Search Buses button
          _buildSearchButton(),
        ],
      ),
    );
  }

  Widget _buildSwapLocationsIcon() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.primaryAccent,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.white, width: 4),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryAccent.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        onPressed: controller.swapLocations,
        icon: const Icon(Icons.sync, color: AppColors.white, size: 20),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      ),
    );
  }

  Widget _buildLocationInput({
    required String title,
    required TextEditingController controller,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.secondaryGreyBlue,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.lightBackground,
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: TextField(
            controller: controller,
            style: AppTextStyles.bodyLarge,
            decoration: InputDecoration(
              hintText: 'City or Station',
              hintStyle: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.secondaryGreyBlue.withValues(alpha: 0.5),
              ),
              prefixIcon: Icon(icon, color: AppColors.primaryAccent),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 18.0),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateSelection(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Departure Date',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.secondaryGreyBlue,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => controller.selectDate(context),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 18.0,
              ),
              decoration: BoxDecoration(
                color: AppColors.lightBackground,
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    color: AppColors.primaryAccent,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  // Reactive Date text
                  Expanded(
                    child: Obx(
                      () => Text(
                        "${controller.selectedDate.value.day}/${controller.selectedDate.value.month}/${controller.selectedDate.value.year}",
                        style: AppTextStyles.bodyLarge.copyWith(fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
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

  Widget _buildPassengerCount() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Passengers',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.secondaryGreyBlue,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 6.0),
            decoration: BoxDecoration(
              color: AppColors.lightBackground,
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 4.0),
                  child: Icon(
                    Icons.person,
                    color: AppColors.primaryAccent,
                    size: 18,
                  ),
                ),
                // Subtract button
                IconButton(
                  onPressed: controller.decrementPassengers,
                  icon: const Icon(
                    Icons.remove,
                    color: AppColors.secondaryGreyBlue,
                    size: 16,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                // Reactive Passenger Count
                Obx(
                  () => Text(
                    "${controller.passengerCount.value}",
                    style: AppTextStyles.bodyLarge.copyWith(fontSize: 14),
                  ),
                ),
                // Add button
                IconButton(
                  onPressed: controller.incrementPassengers,
                  icon: const Icon(
                    Icons.add,
                    color: AppColors.primaryAccent,
                    size: 16,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchButton() {
    return ElevatedButton.icon(
      onPressed: controller.searchBuses,
      icon: const Icon(Icons.search, color: AppColors.white, size: 20),
      label: Text(
        'Search Buses',
        style: AppTextStyles.buttonText.copyWith(fontSize: 18),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryAccent,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        shadowColor: AppColors.primaryAccent.withValues(alpha: 0.3),
        elevation: 8,
      ),
    );
  }

  Widget _buildRecentSearches() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24.0),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryGreyBlue.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: title & button
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recent Searches', style: AppTextStyles.h3),
                TextButton(
                  onPressed: controller.clearRecentSearches,
                  child: Text(
                    'Clear All',
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Body: text "no recent search"
          Container(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            margin: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
            decoration: BoxDecoration(
              color: AppColors.lightBackground,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(
                color: AppColors.secondaryGreyBlue.withValues(alpha: 0.2),
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.history,
                  size: 48,
                  color: AppColors.secondaryGreyBlue.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 12),
                Text(
                  'No recent search',
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.secondaryGreyBlue,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your recent bus searches will appear here for quick access.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.secondaryGreyBlue,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularRoutes() {
    // Dummy data list
    final popularRoutes = [
      {
        'title': 'Delhi to Jaipur',
        'price': '₹499',
        'image': AppAssets.route1Image,
      },
      {
        'title': 'Mumbai to Goa',
        'price': '₹899',
        'image': AppAssets.route2Image,
      },
      {
        'title': 'Bangalore to Mysore',
        'price': '₹299',
        'image': AppAssets.route3Image,
      },
    ];

    return Wrap(
      spacing: 16.0,
      runSpacing: 16.0,
      children: popularRoutes.map((route) {
        return _buildRouteCard(route);
      }).toList(),
    );
  }

  Widget _buildRouteCard(Map<String, String> route) {
    return Container(
      width: (Get.width - 48 - 16) / 2, // 2 cards per row
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20.0),
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
          // Image top
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: Image.asset(route['image']!, height: 120, fit: BoxFit.cover),
          ),
          // Content bottom
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  route['title']!,
                  style: AppTextStyles.h3.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 6),
                RichText(
                  text: TextSpan(
                    text: 'Starts at ',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.secondaryGreyBlue,
                    ),
                    children: [
                      TextSpan(
                        text: route['price']!,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primaryAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
