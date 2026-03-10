import 'package:get/get.dart';

class MainLayoutController extends GetxController {
  // Reactive variable to track which tab is currently selected in the Bottom Navigation Bar
  final RxInt currentIndex = 0.obs;

  // Method to update the active tab when a user taps an icon
  void changeTab(int index) {
    currentIndex.value = index;
  }
}