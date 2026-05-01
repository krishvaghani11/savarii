import 'dart:async';
import 'package:get/get.dart';
import 'package:savarii/core/services/auth_services.dart';
import 'package:savarii/core/services/firestore_service.dart';

class DriverNotificationsController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final FirestoreService _firestoreService = Get.find<FirestoreService>();

  final RxList<Map<String, dynamic>> notifications = <Map<String, dynamic>>[].obs;
  StreamSubscription? _notificationSubscription;

  int get unreadNotificationsCount =>
      notifications.where((n) => !(n['readStatus'] as bool? ?? false)).length;

  @override
  void onInit() {
    super.onInit();
    _fetchNotifications();
  }

  void _fetchNotifications() {
    final driverId = _authService.currentUser?.uid;
    if (driverId != null) {
      _notificationSubscription = _firestoreService
          .getDriverNotificationsStream(driverId)
          .listen((data) {
        notifications.assignAll(data);
      });
    }
  }

  void markNotificationAsRead(String notificationId) {
    _firestoreService.markNotificationAsRead(notificationId);
  }

  void markAllNotificationsAsRead() {
    final driverId = _authService.currentUser?.uid;
    if (driverId != null) {
      _firestoreService.markAllDriverNotificationsAsRead(driverId);
    }
  }

  @override
  void onClose() {
    _notificationSubscription?.cancel();
    super.onClose();
  }
}
