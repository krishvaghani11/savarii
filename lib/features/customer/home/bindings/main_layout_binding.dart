import 'package:get/get.dart';
import 'package:savarii/features/customer/home/controller/bookings_controller.dart';
import 'package:savarii/features/customer/home/controller/customer_home_controller.dart';
import 'package:savarii/features/customer/home/controller/main_layout_controller.dart';
import 'package:savarii/features/customer/home/controller/profile_controller.dart';
import 'package:savarii/features/customer/home/controller/wallet_controller.dart';

class MainLayoutBinding extends Bindings {
  @override
  void dependencies() {
    // Injects the Bottom Navigation logic
    Get.lazyPut<MainLayoutController>(() => MainLayoutController());

    // Injects the Home Screen logic so the first tab doesn't crash
    Get.lazyPut<CustomerHomeController>(() => CustomerHomeController());
    Get.lazyPut<ProfileController>(() => ProfileController());
    Get.lazyPut<BookingsController>(() => BookingsController());
    Get.lazyPut<WalletController>(() => WalletController());
  }
}
