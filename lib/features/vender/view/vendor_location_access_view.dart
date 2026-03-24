import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:savarii/core/theme/app_colors.dart';
import 'package:savarii/core/theme/app_text_styles.dart';
import '../controllers/vendor_location_access_controller.dart';

class VendorLocationAccessView extends GetView<VendorLocationAccessController> {
  const VendorLocationAccessView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 24.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Logo and Branding
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryAccent.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.directions_bus,
                            color: AppColors.primaryAccent,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Savarii',
                          style: AppTextStyles.h2.copyWith(fontSize: 20),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // 2. Titles
                    Text(
                      'Location access\nis required',
                      style: AppTextStyles.h1.copyWith(
                        fontSize: 32,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Savarii collects location data to provide a seamless and real-time experience. We use this to:',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.secondaryGreyBlue,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // 3. Feature List
                    _buildFeatureItem(
                      icon: Icons.bus_alert,
                      iconColor: const Color(0xFF00A65A), // Green
                      title: 'Nearby Trips Instantly',
                      description:
                          'Quickly book trips available right where you are.',
                    ),
                    const SizedBox(height: 24),
                    _buildFeatureItem(
                      icon: Icons.monetization_on,
                      iconColor: const Color(0xFFF39C12), // Orange/Gold
                      title: 'Exact Fares Calculation',
                      description:
                          'Ensure accurate pricing based on precise distance.',
                    ),
                    const SizedBox(height: 24),
                    _buildFeatureItem(
                      icon: Icons.share_location,
                      iconColor: AppColors.primaryAccent, // Red
                      title: 'Track Driver in Real-time',
                      description:
                          'Know exactly where your driver is and when they\'ll arrive.',
                    ),
                    const SizedBox(height: 40),

                    // 4. Main Illustration (Using map.png as it exists in project)
                    Center(
                      child: Image.asset(
                        'assets/images/map.png',
                        height: 200,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.secondaryGreyBlue.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.map_outlined,
                                size: 60,
                                color: AppColors.secondaryGreyBlue,
                              ),
                              SizedBox(height: 16),
                              Text('Location Illustration Placeholder'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 5. Bottom Action Buttons
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: controller.enableLocationServices,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryAccent,
                      minimumSize: const Size(double.infinity, 54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'ENABLE LOCATION SERVICES',
                      style: AppTextStyles.buttonText.copyWith(fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: controller.skipForNow,
                    style: TextButton.styleFrom(
                      minimumSize: const Size(double.infinity, 54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Skip for now',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.primaryAccent,
                        fontWeight: FontWeight.bold,
                      ),
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

  // --- Sub-Widgets ---

  Widget _buildFeatureItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.secondaryGreyBlue,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
