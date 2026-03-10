import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:savarii/features/customer/home/controller/report_issue_controller.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class ReportIssueView extends GetView<ReportIssueController> {
  const ReportIssueView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Text('Report an Issue', style: AppTextStyles.h3),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryDark),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Recent Trip Details Card
              _buildTripCard(),
              const SizedBox(height: 24),

              // 2. Issue Category Dropdown
              _buildSectionTitle('Issue Category'),
              _buildDropdown(),
              const SizedBox(height: 20),

              // 3. Description Text Box
              _buildSectionTitle('Description'),
              _buildDescriptionBox(),
              const SizedBox(height: 20),

              // 4. Upload Proof Box
              _buildSectionTitle('Upload Proof (Optional)'),
              _buildUploadBox(),

              const SizedBox(height: 120), // Buffer for the bottom button area
            ],
          ),
        ),
      ),
      // Bottom Sticky Section
      bottomNavigationBar: _buildBottomSection(),
    );
  }

  // --- Sub-Widgets ---

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(title, style: AppTextStyles.h3.copyWith(fontSize: 14)),
    );
  }

  Widget _buildTripCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secondaryGreyBlue.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryGreyBlue.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'RECENT TRIP',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.secondaryGreyBlue,
                    letterSpacing: 1,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  controller.tripTitle,
                  style: AppTextStyles.h3.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  controller.tripDate,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.secondaryGreyBlue,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              controller.tripImage,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 60,
                height: 60,
                color: AppColors.lightBackground,
                child: const Icon(
                  Icons.directions_bus,
                  color: AppColors.secondaryGreyBlue,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secondaryGreyBlue.withOpacity(0.2)),
      ),
      child: Obx(
        () => DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: controller.selectedCategory.value,
            hint: Text(
              'Select what went wrong',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.secondaryGreyBlue.withOpacity(0.6),
              ),
            ),
            isExpanded: true,
            icon: const Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.secondaryGreyBlue,
            ),
            items: controller.issueCategories.map((String category) {
              return DropdownMenuItem<String>(
                value: category,
                child: Text(category, style: AppTextStyles.bodyLarge),
              );
            }).toList(),
            onChanged: controller.selectCategory,
          ),
        ),
      ),
    );
  }

  Widget _buildDescriptionBox() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secondaryGreyBlue.withOpacity(0.2)),
      ),
      child: TextField(
        controller: controller.descriptionController,
        maxLines: 5,
        style: AppTextStyles.bodyLarge,
        decoration: InputDecoration(
          hintText:
              'Tell us more about what happened. Please\nbe as specific as possible...',
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.secondaryGreyBlue.withOpacity(0.5),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildUploadBox() {
    return GestureDetector(
      onTap: controller.uploadProof,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 30),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          // Tip: For a true dashed line, you can install the 'dotted_border' package later!
          border: Border.all(
            color: AppColors.secondaryGreyBlue.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.camera_alt,
              color: AppColors.secondaryGreyBlue,
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              'Add photos or screenshots',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.secondaryGreyBlue,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Maximum size 10MB per file',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.secondaryGreyBlue.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      decoration: BoxDecoration(color: AppColors.lightBackground),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: controller.submitReport,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryAccent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Submit Report', style: AppTextStyles.buttonText),
                  const SizedBox(width: 8),
                  const Icon(Icons.send, color: AppColors.white, size: 18),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Our support team typically responds within 24 hours.',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.secondaryGreyBlue.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
