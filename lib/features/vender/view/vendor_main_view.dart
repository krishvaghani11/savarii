import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:savarii/core/theme/app_colors.dart';
import 'package:savarii/features/vender/view/vendor_home_view.dart';
import 'package:savarii/features/vender/view/vendor_my_buses_view.dart';
import 'package:savarii/features/vender/view/vendor_profile_view.dart';
import 'package:savarii/features/vender/view/vendor_view_tickets_view.dart';
import '../controllers/vendor_main_controller.dart';

class VendorMainView extends GetView<VendorMainController> {
  const VendorMainView({super.key});

  @override
  Widget build(BuildContext context) {
    // The screens for each tab
    final List<Widget> pages = [
      const VendorHomeView(), // Placeholder,
      const VendorViewTicketsView(),
      const VendorMyBusesView(),
      const VendorProfileView(),
    ];

    return Scaffold(
      body: Obx(
        () =>
            IndexedStack(index: controller.currentIndex.value, children: pages),
      ),
      bottomNavigationBar: Obx(
        () => Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: AppColors.secondaryGreyBlue.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: controller.currentIndex.value,
            onTap: controller.changeTab,
            type: BottomNavigationBarType.fixed,
            backgroundColor: AppColors.white,
            selectedItemColor: AppColors.primaryAccent,
            unselectedItemColor: AppColors.secondaryGreyBlue,
            selectedFontSize: 10,
            unselectedFontSize: 10,
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.home_filled),
                label: 'main.home'.tr(),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.confirmation_num),
                label: 'main.tickets'.tr(),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.directions_bus),
                label: 'main.my_buses'.tr(),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.person),
                label: 'main.profile'.tr(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
