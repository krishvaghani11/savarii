import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:savarii/core/constants/app_assets.dart';
import 'package:savarii/core/theme/app_colors.dart';
import 'package:savarii/core/theme/app_text_styles.dart';
import 'package:savarii/features/customer/home/controller/parcel_confirmation_controller.dart';

class ParcelConfirmationView extends GetView<ParcelConfirmationController> {
  const ParcelConfirmationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text('Confirmation', style: AppTextStyles.h3),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryDark),
          onPressed: controller
              .backToHome, // Route home on back to prevent going back to payment
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Success Graphic
              _buildSuccessGraphic(),
              const SizedBox(height: 32),

              // 2. Success Text
              Text(
                'Parcel Booked\nSuccessfully!',
                textAlign: TextAlign.center,
                style: AppTextStyles.h1.copyWith(fontSize: 24, height: 1.3),
              ),
              const SizedBox(height: 12),
              Text(
                'Your request has been received. Our courier will\narrive shortly to pick up your package.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.secondaryGreyBlue,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              // 3. Tracking Details Card
              _buildTrackingCard(),
              const SizedBox(height: 40),

              // 4. Action Buttons
              _buildActionButtons(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // --- Sub-Widgets ---

  Widget _buildSuccessGraphic() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Image.asset(
        AppAssets.parcelSuccessImage, // The path to your 3D box graphic
        height: 200,
        width: 200,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          height: 200,
          width: 200,
          decoration: BoxDecoration(
            color: AppColors.secondaryGreyBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.inventory_2,
            size: 80,
            color: AppColors.primaryAccent,
          ),
        ),
      ),
    );
  }

  Widget _buildTrackingCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryGreyBlue.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Tracking ID Label & Copy Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TRACKING ID',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.secondaryGreyBlue,
                  letterSpacing: 1,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: controller.copyTrackingId,
                child: const Icon(
                  Icons.copy,
                  color: AppColors.primaryAccent,
                  size: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Row 2: Icon and ID Details
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryAccent.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.inventory_2,
                  color: AppColors.primaryAccent,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.trackingId,
                    style: AppTextStyles.h2.copyWith(fontSize: 20),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Savarii Express Delivery',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.secondaryGreyBlue,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Row 3: Download Invoice Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: controller.downloadInvoice,
              icon: const Icon(
                Icons.download_outlined,
                color: AppColors.primaryAccent,
                size: 18,
              ),
              label: Text(
                'Download Invoice',
                style: AppTextStyles.buttonText.copyWith(
                  color: AppColors.primaryAccent,
                  fontSize: 14,
                ),
              ),
              style: OutlinedButton.styleFrom(
                backgroundColor: AppColors.primaryAccent.withOpacity(0.05),
                side: BorderSide(
                  color: AppColors.primaryAccent.withOpacity(0.2),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),
          Divider(
            color: AppColors.secondaryGreyBlue.withOpacity(0.2),
            height: 1,
          ),
          const SizedBox(height: 20),

          // Row 4: Estimated Pickup
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Estimated Pickup',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.secondaryGreyBlue,
                ),
              ),
              Text(
                '10:30 AM Today',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Track Parcel Button (Solid Red)
        ElevatedButton.icon(
          onPressed: controller.trackParcel,
          icon: const Icon(Icons.location_on, color: AppColors.white, size: 18),
          label: Text('Track Parcel', style: AppTextStyles.buttonText),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryAccent,
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
        ),
        const SizedBox(height: 16),

        // Back to Home Button (Light/Transparent)
        ElevatedButton(
          onPressed: controller.backToHome,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryAccent.withOpacity(0.08),
            foregroundColor: AppColors.primaryDark,
            // Dark text
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: Text(
            'Back to Home',
            style: AppTextStyles.buttonText.copyWith(
              color: AppColors.primaryDark,
            ),
          ),
        ),
      ],
    );
  }
}
