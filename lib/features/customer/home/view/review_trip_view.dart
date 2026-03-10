import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:savarii/features/customer/home/controller/review_trip_controller.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class ReviewTripView extends GetView<ReviewTripController> {
  const ReviewTripView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Text('Review Your Trip', style: AppTextStyles.h3),
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
              // 1. Trip Summary Card
              _buildTripSummaryCard(),
              const SizedBox(height: 16),

              // 2. Overall Experience Card
              _buildOverallExperienceCard(),
              const SizedBox(height: 16),

              // 3. Specific Criteria Card
              _buildSpecificCriteriaCard(),
              const SizedBox(height: 16),

              // 4. Additional Feedback Card
              _buildFeedbackCard(),

              const SizedBox(height: 24), // Buffer before sticky button
            ],
          ),
        ),
      ),
      // Sticky Bottom Button
      bottomNavigationBar: _buildSubmitButton(),
    );
  }

  // --- Sub-Widgets ---

  Widget _buildTripSummaryCard() {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: Image.asset(
              AppAssets.busExteriorImage,
              // Make sure you have this asset or replace with a placeholder
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 120,
                color: AppColors.secondaryGreyBlue.withOpacity(0.2),
                child: const Icon(
                  Icons.directions_bus,
                  size: 40,
                  color: AppColors.secondaryGreyBlue,
                ),
              ),
            ),
          ),

          // Trip Details
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'OCT 24, 2023',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primaryAccent,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'COMPLETED',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primaryAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Savarii Express',
                  style: AppTextStyles.h2.copyWith(fontSize: 22),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: AppColors.secondaryGreyBlue,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Mumbai',
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
                      'Pune',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.secondaryGreyBlue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverallExperienceCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
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
        children: [
          Text('Overall Experience', style: AppTextStyles.h3),
          const SizedBox(height: 16),
          // Interactive Large Stars
          Obx(
            () => _buildStarRow(
              currentRating: controller.overallRating.value,
              onRatingChanged: controller.setOverallRating,
              starSize: 40,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Tap to rate your overall journey',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.secondaryGreyBlue,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecificCriteriaCard() {
    return Container(
      padding: const EdgeInsets.all(20),
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
          Text('Rate specific criteria', style: AppTextStyles.h3),
          const SizedBox(height: 24),

          // Driver Behavior
          Obx(
            () => _buildCriteriaRow(
              title: 'Driver Behavior',
              subtitle: 'Courteousness and safe driving',
              currentRating: controller.driverRating.value,
              onRatingChanged: controller.setDriverRating,
            ),
          ),
          const SizedBox(height: 20),

          // Bus Cleanliness
          Obx(
            () => _buildCriteriaRow(
              title: 'Bus Cleanliness',
              subtitle: 'Seats, floor, and amenities',
              currentRating: controller.cleanlinessRating.value,
              onRatingChanged: controller.setCleanlinessRating,
            ),
          ),
          const SizedBox(height: 20),

          // Punctuality
          Obx(
            () => _buildCriteriaRow(
              title: 'Punctuality',
              subtitle: 'On-time departure and arrival',
              currentRating: controller.punctualityRating.value,
              onRatingChanged: controller.setPunctualityRating,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCriteriaRow({
    required String title,
    required String subtitle,
    required int currentRating,
    required Function(int) onRatingChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.secondaryGreyBlue,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        _buildStarRow(
          currentRating: currentRating,
          onRatingChanged: onRatingChanged,
          starSize: 22,
        ),
      ],
    );
  }

  // Helper widget to generate clickable stars
  Widget _buildStarRow({
    required int currentRating,
    required Function(int) onRatingChanged,
    required double starSize,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: () => onRatingChanged(index + 1), // Ratings are 1-5
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: starSize > 30 ? 6.0 : 2.0,
            ),
            child: Icon(
              Icons.star,
              // Using solid star for both, changing color to indicate selection
              color: index < currentRating
                  ? AppColors.primaryAccent
                  : AppColors.secondaryGreyBlue.withOpacity(0.3),
              size: starSize,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildFeedbackCard() {
    return Container(
      padding: const EdgeInsets.all(20),
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
          Text('Additional Feedback', style: AppTextStyles.h3),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.secondaryGreyBlue.withOpacity(0.2),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: controller.feedbackController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText:
                    'Share your experience or\nsuggestions for improvement\n(optional)...',
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.secondaryGreyBlue.withOpacity(0.6),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(color: AppColors.lightBackground),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: controller.submitReview,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryAccent,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: Text('Submit Review', style: AppTextStyles.buttonText),
        ),
      ),
    );
  }
}
