import 'package:get/get.dart';

class VendorMainController extends GetxController {
  final RxInt currentIndex = 0.obs;

  void changeTab(int index) {
    currentIndex.value = index;
  }
}
