import 'package:get/get.dart';
import 'package:savarii/features/customer/home/controller/wallet_controller.dart';

class WalletBinding extends Bindings {
  @override
  void dependencies() {
    // Injects the WalletController into memory when the Wallet route is called directly
    Get.lazyPut<WalletController>(() => WalletController());
  }
}