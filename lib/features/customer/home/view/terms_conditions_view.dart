import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:savarii/core/theme/app_colors.dart';
import 'package:savarii/core/theme/app_text_styles.dart';
import 'package:savarii/features/customer/home/controller/terms_conditions_controller.dart';

class TermsConditionsView extends GetView<TermsConditionsController> {
  const TermsConditionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Text('Terms & Conditions', style: AppTextStyles.h3),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryDark),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Header Section
              Text('Acceptance of Terms', style: AppTextStyles.h2),
              const SizedBox(height: 12),
              Text(
                'By accessing or using the Savarii app, you agree to be bound by these Terms and Conditions. Please read them carefully before using our transportation and parcel services. Your continued use of the platform signifies your agreement to any future modifications.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.secondaryGreyBlue,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),

              // 2. Expandable Terms Sections
              _buildTermsSection(
                title: 'User Accounts & Eligibility',
                icon: Icons.person_outline,
                initiallyExpanded: true,
                content: Text(
                  'Users must be at least 18 years old to create an account. You are responsible for maintaining the confidentiality of your login credentials and for all activities under your account. Savarii reserves the right to suspend accounts providing false information.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.secondaryGreyBlue,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              _buildTermsSection(
                title: 'Bus Booking & Cancellation',
                icon: Icons.directions_bus_outlined,
                content: Text(
                  'Details regarding ticket purchases, seat assignments, and cancellation refund policies go here.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.secondaryGreyBlue,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              _buildTermsSection(
                title: 'Parcel Booking & Delivery',
                icon: Icons.inventory_2_outlined,
                content: Text(
                  'Terms regarding prohibited items, weight limits, and delivery liability go here.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.secondaryGreyBlue,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              _buildTermsSection(
                title: 'Payments, Refunds & Wallet',
                icon: Icons.account_balance_wallet_outlined,
                content: Text(
                  'Information on accepted payment methods, Savarii wallet terms, and refund processing times go here.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.secondaryGreyBlue,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              _buildTermsSection(
                title: 'User Conduct & Safety',
                icon: Icons.gpp_maybe_outlined,
                content: Text(
                  'Rules regarding acceptable behavior during trips and consequences of violating safety protocols go here.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.secondaryGreyBlue,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              _buildTermsSection(
                title: 'Privacy Policy Reference',
                icon: Icons.privacy_tip_outlined,
                content: Text(
                  'A brief note connecting these terms to how data is handled, linking back to the Privacy Policy.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.secondaryGreyBlue,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // 3. Contact Support Card
              _buildContactCard(),
              const SizedBox(height: 32),

              // 4. Footer Date
              Center(
                child: Text(
                  'Last updated: October 24, 2023',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.secondaryGreyBlue.withOpacity(0.6),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // --- Sub-Widgets ---

  Widget _buildTermsSection({
    required String title,
    required IconData icon,
    required Widget content,
    bool initiallyExpanded = false,
  }) {
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
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          iconColor: AppColors.primaryDark,
          collapsedIconColor: AppColors.primaryDark,
          leading: Icon(icon, color: AppColors.primaryAccent, size: 22),
          title: Text(
            title,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          // Slightly smaller to prevent text overflow
          children: [content],
        ),
      ),
    );
  }

  Widget _buildContactCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primaryAccent.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryAccent.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        // Left aligned in this mockup
        children: [
          Text('Questions?', style: AppTextStyles.h3),
          const SizedBox(height: 8),
          Text(
            'If you have any questions regarding these terms, please contact our support team.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.secondaryGreyBlue,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: controller.contactSupport,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryAccent,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: Text('Contact Support', style: AppTextStyles.buttonText),
          ),
        ],
      ),
    );
  }
}
