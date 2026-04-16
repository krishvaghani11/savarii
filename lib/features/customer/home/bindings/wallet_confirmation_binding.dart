import 'package:get/get.dart';
import 'package:savarii/features/customer/home/controller/wallet_confirmation_controller.dart';


class WalletConfirmationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WalletConfirmationController>(() => WalletConfirmationController());
  }
}