import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:savarii/core/theme/app_colors.dart';
import 'package:savarii/core/theme/app_text_styles.dart';
import 'package:savarii/features/driver/controller/driver_documents_controller.dart';

class DriverDocumentsView extends GetView<DriverDocumentsController> {
  const DriverDocumentsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'My Documents',
          style: AppTextStyles.h2.copyWith(color: const Color(0xFF2A2D3E)),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryAccent),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryAccent),
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            children: [
              // ── Info Note Banner ────────────────────────────────────────
              _buildInfoBanner(),
              const SizedBox(height: 20),

              // ── Document Cards ──────────────────────────────────────────
              ...List.generate(controller.documents.length, (index) {
                final doc = controller.documents[index];
                return _buildDocumentCard(doc, index);
              }),
            ],
          );
        }),
      ),
    );
  }

  // ── Info Banner ──────────────────────────────────────────────────────────

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1), // warm amber tint
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFCC02).withOpacity(0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.lightbulb_outline_rounded,
            color: Color(0xFFF9A825),
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Document Upload Guidelines',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF5D4037),
                  ),
                ),
                const SizedBox(height: 6),
                _infoLine('Max file size: 1 MB per document'),
                _infoLine('Accepted formats: PDF, JPEG'),
                _infoLine('Ensure all text and details are clearly visible'),
                _infoLine('Uploaded documents are reviewed by your vendor'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoLine(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: Color(0xFF8D6E63))),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.caption.copyWith(
                color: const Color(0xFF6D4C41),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Document Card ────────────────────────────────────────────────────────

  Widget _buildDocumentCard(Map<String, dynamic> doc, int index) {
    final String docId = doc['id'];
    final bool hasUploaded = doc['hasUploaded'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryGreyBlue.withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // 1. Icon circle
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryAccent.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              doc['icon'] as IconData,
              color: AppColors.primaryAccent,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),

          // 2. Title (and uploaded file name if any)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doc['title'],
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2A2D3E),
                  ),
                ),
                if (hasUploaded && (doc['fileName'] as String).isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text(
                      doc['fileName'],
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.secondaryGreyBlue.withOpacity(0.7),
                        fontSize: 11,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // 3. Action button — Add / View / Uploading spinner
          Obx(() {
            final uploading = controller.isUploading(docId);
            return SizedBox(
              height: 40,
              child: ElevatedButton(
                onPressed: uploading
                    ? null
                    : () => hasUploaded
                        ? controller.viewDocument(index)
                        : controller.uploadDocument(index),
                style: ElevatedButton.styleFrom(
                  backgroundColor: uploading
                      ? AppColors.secondaryGreyBlue.withOpacity(0.15)
                      : hasUploaded
                          ? AppColors.secondaryGreyBlue.withOpacity(0.15)
                          : AppColors.primaryAccent,
                  foregroundColor: hasUploaded || uploading
                      ? const Color(0xFF2A2D3E)
                      : AppColors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  minimumSize: Size.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: uploading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: AppColors.primaryAccent,
                        ),
                      )
                    : Text(
                        hasUploaded ? 'View' : 'Add',
                        style: AppTextStyles.buttonText.copyWith(
                          color: hasUploaded
                              ? const Color(0xFF2A2D3E)
                              : AppColors.white,
                          fontSize: 13,
                        ),
                      ),
              ),
            );
          }),
        ],
      ),
    );
  }
}