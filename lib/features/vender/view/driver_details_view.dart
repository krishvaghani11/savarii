import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:savarii/core/theme/app_colors.dart';
import 'package:savarii/core/theme/app_text_styles.dart';

class DriverDetailsView extends StatelessWidget {
  const DriverDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> driver = Get.arguments ?? {};

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Driver Details', style: AppTextStyles.h3),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryDark),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Profile Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(24),
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
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: (driver['profileImage'] != null && driver['profileImage'].toString().isNotEmpty)
                        ? Image.network(
                            driver['profileImage'],
                            height: 120,
                            width: 120,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                          )
                        : _buildPlaceholder(),
                  ),
                  const SizedBox(height: 16),
                  Text(driver['name'] ?? 'Unknown', style: AppTextStyles.h2),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: (driver['status'] == 'ACTIVE' ? Colors.green : Colors.blue).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      driver['status'] ?? 'INACTIVE',
                      style: AppTextStyles.caption.copyWith(
                        color: driver['status'] == 'ACTIVE' ? Colors.green.shade700 : Colors.blue.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 2. Info Sections
            _buildDetailSection(
              title: 'Contact Information',
              icon: Icons.contact_phone_outlined,
              details: [
                _buildDetailRow('Phone', driver['phone'] ?? 'N/A'),
                _buildDetailRow('Email', driver['email'] ?? 'N/A'),
                _buildDetailRow('Alt Phone', driver['altPhone'] ?? 'N/A'),
              ],
            ),
            const SizedBox(height: 16),

            _buildDetailSection(
              title: 'Identification',
              icon: Icons.badge_outlined,
              details: [
                _buildDetailRow('DL Number', driver['dlNumber'] ?? 'N/A'),
                _buildDetailRow('Aadhar Number', driver['aadharNumber'] ?? 'N/A'),
                const SizedBox(height: 16),
                _buildImageLabel('Driving License'),
                const SizedBox(height: 8),
                _buildDocImage(driver['dlImage']),
                const SizedBox(height: 16),
                _buildImageLabel('Aadhar Card'),
                const SizedBox(height: 8),
                _buildDocImage(driver['aadharImage']),
              ],
            ),
            const SizedBox(height: 16),

            _buildDetailSection(
              title: 'Address',
              icon: Icons.location_on_outlined,
              details: [
                _buildDetailRow('Street', driver['street'] ?? 'N/A'),
                _buildDetailRow('City/State', '${driver['city'] ?? 'N/A'}, ${driver['state'] ?? 'N/A'}'),
                _buildDetailRow('PIN Code', driver['pinCode'] ?? 'N/A'),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 120,
      width: 120,
      color: AppColors.secondaryGreyBlue.withOpacity(0.1),
      child: const Icon(Icons.person, size: 60, color: AppColors.secondaryGreyBlue),
    );
  }

  Widget _buildDetailSection({required String title, required IconData icon, required List<Widget> details}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primaryAccent),
              const SizedBox(width: 8),
              Text(title, style: AppTextStyles.h3.copyWith(fontSize: 14)),
            ],
          ),
          const Divider(height: 24),
          ...details,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.secondaryGreyBlue)),
          Text(value, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildImageLabel(String label) {
    return Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.primaryDark, fontWeight: FontWeight.bold));
  }

  Widget _buildDocImage(String? url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: (url != null && url.isNotEmpty)
          ? Image.network(
              url,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _buildImageError(),
            )
          : _buildImageError(),
    );
  }

  Widget _buildImageError() {
    return Container(
      height: 150,
      width: double.infinity,
      color: AppColors.secondaryGreyBlue.withOpacity(0.05),
      child: const Center(child: Icon(Icons.image_not_supported_outlined, color: AppColors.secondaryGreyBlue)),
    );
  }
}
