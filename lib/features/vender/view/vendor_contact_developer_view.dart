import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:savarii/core/theme/app_colors.dart';
import 'package:savarii/core/theme/app_text_styles.dart';
import '../controllers/vendor_contact_developer_controller.dart';

class VendorContactDeveloperView
    extends GetView<VendorContactDeveloperController> {
  const VendorContactDeveloperView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Text('Contact Developer', style: AppTextStyles.h3),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryDark),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Header Section
              Text(
                'How can we help?',
                style: AppTextStyles.h1.copyWith(fontSize: 24),
              ),
              const SizedBox(height: 8),
              Text(
                'Our development team is here to assist Savarii Vendors with technical issues, feature requests, or app feedback.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.secondaryGreyBlue,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),

              // 2. Support Options Cards
              _buildSupportOptionCard(
                title: 'Email Support',
                subtitle: controller.supportEmail,
                buttonText: 'Send Email',
                buttonColor: AppColors.primaryAccent,
                iconData: Icons.email,
                iconColor: AppColors.primaryAccent,
                iconBgColor: AppColors.primaryAccent.withOpacity(0.1),
                onTap: controller.sendEmail,
              ),
              const SizedBox(height: 16),
              _buildSupportOptionCard(
                title: 'WhatsApp Chat',
                subtitle: 'Chat with us live',
                buttonText: 'Start Chat',
                buttonColor: const Color(0xFF2A2D3E),
                // Dark slate color from the mockup
                iconData: Icons.chat,
                iconColor: const Color(0xFF2A2D3E),
                iconBgColor: AppColors.secondaryGreyBlue.withOpacity(0.15),
                onTap: controller.startWhatsAppChat,
              ),
              const SizedBox(height: 32),

              // 3. Direct Message Form
              Text(
                'Send us a message',
                style: AppTextStyles.h3.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.secondaryGreyBlue.withOpacity(0.1),
                  ),
                ),
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildLabel('Subject'),
                      _buildTextField(
                        controller: controller.subjectController,
                        hint: 'Technical issue, billing, feedback...',
                      ),
                      const SizedBox(height: 16),
                      _buildLabel('Message'),
                      _buildTextField(
                        controller: controller.messageController,
                        hint: 'Describe your issue or request in detail...',
                        maxLines: 4,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: controller.sendMessage,
                        icon: const Icon(
                          Icons.send,
                          color: AppColors.white,
                          size: 18,
                        ),
                        label: Text(
                          'Send Message',
                          style: AppTextStyles.buttonText,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryAccent,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // 4. Footer Text
              Center(
                child: Text(
                  'Typical response time: 2-4 business hours\nAvailable Mon-Fri, 9AM - 6PM',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.secondaryGreyBlue.withOpacity(0.6),
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // --- Sub-Widgets ---

  Widget _buildSupportOptionCard({
    required String title,
    required String subtitle,
    required String buttonText,
    required Color buttonColor,
    required IconData iconData,
    required Color iconColor,
    required Color iconBgColor,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.secondaryGreyBlue.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryGreyBlue.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
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
                  subtitle,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.secondaryGreyBlue,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                    minimumSize: const Size(0, 36),
                  ),
                  child: Text(
                    buttonText,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(iconData, color: iconColor, size: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: AppTextStyles.caption.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.primaryDark,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white, // Setting to white as per mockup form
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.secondaryGreyBlue.withOpacity(0.2)),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        validator: (value) => value!.isEmpty ? 'This field is required' : null,
        style: AppTextStyles.bodyMedium,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.secondaryGreyBlue.withOpacity(0.6),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}
