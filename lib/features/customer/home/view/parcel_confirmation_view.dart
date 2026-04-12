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
      backgroundColor: AppColors.lightBackground, // Light grey background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text('Confirmation', style: AppTextStyles.h3),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryDark),
          onPressed: controller.backToHome, // Route home to prevent going back to payment
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
                'Your request has been received. Our courier\nwill arrive shortly to pick up your package.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.secondaryGreyBlue,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              // 3. Tracking Details Card (Updated with timeline)
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
      borderRadius: BorderRadius.circular(24),
      child: Image.asset(
        AppAssets.parcelBoxImage, // Replace with your actual 3D box asset path
        height: 200,
        width: 200,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          height: 200,
          width: 200,
          decoration: BoxDecoration(
            color: AppColors.secondaryGreyBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(24),
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
          // Row 1: Icon, Tracking ID & Copy Button
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2D3E), // Dark navy color from mockup
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  color: AppColors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TRACKING ID',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.secondaryGreyBlue,
                        letterSpacing: 0.5,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      controller.trackingId,
                      style: AppTextStyles.h2.copyWith(fontSize: 18),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: controller.copyTrackingId,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryGreyBlue.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.copy_all,
                    color: AppColors.secondaryGreyBlue,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Row 2: Vertical Timeline (Pickup and Drop-off)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeline Dots and Line
              Column(
                children: [
                  const SizedBox(height: 6),
                  const Icon(
                    Icons.circle,
                    color: AppColors.primaryAccent,
                    size: 14,
                  ),
                  Container(
                    height: 50,
                    width: 1.5,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: CustomPaint(
                      painter: DottedLinePainter(),
                    ),
                  ),
                  const Icon(
                    Icons.circle,
                    color: AppColors.primaryDark,
                    size: 14,
                  ),
                ],
              ),
              const SizedBox(width: 16),
              // Timeline Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PICKUP',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.secondaryGreyBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      controller.pickupLocation,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    Text(
                      controller.pickupTime,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.secondaryGreyBlue,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'DROP-OFF',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.secondaryGreyBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      controller.dropoffLocation,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    Text(
                      controller.dropoffTime,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.secondaryGreyBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

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
                backgroundColor: AppColors.primaryAccent.withOpacity(0.05), // Light pink background
                side: BorderSide(
                  color: AppColors.primaryAccent.withOpacity(0.2), // Light red border
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
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Track Parcel Button (Solid Red)
        ElevatedButton.icon(
          onPressed: controller.trackParcel,
          icon: const Icon(Icons.location_on_outlined, color: AppColors.white, size: 20),
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
            backgroundColor: AppColors.white,
            foregroundColor: AppColors.primaryDark,
            side: BorderSide(color: AppColors.secondaryGreyBlue.withOpacity(0.2)),
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

// Custom Painter for the dotted vertical line in the timeline
class DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double dashHeight = 4, dashSpace = 4, startY = 0;
    final paint = Paint()
      ..color = AppColors.secondaryGreyBlue.withOpacity(0.4)
      ..strokeWidth = 1.5;
    while (startY < size.height) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashHeight), paint);
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}