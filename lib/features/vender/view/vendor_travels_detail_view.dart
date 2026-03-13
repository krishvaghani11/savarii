import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:savarii/core/constants/app_assets.dart';
import 'package:savarii/core/theme/app_colors.dart';
import 'package:savarii/core/theme/app_text_styles.dart';
import '../controllers/vendor_travels_detail_controller.dart';

class VendorTravelsDetailView extends GetView<VendorTravelsDetailController> {
  const VendorTravelsDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Text('Travels Detail', style: AppTextStyles.h3),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryDark),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 16.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Header Card (Image, Badges, Stats)
                    _buildHeaderCard(),
                    const SizedBox(height: 24),

                    // 2. BUSINESS INFORMATION
                    _buildSectionTitle('BUSINESS INFORMATION'),
                    _buildBusinessInfoCard(),
                    const SizedBox(height: 24),

                    // 3. OPERATIONAL COVERAGE
                    _buildSectionTitle('OPERATIONAL COVERAGE'),
                    _buildCoverageCard(),
                    const SizedBox(height: 24),

                    // 4. CONTACT INFORMATION
                    _buildSectionTitle('CONTACT INFORMATION'),
                    _buildContactInfoCard(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // 5. Sticky Bottom Button
            _buildStickyEditButton(),
          ],
        ),
      ),
    );
  }

  // --- Sub-Widgets ---

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.secondaryGreyBlue,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryGreyBlue.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bus Image
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  AppAssets.busImagePlaceholder, // Use your bus asset here
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 80,
                    height: 80,
                    color: AppColors.secondaryGreyBlue.withOpacity(0.2),
                    child: const Icon(
                      Icons.directions_bus,
                      color: AppColors.secondaryGreyBlue,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Name and Badges
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _buildBadge(
                          'VERIFIED',
                          AppColors.primaryAccent.withOpacity(0.1),
                          AppColors.primaryAccent,
                        ),
                        const SizedBox(width: 8),
                        _buildBadge(
                          'SAVARII PARTNER',
                          AppColors.secondaryGreyBlue.withOpacity(0.1),
                          AppColors.primaryDark,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      controller.travelsName,
                      style: AppTextStyles.h2.copyWith(
                        fontSize: 18,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          color: AppColors.secondaryGreyBlue,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          controller.establishedDate,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.secondaryGreyBlue,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Divider(
            color: AppColors.secondaryGreyBlue.withOpacity(0.1),
            height: 1,
          ),
          const SizedBox(height: 16),
          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatCol(controller.fleetSize, 'FLEET SIZE'),
              Container(
                width: 1,
                height: 30,
                color: AppColors.secondaryGreyBlue.withOpacity(0.1),
              ),
              _buildStatCol(controller.rating, 'RATING', isRating: true),
              Container(
                width: 1,
                height: 30,
                color: AppColors.secondaryGreyBlue.withOpacity(0.1),
              ),
              _buildStatCol(controller.routes, 'ROUTES'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: AppTextStyles.caption.copyWith(
          fontSize: 8,
          fontWeight: FontWeight.bold,
          color: textColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildStatCol(String value, String label, {bool isRating = false}) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(value, style: AppTextStyles.h2.copyWith(fontSize: 18)),
            if (isRating) ...[
              const SizedBox(width: 2),
              const Icon(Icons.star, color: AppColors.primaryAccent, size: 16),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.secondaryGreyBlue,
            fontSize: 10,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildBusinessInfoCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryGreyBlue.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoTile(
            Icons.badge_outlined,
            'REGISTRATION NUMBER',
            controller.regNumber,
          ),
          _buildInfoTile(
            Icons.receipt_long_outlined,
            'GST NUMBER',
            controller.gstNumber,
          ),
          _buildInfoTile(
            Icons.domain_outlined,
            'BUSINESS TYPE',
            controller.businessType,
          ),
          _buildInfoTile(
            Icons.person_outline,
            'OWNER NAME',
            controller.ownerName,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildCoverageCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
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
          Text(
            'PRIMARY ROUTES COVERED',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.secondaryGreyBlue,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            controller.primaryRoutes,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          // Map Snapshot
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  AppAssets.locationMapImage, // Your map asset
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 120,
                    color: AppColors.secondaryGreyBlue.withOpacity(0.1),
                  ),
                ),
              ),
              Positioned(
                bottom: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 4),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.circle,
                        color: AppColors.primaryAccent,
                        size: 8,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Live Operations Active',
                        style: AppTextStyles.caption.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfoCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryGreyBlue.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoTile(
            Icons.phone_in_talk_outlined,
            'PRIMARY MOBILE',
            controller.primaryMobile,
            trailingIcon: Icons.copy,
            onTrailingTap: () => controller.copyToClipboard(
              controller.primaryMobile,
              "Mobile Number",
            ),
          ),
          _buildInfoTile(
            Icons.email_outlined,
            'SUPPORT EMAIL',
            controller.supportEmail,
            trailingIcon: Icons.send,
            onTrailingTap: controller.sendEmail,
          ),
          _buildInfoTile(
            Icons.location_on_outlined,
            'OFFICE ADDRESS',
            controller.officeAddress,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(
    IconData icon,
    String label,
    String value, {
    bool isLast = false,
    IconData? trailingIcon,
    VoidCallback? onTrailingTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.secondaryGreyBlue.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primaryDark, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.secondaryGreyBlue,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          if (trailingIcon != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onTrailingTap,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryAccent.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  trailingIcon,
                  color: AppColors.primaryAccent,
                  size: 16,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStickyEditButton() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.lightBackground,
        border: Border(
          top: BorderSide(color: AppColors.secondaryGreyBlue.withOpacity(0.1)),
        ),
      ),
      child: ElevatedButton.icon(
        onPressed: controller.editTravelsDetail,
        icon: const Icon(Icons.edit, color: AppColors.white, size: 18),
        label: Text(
          'Edit Travels Detail',
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
    );
  }
}
