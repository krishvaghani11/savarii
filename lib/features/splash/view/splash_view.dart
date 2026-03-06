import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:savarii/core/theme/app_colors.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/theme/app_text_styles.dart';
import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: Stack(
        children: [
          // 1. Layer 1: The Map Background Pattern
          // We use Opacity to blend your map image perfectly into the dark background
          Positioned.fill(
            child: Opacity(
              opacity: 0.3, // Adjusted to match the faintness in your mockup
              child: Image.asset(
                AppAssets.mapBackgroundPattern, // Your Image.jpg
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 2. Layer 2: The Center Content (Logo & Text)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Red Logo Box with Custom Glow
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: AppColors.primaryAccent,
                    borderRadius: BorderRadius.circular(22),
                    // Matched corner radius
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryAccent.withOpacity(0.4),
                        blurRadius: 35, // High blur for that soft glow
                        spreadRadius: 2,
                        offset: const Offset(0, 5), // Slight drop shadow
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.directions_car_filled,
                      // Closest Material icon to your mockup
                      color: AppColors.white,
                      size: 50,
                    ),
                  ),
                ),
                const SizedBox(height: 30), // Spacing below logo
                // App Name
                Text(
                  'Savarii',
                  style: AppTextStyles.h1.copyWith(
                    color: AppColors.white,
                    fontSize: 36,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12),

                // Subtitle
                Text(
                  'Your Local Travel & Parcel Partner',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.secondaryGreyBlue,
                  ),
                ),
              ],
            ),
          ),

          // 3. Layer 3: Bottom Loader and Version
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Centered Loader Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 60),
                  // Matched padding from edges
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Container(
                        height: 4, // Thin bar just like the screenshot
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.secondaryGreyBlue.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Stack(
                          children: [
                            // Reactive progressing bar
                            Obx(
                              () => Container(
                                width:
                                    constraints.maxWidth *
                                    controller.progress.value,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryAccent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),

                // Version Info
                Text(
                  'v1.0.2',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.secondaryGreyBlue.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
