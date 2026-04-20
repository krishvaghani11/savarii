import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:savarii/core/theme/app_colors.dart';
import 'package:savarii/core/theme/app_text_styles.dart';
import 'package:savarii/features/driver/controller/driver_location_access_controller.dart';


class DriverLocationAccessView extends GetView<DriverLocationAccessController> {
  const DriverLocationAccessView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Location Access',
          style: AppTextStyles.h3.copyWith(color: const Color(0xFF2A2D3E)), // Dark Navy
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryAccent), // Red arrow as per mockup
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 1),

              // 1. Map & Bus Graphic (Native Flutter Recreation)
              _buildLocationGraphic(),
              
              const Spacer(flex: 1),

              // 2. Titles & Description
              Text(
                'Enable Location\nTracking',
                textAlign: TextAlign.center,
                style: AppTextStyles.h1.copyWith(
                  fontSize: 28,
                  color: const Color(0xFF2A2D3E), // Dark Navy
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'To receive bus assignments, provide\nreal-time updates to passengers, and\ntrack your route, please enable location\naccess.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.secondaryGreyBlue,
                  height: 1.5,
                ),
              ),
              
              const Spacer(flex: 2),

              // 3. Allow Button
              ElevatedButton(
                onPressed: controller.allowLocationAccess,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryAccent,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28), // Pill shape
                  ),
                  elevation: 8,
                  shadowColor: AppColors.primaryAccent.withOpacity(0.4),
                ),
                child: Text(
                  'Allow Location Access',
                  style: AppTextStyles.buttonText.copyWith(fontSize: 16),
                ),
              ),
              const SizedBox(height: 24),

              // 4. Skip Button
              GestureDetector(
                onTap: controller.skipForNow,
                child: Center(
                  child: Text(
                    'Skip for Now',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: const Color(0xFF2A2D3E), // Dark Navy
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }

  // --- Native Flutter Graphic Recreation ---
  Widget _buildLocationGraphic() {
    return Center(
      child: Container(
        height: 250,
        width: 250,
        decoration: BoxDecoration(
          color: const Color(0xFFF7F8FA), // Very light grey background simulating the map container
          borderRadius: BorderRadius.circular(40),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Faint grid lines to simulate a map
            CustomPaint(
              size: const Size(250, 250),
              painter: MapGridPainter(),
            ),
            
            // Central Bus Icon & Dots
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Red glowing circle with bus icon
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primaryAccent,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryAccent.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.directions_bus,
                    color: AppColors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Three pulsing dots
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildDot(opacity: 1.0),
                    const SizedBox(width: 6),
                    _buildDot(opacity: 0.6),
                    const SizedBox(width: 6),
                    _buildDot(opacity: 0.3),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDot({required double opacity}) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: AppColors.primaryAccent.withOpacity(opacity),
        shape: BoxShape.circle,
      ),
    );
  }
}

// A simple custom painter to draw faint intersecting lines that look like a street map
class MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    final path = Path();
    // Simulate some random street lines
    path.moveTo(0, size.height * 0.3);
    path.quadraticBezierTo(size.width * 0.5, size.height * 0.4, size.width, size.height * 0.2);
    
    path.moveTo(size.width * 0.2, 0);
    path.lineTo(size.width * 0.4, size.height);
    
    path.moveTo(0, size.height * 0.7);
    path.quadraticBezierTo(size.width * 0.6, size.height * 0.8, size.width, size.height * 0.6);

    path.moveTo(size.width * 0.8, 0);
    path.lineTo(size.width * 0.6, size.height);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}