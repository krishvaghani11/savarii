import 'package:get/get.dart';
import 'package:savarii/features/customer/home/controller/wallet_topups_controller.dart';


class WalletTopupsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WalletTopupsController>(() => WalletTopupsController());
  }
}