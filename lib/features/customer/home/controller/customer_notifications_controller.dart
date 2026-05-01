import 'dart:async';
import 'package:get/get.dart';
import 'package:savarii/core/services/auth_services.dart';
import 'package:savarii/core/services/firestore_service.dart';

class CustomerNotificationsController extends GetxController {
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
    final customerId = _authService.currentUser?.uid;
    if (customerId != null) {
      _notificationSubscription = _firestoreService
          .getCustomerNotificationsStream(customerId)
          .listen((data) {
        notifications.assignAll(data);
      });
    }
  }

  void markNotificationAsRead(String notificationId) {
    _firestoreService.markNotificationAsRead(notificationId);
  }

  void markAllNotificationsAsRead() {
    final customerId = _authService.currentUser?.uid;
    if (customerId != null) {
      _firestoreService.markAllNotificationsAsRead(customerId);
    }
  }

  @override
  void onClose() {
    _notificationSubscription?.cancel();
    super.onClose();
  }
}
