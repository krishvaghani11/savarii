import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:savarii/core/theme/app_colors.dart';
import 'package:savarii/features/customer/home/controller/customer_home_controller.dart';
import '../../../../core/theme/app_text_styles.dart';

class CustomerHomeView extends GetView<CustomerHomeController> {
  const CustomerHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: controller.scaffoldKey,
      backgroundColor: AppColors.lightBackground,

      // 1. The Sidebar Drawer (This was missing!)
      drawer: _buildSidebarDrawer(),

      // 2. The Scrollable Body
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Row (Profile & Notifications)
              _buildHeader(),
              const SizedBox(height: 24),

              // Search Bar
              _buildSearchBar(),
              const SizedBox(height: 30),

              // Quick Actions Grid
              Text('Quick Actions', style: AppTextStyles.h3),
              const SizedBox(height: 16),
              _buildQuickActionsGrid(),
              const SizedBox(height: 30),

              // Active Ticket Section (Empty State)
              Text('Active Ticket', style: AppTextStyles.h3),
              const SizedBox(height: 16),
              _buildActiveTicketCard(),

              const SizedBox(height: 20), // Bottom buffer
            ],
          ),
        ),
      ),
    );
  }

  // --- Sub-Widgets for cleaner code ---

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Profile Tap Area opens Sidebar
        GestureDetector(
          onTap: controller.openSidebar,
          child: Row(
            children: [
              // Profile Avatar with online indicator
              Stack(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.secondaryGreyBlue.withOpacity(
                      0.2,
                    ),
                    child: const Icon(
                      Icons.person,
                      color: AppColors.primaryDark,
                    ),
                    // backgroundImage: AssetImage('assets/images/profile.png'), // Use when you have image
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.lightBackground,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              // Greeting Text
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Good Morning 👋', style: AppTextStyles.caption),
                  Text(
                    controller.userName,
                    style: AppTextStyles.h3.copyWith(fontSize: 18),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Notification Bell
        IconButton(
          onPressed: controller.goToNotifications,
          icon: const Badge(
            backgroundColor: AppColors.primaryAccent,
            smallSize: 10,
            child: Icon(
              Icons.notifications_none_outlined,
              color: AppColors.primaryDark,
              size: 28,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryGreyBlue.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search routes or bus numbers...',
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.secondaryGreyBlue,
          ),
          prefixIcon: const Icon(Icons.search, color: AppColors.primaryAccent),
          suffixIcon: const Icon(
            Icons.tune,
            color: AppColors.secondaryGreyBlue,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildQuickActionsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                title: 'Book Ticket',
                subtitle: 'Intercity & Local',
                icon: Icons.directions_bus,
                iconColor: AppColors.primaryAccent,
                onTap: controller.goToBookTicket,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionCard(
                title: 'Track Bus',
                subtitle: 'Live Location',
                icon: Icons.location_on,
                iconColor: Colors.blueAccent,
                onTap: controller.goToTrackBus,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                title: 'Book Parcel',
                subtitle: 'Send Packages',
                icon: Icons.local_shipping,
                iconColor: Colors.orange,
                onTap: controller.goToBookParcel,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionCard(
                title: 'Wallet',
                subtitle: '\$${controller.walletBalance} Balance',
                icon: Icons.account_balance_wallet,
                iconColor: Colors.teal,
                onTap: controller.goToWallet,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondaryGreyBlue.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(height: 16),
            Text(title, style: AppTextStyles.h3.copyWith(fontSize: 16)),
            const SizedBox(height: 4),
            Text(subtitle, style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveTicketCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryAccent, // The solid red from your design
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryAccent.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // --- Top Row (Ticket ID & Status) ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.confirmation_number,
                    color: AppColors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'TICKET #84920',
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.white,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'CONFIRMED',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          Divider(color: AppColors.white.withOpacity(0.2), height: 1),
          const SizedBox(height: 16),

          // --- Middle Row (Journey Timeline) ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // From Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'From',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.white.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'New York',
                    style: AppTextStyles.h2.copyWith(
                      color: AppColors.white,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '08:00 AM',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),

              // Center Dotted Timeline & Duration
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // Left dotted line
                          Expanded(
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return Flex(
                                  direction: Axis.horizontal,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  mainAxisSize: MainAxisSize.max,
                                  children: List.generate(
                                    (constraints.constrainWidth() / 6).floor(),
                                    (index) => SizedBox(
                                      width: 3,
                                      height: 1.5,
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          color: AppColors.white.withOpacity(
                                            0.5,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          // Center Arrow Circle
                          Container(
                            padding: const EdgeInsets.all(6),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: AppColors.white.withOpacity(0.25),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_forward,
                              color: AppColors.white,
                              size: 14,
                            ),
                          ),
                          // Right dotted line
                          Expanded(
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return Flex(
                                  direction: Axis.horizontal,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  mainAxisSize: MainAxisSize.max,
                                  children: List.generate(
                                    (constraints.constrainWidth() / 6).floor(),
                                    (index) => SizedBox(
                                      width: 3,
                                      height: 1.5,
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          color: AppColors.white.withOpacity(
                                            0.5,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '4h 30m',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // To Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'To',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.white.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Boston',
                    style: AppTextStyles.h2.copyWith(
                      color: AppColors.white,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '12:30 PM',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),

          // --- Bottom Row (Seat, Date & Action Button) ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.airline_seat_recline_normal,
                    color: AppColors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Seat 4A',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Icon(
                    Icons.calendar_today,
                    color: AppColors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Today',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  print("View QR Tapped");
                  // Add your navigation or modal pop-up logic here
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.white,
                  foregroundColor: AppColors.primaryAccent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                  minimumSize: const Size(0, 36),
                ),
                child: Text(
                  'View QR',
                  style: AppTextStyles.buttonText.copyWith(
                    color: AppColors.primaryAccent,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Basic Placeholder Sidebar Drawer
  Widget _buildSidebarDrawer() {
    return Drawer(
      backgroundColor: AppColors.primaryDark,
      // Dark background from your design
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- HEADER SECTION ---
            Padding(
              padding: const EdgeInsets.only(
                left: 24,
                top: 40,
                bottom: 24,
                right: 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.secondaryGreyBlue.withOpacity(0.5),
                        width: 2,
                      ),
                      color: AppColors.white,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.person,
                        size: 40,
                        color: AppColors.primaryDark,
                      ),
                      // backgroundImage: AssetImage('assets/images/profile.png'), // When you have a real image
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Savarii User',
                    // Replace with controller.userName when dynamic
                    style: AppTextStyles.h2.copyWith(
                      color: AppColors.white,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '+91 98765 43210',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.secondaryGreyBlue,
                    ),
                  ),
                ],
              ),
            ),

            Divider(
              color: AppColors.secondaryGreyBlue.withOpacity(0.2),
              height: 1,
            ),
            const SizedBox(height: 16),

            // --- MENU ITEMS ---
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildDrawerItem(
                    icon: Icons.home_filled,
                    title: 'Home',
                    isActive: true, // Home is currently active
                    onTap: controller.closeSidebar,
                  ),
                  _buildDrawerItem(
                    icon: Icons.directions_bus_outlined,
                    title: 'Track Bus',
                    onTap: controller.goToTrackBus,
                  ),
                  _buildDrawerItem(
                    icon: Icons.confirmation_number_outlined,
                    title: 'My Bookings',
                    onTap: controller.goToMyBookings,
                  ),
                  _buildDrawerItem(
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    onTap: controller.goToHelpAndSupport,
                  ),
                  _buildDrawerItem(
                    icon: Icons.language,
                    title: 'Language',
                    onTap: controller.goToLanguage,
                  ),
                  _buildDrawerItem(
                    icon: Icons.info_outline,
                    title: 'About Us',
                    onTap: controller.goToAboutUs,
                  ),
                ],
              ),
            ),

            Divider(
              color: AppColors.secondaryGreyBlue.withOpacity(0.2),
              height: 1,
            ),

            // --- BOTTOM LOGOUT SECTION ---
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: controller.logout,
                    icon: const Icon(
                      Icons.logout,
                      color: AppColors.white,
                      size: 20,
                    ),
                    label: Text('Logout', style: AppTextStyles.buttonText),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryAccent, // Red button
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Version 1.0.2',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.secondaryGreyBlue.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Reusable Drawer Item Widget ---
  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primaryAccent : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          icon,
          color: isActive ? AppColors.white : AppColors.secondaryGreyBlue,
          size: 24,
        ),
        title: Text(
          title,
          style: AppTextStyles.bodyLarge.copyWith(
            color: isActive ? AppColors.white : AppColors.secondaryGreyBlue,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      ),
    );
  }
}
