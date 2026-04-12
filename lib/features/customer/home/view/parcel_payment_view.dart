import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:savarii/core/theme/app_colors.dart';
import 'package:savarii/core/theme/app_text_styles.dart';
import 'package:savarii/features/customer/home/controller/parcel_payment_controller.dart';

class ParcelPaymentView extends GetView<ParcelPaymentController> {
  const ParcelPaymentView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text('Parcel Payment', style: AppTextStyles.h3),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryDark),
          onPressed: () => Get.back(),
        ),
        actions: [
          TextButton(
            onPressed: controller.helpAction,
            child: Text(
              'Help',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primaryAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Delivery Details Card
              _buildDeliveryDetailsCard(),
              const SizedBox(height: 20),

              // 2. Estimated Times Banner (Updated to split Pickup/Drop-off)
              _buildEstimatedTimeBanner(),
              const SizedBox(height: 24),

              // 3. Bus & Driver Details Card (NEW)
              _buildSectionTitle('Bus & Driver Details'),
              _buildBusAndDriverDetailsCard(),
              const SizedBox(height: 24),

              // 4. Charge Summary Card
              _buildSectionTitle('Charge Summary'),
              _buildChargeSummaryCard(),

              const SizedBox(height: 100), // Buffer for sticky bottom bar
            ],
          ),
        ),
      ),
      // Sticky Bottom Bar
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  // --- Sub-Widgets ---

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(title, style: AppTextStyles.h3.copyWith(fontSize: 16, color: AppColors.primaryDark)),
    );
  }

  Widget _buildDeliveryDetailsCard() {
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
          // Top Row: Icon and Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryAccent.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.local_shipping,
                  color: AppColors.primaryAccent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Standard Delivery',
                    style: AppTextStyles.h3.copyWith(fontSize: 16),
                  ),
                  Text(
                    'Order ID: ${controller.orderId}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.secondaryGreyBlue,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Vertical Timeline
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
                    height: 45,
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
                      'Pickup',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.secondaryGreyBlue,
                        fontSize: 11,
                      ),
                    ),
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
                      'Drop-off',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.secondaryGreyBlue,
                        fontSize: 11,
                      ),
                    ),
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
        ],
      ),
    );
  }

  Widget _buildEstimatedTimeBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.primaryAccent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primaryAccent.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryAccent, width: 1.5),
            ),
            child: const Icon(Icons.access_time, color: AppColors.primaryAccent, size: 16),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ESTIMATED PICKUP',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primaryAccent,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                          fontSize: 9,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        controller.estimatedPickupTime,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDark,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ESTIMATED DROP-OFF',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primaryAccent,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                          fontSize: 9,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        controller.estimatedDropoffTime,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDark,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBusAndDriverDetailsCard() {
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
        children: [
          // Bus Details Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.secondaryGreyBlue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.directions_bus_outlined, color: AppColors.primaryDark, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.busName,
                      style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      controller.busNumber,
                      style: AppTextStyles.caption.copyWith(color: AppColors.secondaryGreyBlue),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Driver Details Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.secondaryGreyBlue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_outline, color: AppColors.primaryDark, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.driverName,
                      style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      controller.driverPhone,
                      style: AppTextStyles.caption.copyWith(color: AppColors.secondaryGreyBlue),
                    ),
                  ],
                ),
              ),
              
              // Call Button
              GestureDetector(
                onTap: controller.callDriver,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.phone_in_talk, color: Colors.green, size: 20),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChargeSummaryCard() {
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
        children: [
          _buildSummaryRow('Base Fare', controller.baseFare),
          const SizedBox(height: 12),
          _buildSummaryRow('Weight Surcharge (5kg)', controller.weightSurcharge),
          const SizedBox(height: 12),
          _buildSummaryRow('Service Fee', controller.serviceFee),
          const SizedBox(height: 12),
          _buildSummaryRow('Tax', controller.tax),
          const SizedBox(height: 20),
          Divider(color: AppColors.secondaryGreyBlue.withOpacity(0.2)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Payable',
                style: AppTextStyles.h3.copyWith(fontSize: 16, color: AppColors.primaryDark),
              ),
              Obx(
                () => Text(
                  '₹${controller.totalAmount.value.toStringAsFixed(2)}',
                  style: AppTextStyles.h3.copyWith(
                    fontSize: 20,
                    color: AppColors.primaryAccent, // Red highlighted total
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.secondaryGreyBlue,
          ),
        ),
        Text(
          '₹${amount.toStringAsFixed(2)}',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primaryDark,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.secondaryGreyBlue.withOpacity(0.1))),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Amount',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.secondaryGreyBlue,
                  ),
                ),
                Obx(
                  () => Text(
                    '₹${controller.totalAmount.value.toStringAsFixed(2)}',
                    style: AppTextStyles.h2.copyWith(fontSize: 20, color: AppColors.primaryDark),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: controller.payNow,
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
                    'Confirm & Pay Now',
                    style: AppTextStyles.buttonText.copyWith(fontSize: 16),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward,
                    color: AppColors.white,
                    size: 20,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Painter for the dotted vertical line
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