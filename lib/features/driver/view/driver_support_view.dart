import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:savarii/core/theme/app_colors.dart';
import 'package:savarii/core/theme/app_text_styles.dart';
import 'package:savarii/features/driver/controller/driver_support_controller.dart';


class DriverSupportView extends GetView<DriverSupportController> {
  const DriverSupportView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC), // Very light greyish-blue background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Text('Support', style: AppTextStyles.h3.copyWith(color: const Color(0xFF2A2D3E))),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.secondaryGreyBlue),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.secondaryGreyBlue),
            onPressed: () {
              // Trigger search focus
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Header Title
              Text(
                'How can we help,\nDriver?',
                style: AppTextStyles.h1.copyWith(
                  fontSize: 32,
                  color: const Color(0xFF2A2D3E), // Dark Navy
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Find instant answers or reach our team 24/7.',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.secondaryGreyBlue),
              ),
              const SizedBox(height: 24),

              // 2. Search Bar
              _buildSearchBar(),
              const SizedBox(height: 32),

              // 3. Categories Section
              _buildSectionTitle('CATEGORIES'),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildCategoryCard(
                    icon: Icons.build_outlined, // Wrench icon
                    title: 'Vehicle\nIssues',
                    subtitle: 'Maintenance &\ndocs',
                    onTap: () => controller.openCategory('Vehicle Issues'),
                  ),
                  const SizedBox(width: 16),
                  _buildCategoryCard(
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'Account &\nPayouts',
                    subtitle: 'Earnings & tax info',
                    onTap: () => controller.openCategory('Account & Payouts'),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // 4. Direct Contact Section
              _buildDirectContactCard(),
              const SizedBox(height: 32),

              // 5. Common FAQs Section
              _buildSectionTitle('COMMON FAQS'),
              const SizedBox(height: 16),
              _buildFaqTile(
                icon: Icons.directions_car_outlined,
                title: 'How to update vehicle info?',
                onTap: () => controller.openFaq('update_vehicle'),
              ),
              const SizedBox(height: 12),
              _buildFaqTile(
                icon: Icons.payments_outlined,
                title: 'When will I get paid?',
                onTap: () => controller.openFaq('payout_schedule'),
              ),
              const SizedBox(height: 12),
              _buildFaqTile(
                icon: Icons.shield_outlined,
                title: 'Safety and insurance\ncoverage',
                onTap: () => controller.openFaq('insurance'),
              ),
              const SizedBox(height: 40), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }

  // --- Sub-Widgets ---

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryGreyBlue.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: controller.searchController,
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primaryDark),
        decoration: InputDecoration(
          hintText: 'Search issues, trips, or policies...',
          hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.secondaryGreyBlue.withOpacity(0.7)),
          prefixIcon: const Icon(Icons.search, color: AppColors.secondaryGreyBlue),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.caption.copyWith(
        color: AppColors.secondaryGreyBlue,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
        fontSize: 11,
      ),
    );
  }

  Widget _buildCategoryCard({required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2D3E), // Dark Slate/Navy
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2A2D3E).withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryAccent.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.primaryAccent, size: 24),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: AppTextStyles.bodyLarge.copyWith(color: AppColors.white, fontWeight: FontWeight.bold, height: 1.2),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: AppTextStyles.caption.copyWith(color: AppColors.white.withOpacity(0.7), fontSize: 10, height: 1.3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDirectContactCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryGreyBlue.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('DIRECT CONTACT'),
          const SizedBox(height: 16),
          
          // Call Help Desk Button
          ElevatedButton.icon(
            onPressed: controller.callHelpDesk,
            icon: const Icon(Icons.phone_in_talk_outlined, color: AppColors.white, size: 20),
            label: Text('Call Help Desk', style: AppTextStyles.buttonText.copyWith(fontSize: 15)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryAccent,
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              shadowColor: AppColors.primaryAccent.withOpacity(0.3),
            ),
          ),
          const SizedBox(height: 12),
          
          // Chat & Email Row
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: controller.openChat,
                  icon: const Icon(Icons.chat_bubble_outline, color: AppColors.primaryAccent, size: 18),
                  label: Text('Chat', style: AppTextStyles.buttonText.copyWith(color: const Color(0xFF2A2D3E), fontSize: 14)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.secondaryGreyBlue.withOpacity(0.2)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: controller.openEmail,
                  icon: const Icon(Icons.email_outlined, color: AppColors.primaryAccent, size: 18),
                  label: Text('Email', style: AppTextStyles.buttonText.copyWith(color: const Color(0xFF2A2D3E), fontSize: 14)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.secondaryGreyBlue.withOpacity(0.2)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFaqTile({required IconData icon, required String title, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondaryGreyBlue.withOpacity(0.04),
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
                color: AppColors.primaryAccent.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primaryAccent, size: 18),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2A2D3E), // Dark Navy
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.secondaryGreyBlue, size: 20),
          ],
        ),
      ),
    );
  }
}