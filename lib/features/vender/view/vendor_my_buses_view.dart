import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:savarii/core/theme/app_colors.dart';
import 'package:savarii/core/theme/app_text_styles.dart';
import '../controllers/vendor_my_buses_controller.dart';

class VendorMyBusesView extends GetView<VendorMyBusesController> {
  const VendorMyBusesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Header (Title & Add Bus Button)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'my_buses.title'.tr(),
                    style: AppTextStyles.h1.copyWith(fontSize: 28),
                  ),
                  ElevatedButton.icon(
                    onPressed: controller.goToAddBus,
                    icon: const Icon(
                      Icons.add,
                      color: AppColors.white,
                      size: 16,
                    ),
                    label: Text(
                      'my_buses.add_bus'.tr(),
                      style: AppTextStyles.buttonText.copyWith(fontSize: 12),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryAccent,
                      minimumSize: const Size(0, 0), // Fixes infinite width crash in Row
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ),

            // 2. Search Bar & Filter
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.secondaryGreyBlue.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: controller.searchController,
                        decoration: InputDecoration(
                          hintText: 'my_buses.search_hint'.tr(),
                          hintStyle: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.secondaryGreyBlue.withValues(alpha: 0.6),
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: AppColors.secondaryGreyBlue,
                            size: 20,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryGreyBlue.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.tune, color: AppColors.primaryDark),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 3. Custom Tab Bar
            _buildCustomTabBar(),
            Divider(
              color: AppColors.secondaryGreyBlue.withValues(alpha: 0.1),
              height: 1,
            ),

            // 4. Bus List
            Expanded(
              child: Obx(() {
                final buses = controller.filteredBuses;
                if (buses.isEmpty) {
                  return Center(
                    child: Text(
                      'my_buses.no_buses'.tr(),
                      style: AppTextStyles.bodyMedium,
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: buses.length,
                  itemBuilder: (context, index) => _buildBusCard(buses[index]),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // --- Sub-Widgets ---

  Widget _buildCustomTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Obx(
        () => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildTabItem(title: 'my_buses.all_buses'.tr(), index: 0),
            _buildTabItem(title: 'my_buses.active'.tr(), index: 1),
            _buildTabItem(title: 'my_buses.inactive'.tr(), index: 2),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem({required String title, required int index}) {
    bool isSelected = controller.selectedTab.value == index;
    return GestureDetector(
      onTap: () => controller.setTab(index),
      child: Container(
        padding: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppColors.primaryAccent : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          title,
          style: AppTextStyles.bodyMedium.copyWith(
            color: isSelected
                ? AppColors.primaryAccent
                : AppColors.secondaryGreyBlue,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildBusCard(VendorBusModel bus) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.secondaryGreyBlue.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryGreyBlue.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Row 1: Icon, Name/Reg, Switch
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.directions_bus,
                  color: AppColors.primaryAccent,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bus.name,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      bus.regNumber,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.secondaryGreyBlue,
                      ),
                    ),
                  ],
                ),
              ),
              Obx(
                () => CupertinoSwitch(
                  value: bus.isActive.value,
                  activeTrackColor: AppColors.primaryAccent,
                  onChanged: (val) => controller.toggleBusStatus(bus, val),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Row 2: Stats Grid
          Row(
            children: [
              Expanded(
                child: _buildStatColumn(
                  'my_buses.route'.tr(),
                  '${bus.origin} → ${bus.destination}',
                ),
              ),
              Expanded(child: _buildStatColumn('my_buses.total_seats'.tr(), bus.totalSeats)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildStatColumn('my_buses.type'.tr(), bus.type)),
              Expanded(
                child: Obx(() => _buildStatusColumn(bus.isActive.value)),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Row 3: Action Buttons
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.edit,
                  label: 'my_buses.edit_details'.tr(),
                  onTap: () => controller.editBusDetails(bus.id),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Obx(
                  () => _buildActionButton(
                    icon: bus.isActive.value ? Icons.map : Icons.history,
                    label: bus.isActive.value ? 'my_buses.live_route'.tr() : 'my_buses.history'.tr(),
                    onTap: () => bus.isActive.value
                        ? controller.viewLiveRoute(bus.id)
                        : controller.viewHistory(bus.id),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.secondaryGreyBlue,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.primaryDark,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusColumn(bool isActive) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'my_buses.status'.tr(),
          style: AppTextStyles.caption.copyWith(
            color: AppColors.secondaryGreyBlue,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(
              Icons.circle,
              size: 10,
              color: isActive
                  ? const Color(0xFF00A65A)
                  : AppColors.secondaryGreyBlue.withValues(alpha: 0.5),
            ),
            const SizedBox(width: 4),
            Text(
              isActive ? 'my_buses.status_active'.tr() : 'my_buses.status_inactive'.tr(),
              style: AppTextStyles.bodyMedium.copyWith(
                color: isActive
                    ? const Color(0xFF00A65A)
                    : AppColors.secondaryGreyBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.secondaryGreyBlue.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primaryDark, size: 16),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primaryDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
