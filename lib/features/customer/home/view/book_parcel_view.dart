import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:savarii/core/theme/app_colors.dart';
import 'package:savarii/core/theme/app_text_styles.dart';
import 'package:savarii/features/customer/home/controller/book_parcel_controller.dart';

class BookParcelView extends GetView<BookParcelController> {
  const BookParcelView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Text('Book a Parcel', style: AppTextStyles.h3),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryDark),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.help_outline,
              color: AppColors.secondaryGreyBlue,
            ),
            onPressed: () {
              // Add help action here
            },
          ),
        ],
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
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. TOP STEPPER
                      _buildStepper(),
                      const SizedBox(height: 32),

                      // 2. LOCATION CARD (Pickup & Drop + Dynamic Timeline)
                      _buildLocationCard(context),
                      const SizedBox(height: 16),

                      // 3. PARCEL DETAILS CARD
                      _buildSectionCard(
                        icon: Icons.inventory_2,
                        title: 'Parcel Details',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('PARCEL TYPE'),
                            _buildDropdown(),
                            const SizedBox(height: 16),
                            _buildLabel('WEIGHT (KG)'),
                            _buildInputField(
                              controller: controller.weightController,
                              hint: '0.5',
                              keyboardType: TextInputType.number,
                              suffixText: 'KG',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 4. SENDER CONTACT INFORMATION
                      _buildSectionCard(
                        icon: Icons.person,
                        title: 'Sender Contact Information',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('FULL NAME'),
                            _buildInputField(
                              controller: controller.fullNameController,
                              hint: 'Enter sender full name',
                              prefixIcon: Icons.badge_outlined,
                            ),
                            const SizedBox(height: 16),
                            _buildLabel('MOBILE NUMBER'),
                            _buildInputField(
                              controller: controller.mobileController,
                              hint: 'Enter mobile number',
                              keyboardType: TextInputType.phone,
                              prefixText: '+91',
                            ),
                            const SizedBox(height: 16),
                            _buildLabel('EMAIL ID'),
                            _buildInputField(
                              controller: controller.emailController,
                              hint: 'Enter email address (Optional)',
                              keyboardType: TextInputType.emailAddress,
                              prefixIcon: Icons.alternate_email,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 5. RECEIVER CONTACT INFORMATION
                      _buildSectionCard(
                        icon: Icons.contact_mail, // Alternative distinct icon
                        title: 'Receiver Contact Information',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('FULL NAME'),
                            _buildInputField(
                              controller: controller.receiverNameController,
                              hint: 'Enter receiver full name',
                              prefixIcon: Icons.badge_outlined,
                            ),
                            const SizedBox(height: 16),
                            _buildLabel('MOBILE NUMBER'),
                            _buildInputField(
                              controller: controller.receiverMobileController,
                              hint: 'Enter mobile number',
                              keyboardType: TextInputType.phone,
                              prefixText: '+91',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 6. SPECIAL INSTRUCTIONS CARD
                      _buildSectionCard(
                        icon: Icons.sticky_note_2,
                        title: 'Special Instructions (Optional)',
                        child: _buildInputField(
                          controller: controller.notesController,
                          hint:
                              'E.g. Handle with care, ring the doorbell twice...',
                          maxLines: 4,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),

            // BOTTOM CONTINUE BUTTON
            _buildBottomButton(),
          ],
        ),
      ),
    );
  }

  // --- Sub-Widgets ---

  Widget _buildStepper() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepItem(step: '1', title: 'Details', isActive: true),
        _buildStepDivider(),
        _buildStepItem(step: '2', title: 'Review', isActive: false),
        _buildStepDivider(),
        _buildStepItem(step: '3', title: 'Payment', isActive: false),
      ],
    );
  }

  Widget _buildStepItem({
    required String step,
    required String title,
    required bool isActive,
  }) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primaryAccent
                : AppColors.secondaryGreyBlue.withOpacity(0.15),
            shape: BoxShape.circle,
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppColors.primaryAccent.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              step,
              style: AppTextStyles.bodyLarge.copyWith(
                color: isActive ? AppColors.white : AppColors.secondaryGreyBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: AppTextStyles.caption.copyWith(
            color: isActive
                ? AppColors.primaryAccent
                : AppColors.secondaryGreyBlue,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildStepDivider() {
    return Container(
      width: 40,
      height: 2,
      margin: const EdgeInsets.only(top: 18, left: 8, right: 8),
      color: AppColors.secondaryGreyBlue.withOpacity(0.2),
    );
  }

  Widget _buildLocationCard(BuildContext context) {
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
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Vertical Timeline Indicators (Dynamically stretches)
            Column(
              children: [
                const SizedBox(height: 34), // Aligns with the first input
                const Icon(
                  Icons.location_on,
                  color: AppColors.primaryAccent,
                  size: 20,
                ),
                Expanded(
                  child: Container(
                    width: 1,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: CustomPaint(painter: DottedLinePainter()),
                  ),
                ),
                const Icon(Icons.flag, color: AppColors.primaryDark, size: 20),
                const SizedBox(height: 38), // Buffer for the bottom text
              ],
            ),
            const SizedBox(width: 16),

            // Input Fields
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('PICKUP LOCATION'),
                  _buildCityAutocomplete(
                    controller: controller.pickupController,
                    hint: 'Enter pickup address',
                    icon: Icons.search,
                  ),
                  _buildResidentDetails(isPickup: true),
                  _buildAddResidentButton(isPickup: true, context: context),
                  const SizedBox(height: 24),
                  
                  _buildLabel('DROP LOCATION'),
                  _buildCityAutocomplete(
                    controller: controller.dropController,
                    hint: 'Enter delivery address',
                    icon: Icons.near_me,
                  ),
                  _buildResidentDetails(isPickup: false),
                  _buildAddResidentButton(isPickup: false, context: context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResidentDetails({required bool isPickup}) {
    return Obx(() {
      final details = isPickup
          ? controller.pickupResidentDetails.value
          : controller.dropResidentDetails.value;
          
      if (details == null) return const SizedBox.shrink();

      return Container(
        margin: const EdgeInsets.only(top: 8.0),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.secondaryGreyBlue.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.home_outlined, size: 16, color: AppColors.secondaryGreyBlue),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${details['flat']}, ${details['society']},\n${details['city']}, ${details['district']},\n${details['state']} - ${details['pincode']}',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primaryDark,
                  height: 1.4,
                ),
              ),
            ),
            GestureDetector(
              onTap: () => controller.clearResidentDetails(isPickup: isPickup),
              child: const Icon(Icons.close, size: 16, color: AppColors.secondaryGreyBlue),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildAddResidentButton({required bool isPickup, required BuildContext context}) {
    return GestureDetector(
      onTap: () => controller.openResidentSheet(isPickup: isPickup, context: context),
      child: Padding(
        padding: const EdgeInsets.only(top: 10.0, bottom: 4.0),
        child: Row(
          children: [
            const Icon(Icons.add, color: AppColors.primaryAccent, size: 16),
            const SizedBox(width: 4),
            Text(
              'Add a resident',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.primaryAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required Widget child,
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
          Row(
            children: [
              Icon(icon, color: AppColors.primaryAccent, size: 22),
              const SizedBox(width: 10),
              Text(
                title,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
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
          color: AppColors.secondaryGreyBlue,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    IconData? prefixIcon,
    String? prefixText,
    String? suffixText,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: maxLines > 1 ? 12 : 4, 
      ),
      child: Row(
        crossAxisAlignment: maxLines > 1
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          if (prefixIcon != null) ...[
            Padding(
              padding: EdgeInsets.only(top: maxLines > 1 ? 4 : 0),
              child: Icon(prefixIcon, color: AppColors.secondaryGreyBlue, size: 20),
            ),
            const SizedBox(width: 12),
          ],
          if (prefixText != null) ...[
            Text(
              prefixText,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.secondaryGreyBlue),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: TextFormField(
              controller: controller,
              maxLines: maxLines,
              keyboardType: keyboardType,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primaryDark),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.secondaryGreyBlue.withOpacity(0.6),
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          if (suffixText != null) ...[
            const SizedBox(width: 12),
            Text(
              suffixText,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primaryDark,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCityAutocomplete({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) async {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<String>.empty();
        }
        // Fetch suggestions and map to city name string
        final suggestions = await this.controller.getCitySuggestions(textEditingValue.text);
        return suggestions.map((s) => s.city).toList();
      },
      onSelected: (String selection) {
        controller.text = selection;
      },
      fieldViewBuilder: (
        BuildContext context,
        TextEditingController fieldTextEditingController,
        FocusNode fieldFocusNode,
        VoidCallback onFieldSubmitted,
      ) {
        // Sync the passed controller with the field's controller
        fieldTextEditingController.text = controller.text;
        fieldTextEditingController.addListener(() {
          controller.text = fieldTextEditingController.text;
        });

        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF7F8FA),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.secondaryGreyBlue, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: fieldTextEditingController,
                  focusNode: fieldFocusNode,
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primaryDark),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.secondaryGreyBlue.withOpacity(0.6),
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onFieldSubmitted: (String value) {
                    onFieldSubmitted();
                  },
                ),
              ),
            ],
          ),
        );
      },
      optionsViewBuilder: (
        BuildContext context,
        AutocompleteOnSelected<String> onSelected,
        Iterable<String> options,
      ) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4.0,
            borderRadius: BorderRadius.circular(12),
            color: AppColors.white,
            child: SizedBox(
              height: 200.0,
              width: MediaQuery.of(context).size.width - 80, // Approximate width
              child: ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: options.length,
                itemBuilder: (BuildContext context, int index) {
                  final String option = options.elementAt(index);
                  return GestureDetector(
                    onTap: () {
                      onSelected(option);
                    },
                    child: ListTile(
                      title: Text(option, style: AppTextStyles.bodyMedium),
                      leading: const Icon(Icons.location_city, color: AppColors.primaryAccent, size: 20),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Obx(
        () => DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: controller.selectedParcelType.value,
            isExpanded: true,
            icon: const Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.secondaryGreyBlue,
            ),
            items: controller.parcelTypes.map((String type) {
              return DropdownMenuItem<String>(
                value: type,
                child: Text(
                  type,
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primaryDark),
                ),
              );
            }).toList(),
            onChanged: controller.selectParcelType,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.lightBackground,
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryGreyBlue.withOpacity(0.05),
            blurRadius: 10, offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Obx(() {
        return ElevatedButton(
          onPressed: controller.isLoading.value ? null : controller.continueToReview,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryAccent,
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            elevation: 0,
          ),
          child: controller.isLoading.value
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Continue to Review',
                      style: AppTextStyles.buttonText.copyWith(fontSize: 16),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward, color: AppColors.white, size: 18),
                  ],
                ),
        );
      }),
    );
  }
}

// Custom Painter for the dotted vertical line in the location card
class DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double dashHeight = 4, dashSpace = 4, startY = 0;
    final paint = Paint()
      ..color = AppColors.secondaryGreyBlue.withOpacity(0.3)
      ..strokeWidth = 1.5;
    while (startY < size.height) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashHeight), paint);
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}