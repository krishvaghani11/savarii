import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:savarii/core/theme/app_colors.dart';
import 'package:savarii/core/theme/app_text_styles.dart';
import 'package:savarii/features/customer/home/controller/add_passenger_controller.dart';


class CustomerAddPassengerView extends GetView<CustomerAddPassengerController> {
  const CustomerAddPassengerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground, // Standard light grey background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Text('Passenger Details', style: AppTextStyles.h3),
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
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. BOARDING & DROPPING SUMMARY
                    _buildSectionCard(
                      title: 'JOURNEY DETAILS',
                      child: Column(
                        children: [
                          _buildJourneyPoint(
                            title: 'Boarding Point',
                            location: controller.boardingPoint,
                            iconColor: AppColors.primaryAccent,
                          ),
                          const Padding(
                            padding: EdgeInsets.only(left: 11.0, top: 4.0, bottom: 4.0),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: SizedBox(
                                height: 20,
                                child: VerticalDivider(
                                  color: AppColors.secondaryGreyBlue,
                                  thickness: 1.5,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                          _buildJourneyPoint(
                            title: 'Dropping Point',
                            location: controller.droppingPoint,
                            iconColor: AppColors.primaryDark,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 2. PASSENGER LIST SECTION
                    _buildSectionCard(
                      title: 'PASSENGERS',
                      trailing: GestureDetector(
                        onTap: () => controller.openAddPassengerSheet(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primaryAccent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.add, color: AppColors.primaryAccent, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                'Add New',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.primaryAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      child: Obx(() {
                        if (controller.addedPassengers.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20.0),
                            child: Center(
                              child: Text(
                                'No passengers added yet.\nClick "Add New" to add passengers.',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.secondaryGreyBlue,
                                ),
                              ),
                            ),
                          );
                        }
                        return Column(
                          children: List.generate(
                            controller.addedPassengers.length,
                            (index) => _buildPassengerItem(index),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 16),

                    // 3. CONTACT DETAILS (For receiving tickets)
                    Form(
                      key: controller.contactFormKey,
                      child: _buildSectionCard(
                        title: 'CONTACT DETAILS',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your ticket will be sent to these details',
                              style: AppTextStyles.caption.copyWith(color: AppColors.secondaryGreyBlue),
                            ),
                            const SizedBox(height: 16),
                            _buildLabel('Email Address'),
                            _buildTextField('name@example.com', controller.emailController, keyboardType: TextInputType.emailAddress),
                            const SizedBox(height: 16),
                            _buildLabel('Mobile Number'),
                            _buildTextField('+91 00000 00000', controller.phoneController, keyboardType: TextInputType.phone),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // 4. Sticky Bottom Checkout Bar
            _buildCheckoutBar(),
          ],
        ),
      ),
    );
  }

  // --- Sub-Widgets ---

  Widget _buildSectionCard({required String title, Widget? trailing, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.secondaryGreyBlue.withOpacity(0.1)),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildJourneyPoint({required String title, required String location, required Color iconColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 4),
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(color: iconColor, width: 3),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.caption.copyWith(color: AppColors.secondaryGreyBlue)),
              const SizedBox(height: 4),
              Text(location, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPassengerItem(int index) {
    final passenger = controller.addedPassengers[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondaryGreyBlue.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secondaryGreyBlue.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.secondaryGreyBlue.withOpacity(0.2)),
            ),
            child: Icon(
              passenger['gender'] == 'Female' ? Icons.face_3 : Icons.face,
              color: AppColors.primaryDark,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  passenger['name'] ?? '',
                  style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                ),
                const SizedBox(height: 4),
                Text(
                  '${passenger['gender']}, ${passenger['age']} yrs | ${passenger['mobile']}',
                  style: AppTextStyles.caption.copyWith(color: AppColors.secondaryGreyBlue),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.primaryAccent),
            onPressed: () => controller.removePassenger(index),
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
          color: AppColors.primaryDark,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, TextEditingController textController, {TextInputType keyboardType = TextInputType.text}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.secondaryGreyBlue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: textController,
        keyboardType: keyboardType,
        style: AppTextStyles.bodyMedium,
        validator: (val) => val!.isEmpty ? 'Required' : null,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.secondaryGreyBlue.withOpacity(0.6)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        ),
      ),
    );
  }

  Widget _buildCheckoutBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(color: AppColors.secondaryGreyBlue.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -5)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Total Amount', style: AppTextStyles.caption.copyWith(color: AppColors.secondaryGreyBlue)),
                Obx(() => Text('₹${controller.totalAmount.toStringAsFixed(2)}', style: AppTextStyles.h2.copyWith(fontSize: 20))),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: controller.proceedToPay,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryAccent,
              minimumSize: const Size(0, 54),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Proceed to Pay', style: AppTextStyles.buttonText.copyWith(fontSize: 14)),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward, color: AppColors.white, size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }
}