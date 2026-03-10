import 'package:get/get.dart';

class NotificationSettingsController extends GetxController {
  // General
  final RxBool pushNotifications = true.obs;

  // Travel Updates
  final RxBool bookingConfirmations = true.obs;
  final RxBool busTrackingAlerts = true.obs;
  final RxBool delayNotifications = true.obs;

  // Parcel Services
  final RxBool parcelPickupAlerts = false.obs;
  final RxBool deliveryStatusUpdates = true.obs;

  // Promotions & Offers
  final RxBool exclusiveDeals = true.obs;
  final RxBool walletCashbackAlerts = false.obs;

  void toggleSetting(RxBool setting, bool value) {
    setting.value = value;
    // TODO: Sync this new preference with your backend/local storage
  }
}
