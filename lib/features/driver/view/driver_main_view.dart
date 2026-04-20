import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:savarii/core/theme/app_colors.dart';
import 'package:savarii/features/driver/view/driver_home_view.dart';
import 'package:savarii/features/driver/view/driver_profile_view.dart';
import 'package:savarii/features/driver/view/driver_settings_view.dart';
import '../controller/driver_main_controller.dart';

class DriverMainView extends GetView<DriverMainController> {
  const DriverMainView({super.key});

  @override
  Widget build(BuildContext context) {
    // The screens for each tab
    final List<Widget> pages = [
      const DriverHomeView(),
      const DriverProfileView(),
      const DriverSettingsView(),
    ];

    return Scaffold(
      body: Obx(
        () => IndexedStack(
          index: controller.currentIndex.value, 
          children: pages
        ),
      ),
      bottomNavigationBar: Obx(
        () => Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            boxShadow: [
              BoxShadow(
                color: AppColors.secondaryGreyBlue.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            child: BottomNavigationBar(
              currentIndex: controller.currentIndex.value,
              onTap: controller.changeTab,
              type: BottomNavigationBarType.fixed,
              backgroundColor: AppColors.white,
              selectedItemColor: AppColors.primaryAccent,
              unselectedItemColor: AppColors.secondaryGreyBlue,
              selectedFontSize: 12,
              unselectedFontSize: 10,
              showUnselectedLabels: true,
              elevation: 0,
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(Icons.home_outlined),
                  activeIcon: const Icon(Icons.home),
                  label: 'main.home'.tr(),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.person_outline),
                  activeIcon: const Icon(Icons.person),
                  label: 'main.profile'.tr(),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.settings_outlined),
                  activeIcon: const Icon(Icons.settings),
                  label: 'Settings',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
