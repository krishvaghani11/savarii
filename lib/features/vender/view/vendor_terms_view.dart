import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:savarii/core/theme/app_colors.dart';
import 'package:savarii/core/theme/app_text_styles.dart';
import '../controllers/vendor_terms_controller.dart';

class VendorTermsView extends GetView<VendorTermsController> {
  const VendorTermsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text('Terms & Conditions', style: AppTextStyles.h3),
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
                  horizontal: 20.0,
                  vertical: 16.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Introduction Card
                    _buildTermCard(
                      title: 'Introduction',
                      content:
                          'Welcome to the Savarii Vendor app. These terms and conditions outline the rules and regulations for the use of Savarii\'s platform. By using this service, you agree to comply with all guidelines listed below.',
                    ),
                    const SizedBox(height: 16),

                    // Term 1
                    _buildTermCard(
                      number: '1',
                      title: 'Acceptance of Terms',
                      // Replace this placeholder string with your actual asset path, e.g., 'assets/images/signing_document.png'
                      imageAsset: 'assets/images/tern.png',
                      content:
                          'By accessing this app, we assume you accept these terms and conditions. Do not continue to use Savarii if you do not agree to all of the terms.',
                    ),
                    const SizedBox(height: 16),

                    // Term 2
                    _buildTermCard(
                      number: '2',
                      title: 'Vendor Obligations',
                      content:
                          'Vendors must provide accurate business documentation, maintain product quality standards, and fulfill orders within the specified timeframe. Failure to maintain service levels may result in account suspension.',
                    ),
                    const SizedBox(height: 16),

                    // Term 3
                    _buildTermCard(
                      number: '3',
                      title: 'Service Fees & Payments',
                      content:
                          'Savarii charges a standard commission on every successful transaction. Payments are processed on a weekly basis after deducting applicable service fees and taxes as mandated by local regulations.',
                    ),
                    const SizedBox(height: 16),

                    // Term 4
                    _buildTermCard(
                      number: '4',
                      title: 'Termination of Service',
                      content:
                          'Either party may terminate this agreement with a 30-day written notice. Savarii reserves the right to terminate accounts immediately for fraudulent activities or severe policy violations.',
                    ),
                    const SizedBox(height: 16),

                    // Term 5
                    _buildTermCard(
                      number: '5',
                      title: 'Limitation of Liability',
                      content:
                          'Savarii shall not be liable for any indirect, incidental, or consequential damages resulting from the use of the service or the inability to access the vendor dashboard.',
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // Sticky Footer Section
            _buildStickyFooter(),
          ],
        ),
      ),
    );
  }

  // --- Sub-Widgets ---

  Widget _buildTermCard({
    String? number,
    required String title,
    String? imageAsset,
    required String content,
  }) {
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
          // Header Row (Number Badge + Title)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (number != null) ...[
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.primaryAccent.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      number,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primaryAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.h3.copyWith(
                    fontSize: 16,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Optional Image
          if (imageAsset != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                imageAsset,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 120,
                  width: double.infinity,
                  color: AppColors.secondaryGreyBlue.withOpacity(0.1),
                  child: const Icon(
                    Icons.edit_document,
                    color: AppColors.secondaryGreyBlue,
                    size: 40,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Content Text
          Text(
            content,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.secondaryGreyBlue.withOpacity(0.9),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickyFooter() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      decoration: BoxDecoration(color: AppColors.lightBackground),
      child: Column(
        children: [
          ElevatedButton(
            onPressed: controller.acceptTerms,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryAccent,
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'I Accept',
                  style: AppTextStyles.buttonText.copyWith(fontSize: 16),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.check_circle,
                  color: AppColors.white,
                  size: 20,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Last updated: October 2023',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.secondaryGreyBlue,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
