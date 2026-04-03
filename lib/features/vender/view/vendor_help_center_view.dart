import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:savarii/core/theme/app_colors.dart';
import 'package:savarii/core/theme/app_text_styles.dart';
import '../controllers/vendor_help_center_controller.dart';

class VendorHelpCenterView extends GetView<VendorHelpCenterController> {
  const VendorHelpCenterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      // A slightly off-white background matches the mockup
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text('help.title'.tr(), style: AppTextStyles.h3),
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
              // 1. Header & Search
              Text(
                'help.help_how'.tr(),
                style: AppTextStyles.h1.copyWith(fontSize: 24),
              ),
              const SizedBox(height: 8),
              Text(
                'help.help_subtitle'.tr(),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.secondaryGreyBlue,
                ),
              ),
              const SizedBox(height: 24),
              _buildSearchBar(),
              const SizedBox(height: 32),

              // 2. FAQ Categories
              Text(
                'help.faq_categories'.tr(),
                style: AppTextStyles.h3.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 16),
              _buildCategoriesGrid(),
              const SizedBox(height: 32),

              // 3. Popular Articles
              Text(
                'help.popular_articles'.tr(),
                style: AppTextStyles.h3.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 16),
              _buildArticleTile('help.article_refund'.tr()),
              const SizedBox(height: 12),
              _buildArticleTile('help.article_vehicle'.tr()),
              const SizedBox(height: 12),
              _buildArticleTile('help.article_payment'.tr()),
              const SizedBox(height: 32),

              // 4. Contact Support Footer Card
              _buildSupportFooter(),
              const SizedBox(height: 24),
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
        color: AppColors.secondaryGreyBlue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
      ),
      child: TextField(
        controller: controller.searchController,
        decoration: InputDecoration(
          hintText: 'help.search_hint'.tr(),
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.secondaryGreyBlue.withOpacity(0.6),
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.secondaryGreyBlue,
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesGrid() {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              _buildCategoryCard(Icons.person, 'help.account_login'.tr()),
              const SizedBox(height: 16),
              _buildCategoryCard(
                Icons.account_balance_wallet,
                'help.payment_earnings'.tr(),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            children: [
              _buildCategoryCard(Icons.confirmation_num, 'help.ticket_management'.tr()),
              const SizedBox(height: 16),
              _buildCategoryCard(Icons.directions_bus, 'help.bus_tracking'.tr()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(IconData icon, String title) {
    return GestureDetector(
      onTap: () => controller.openCategory(title.replaceAll('\n', ' ')),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.secondaryGreyBlue.withOpacity(0.1),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondaryGreyBlue.withOpacity(0.03),
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
                color: AppColors.primaryAccent.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primaryAccent, size: 20),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArticleTile(String title) {
    return GestureDetector(
      onTap: () => controller.openArticle(title),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.secondaryGreyBlue.withOpacity(0.1),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondaryGreyBlue.withOpacity(0.02),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.secondaryGreyBlue,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: const Color(0xFF141A28), // Dark navy slate color from mockup
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: AppColors.primaryAccent,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.support_agent,
              color: AppColors.white,
              size: 24,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'help.still_need_help'.tr(),
            style: AppTextStyles.h2.copyWith(
              color: AppColors.white,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'help.support_desc'.tr(),
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white70,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: controller.contactSupport,
            icon: const Icon(Icons.chat, color: AppColors.white, size: 18),
            label: Text('help.contact_support'.tr(), style: AppTextStyles.buttonText),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryAccent,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }
}
