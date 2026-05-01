import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../features/auth/controllers/auth_controller.dart';
import '../../models/notification_model.dart';
import '../notifications/notification_routes.dart';

/// Central notification service registered as a permanent [GetxService].
///
/// Responsibilities:
///   1. Create Android notification channels (critical + general).
///   2. Request notification permissions (Android 13+ via permission_handler).
///   3. Listen for FCM token refreshes — auto-update Firestore immediately.
///   4. Sync token on startup if a user is already logged in.
///   5. Fetch & store FCM token per role to Firestore on login.
///   6. Handle foreground messages → show local notification in correct channel.
///   7. Handle background / terminated tap → deep-link navigation.
class NotificationService extends GetxService {
  // ── Singleton accessor ────────────────────────────────────────────────────
  static NotificationService get to => Get.find<NotificationService>();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Android notification channels ────────────────────────────────────────
  //
  // savarii_critical      → high importance, max priority (FCM critical types)
  // savarii_notifications → default importance (all other FCM messages)
  //
  static const _kCriticalChannelId   = 'savarii_critical';
  static const _kCriticalChannelName = 'Savarii Critical Alerts';
  static const _kCriticalChannelDesc = 'Time-sensitive alerts: boarding, cancellations, and driver events.';

  static const _kChannelId   = 'savarii_notifications';
  static const _kChannelName = 'Savarii Alerts';
  static const _kChannelDesc = 'Booking updates, trip info, and general alerts.';

  // ── Public observable — unread badge count (future in-app centre) ─────────
  final RxInt unreadCount = 0.obs;

  // ─────────────────────────────────────────────────────────────────────────
  // Init
  // ─────────────────────────────────────────────────────────────────────────

  /// Call once from [main()] after Firebase.initializeApp() and BEFORE runApp().
  Future<NotificationService> init() async {
    await _createAndroidChannels();
    await _initLocalNotifications();
    await _requestPermissions();
    _listenForeground();
    await _handleTerminatedTap();
    _listenBackgroundTap();
    _listenTokenRefresh();        // Global refresh listener — runs for whole session
    await _syncTokenOnStartup();  // Catches users who were already logged in
    return this;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Android channels
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _createAndroidChannels() async {
    if (!Platform.isAndroid) return;

    final impl = _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    // Critical / high-importance channel
    await impl?.createNotificationChannel(const AndroidNotificationChannel(
      _kCriticalChannelId,
      _kCriticalChannelName,
      description: _kCriticalChannelDesc,
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    ));

    // General channel
    await impl?.createNotificationChannel(const AndroidNotificationChannel(
      _kChannelId,
      _kChannelName,
      description: _kChannelDesc,
      importance: Importance.high,
      playSound: true,
    ));

    debugPrint('NotificationService: Android channels created.');
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Local notifications plugin init
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _initLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _localNotifications.initialize(
      settings: const InitializationSettings(android: androidInit, iOS: iosInit),
      onDidReceiveNotificationResponse: _onLocalNotificationTap,
    );

    debugPrint('NotificationService: flutter_local_notifications initialised.');
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Permissions (Android 13+ via permission_handler)
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _requestPermissions() async {
    // 1. Firebase Messaging internal permission request (required for iOS)
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    debugPrint(
      'NotificationService: FCM permission = ${settings.authorizationStatus}',
    );

    // 2. Android 13+ (API 33) requires explicit POST_NOTIFICATIONS permission
    if (Platform.isAndroid) {
      final status = await Permission.notification.status;
      if (!status.isGranted) {
        final result = await Permission.notification.request();
        debugPrint('NotificationService: Android 13 POST_NOTIFICATIONS = $result');
      }
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // FCM token management
  // ─────────────────────────────────────────────────────────────────────────

  /// Fetch & save the current FCM token for [uid]/[role] to Firestore.
  ///
  /// Called by [AuthController] immediately after login, and on startup via
  /// [_syncTokenOnStartup] for already-authenticated users.
  Future<void> saveFcmToken(String uid, String role) async {
    try {
      if (Platform.isIOS) await _fcm.getAPNSToken();

      final token = await _fcm.getToken();
      if (token == null) {
        debugPrint('NotificationService: FCM token is null — skipping save.');
        return;
      }
      await _writeToken(uid: uid, role: role, token: token);
    } catch (e) {
      debugPrint('NotificationService: Error saving FCM token — $e');
    }
  }

  /// Remove the FCM token from Firestore on logout.
  Future<void> removeFcmToken(String uid, String role) async {
    try {
      final collection = _collectionForRole(role);
      await _db.collection(collection).doc(uid).update({
        'fcmToken': FieldValue.delete(),
        'tokenUpdatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('NotificationService: Token removed for $collection/$uid');
    } catch (e) {
      debugPrint('NotificationService: Error removing FCM token — $e');
    }
  }

  /// Global token-refresh listener — established during [init()] so it
  /// remains active for the full app session even without a fresh login.
  void _listenTokenRefresh() {
    _fcm.onTokenRefresh.listen((newToken) async {
      debugPrint('NotificationService: Token refreshed by FCM — updating Firestore.');
      final user = fb_auth.FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final role = await _getRoleForUid(user.uid);
      if (role != null) {
        await _writeToken(uid: user.uid, role: role, token: newToken);
      }
    });
  }

  /// On app startup, if a user is already authenticated (e.g. returning user),
  /// immediately sync their token so stale tokens are replaced without a login.
  Future<void> _syncTokenOnStartup() async {
    final user = fb_auth.FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final role = await _getRoleForUid(user.uid);
    if (role != null) {
      await saveFcmToken(user.uid, role);
    }
  }

  /// Resolves the Firestore role for [uid] by:
  ///   1. Checking [AuthController] in-memory (fast, no network).
  ///   2. Falling back to Firestore `users` collection lookup.
  Future<String?> _getRoleForUid(String uid) async {
    if (Get.isRegistered<AuthController>()) {
      final ctrl = Get.find<AuthController>();
      if (ctrl.uid == uid && ctrl.selectedRole.value.isNotEmpty) {
        return ctrl.selectedRole.value;
      }
    }

    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) return doc.data()?['role'] as String?;
    } catch (e) {
      debugPrint('NotificationService: _getRoleForUid error — $e');
    }
    return null;
  }

  /// Persists [token] to the correct Firestore collection for [role].
  /// Uses merge:true so existing user data is never overwritten.
  Future<void> _writeToken({
    required String uid,
    required String role,
    required String token,
  }) async {
    final collection = _collectionForRole(role);
    await _db.collection(collection).doc(uid).set(
      {'fcmToken': token, 'tokenUpdatedAt': FieldValue.serverTimestamp()},
      SetOptions(merge: true),
    );
    debugPrint('NotificationService: Token saved to $collection/$uid');
  }

  static String _collectionForRole(String role) {
    switch (role) {
      case 'vendor': return 'vendors';
      case 'driver': return 'drivers';
      case 'customer':
      default:       return 'users';
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Foreground messages
  // ─────────────────────────────────────────────────────────────────────────

  void _listenForeground() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('NotificationService [FG]: type=${message.data['type']}');
      _showLocalNotification(message);
    });
  }

  /// Display a local notification for a foreground FCM message.
  /// Routes critical types to the high-importance channel automatically.
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    final type = message.data['type'] ?? '';
    final isCritical = _criticalTypes.contains(type);

    final channelId   = isCritical ? _kCriticalChannelId   : _kChannelId;
    final channelName = isCritical ? _kCriticalChannelName : _kChannelName;
    final channelDesc = isCritical ? _kCriticalChannelDesc : _kChannelDesc;
    final priority    = isCritical ? Priority.max          : Priority.high;
    final importance  = isCritical ? Importance.max        : Importance.high;

    final androidDetails = AndroidNotificationDetails(
      channelId, channelName,
      channelDescription: channelDesc,
      importance: importance,
      priority: priority,
      icon: '@mipmap/ic_launcher',
      playSound: true,
    );

    await _localNotifications.show(
      id: message.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: NotificationDetails(
        android: androidDetails,
        iOS: const DarwinNotificationDetails(
          interruptionLevel: InterruptionLevel.timeSensitive,
        ),
      ),
      payload: type,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Tap handlers
  // ─────────────────────────────────────────────────────────────────────────

  /// Tap on a LOCAL notification (foreground display).
  void _onLocalNotificationTap(NotificationResponse response) {
    final type = response.payload ?? '';
    debugPrint('NotificationService: Local tap — type=$type');
    _navigateByType(type, {});
  }

  /// App was fully terminated when notification arrived → cold-start routing.
  Future<void> _handleTerminatedTap() async {
    final initial = await _fcm.getInitialMessage();
    if (initial != null) {
      debugPrint(
        'NotificationService [TERMINATED tap]: type=${initial.data['type']}',
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final payload = NotificationPayload.fromMessage(initial);
        _navigateByType(payload.type, payload.raw);
      });
    }
  }

  /// App was in background when notification arrived → resume routing.
  void _listenBackgroundTap() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('NotificationService [BG tap]: type=${message.data['type']}');
      final payload = NotificationPayload.fromMessage(message);
      _navigateByType(payload.type, payload.raw);
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Routing
  // ─────────────────────────────────────────────────────────────────────────

  void _navigateByType(String type, Map<String, String> data) {
    final route = NotificationRoutes.routeFor(type);
    if (route == null) {
      debugPrint(
        'NotificationService: No route for type "$type" — ignoring tap.',
      );
      return;
    }

    final args = <String, dynamic>{};
    if (data['bookingId'] != null) args['bookingId'] = data['bookingId'];
    if (data['busId']     != null) args['busId']     = data['busId'];
    if (data['ticketId']  != null) args['ticketId']  = data['ticketId'];

    Get.toNamed(route, arguments: args.isNotEmpty ? args : null);
  }

  /// Public helper for manual tap routing (e.g. future in-app notification centre).
  void handleNotificationTap(NotificationPayload payload) {
    _navigateByType(payload.type, payload.raw);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────────────────────

  /// Notification types that warrant the high-importance channel.
  /// Mirrors CRITICAL_TYPES in functions/fcm.js.
  static const _criticalTypes = {
    'booking_confirmed',
    'bus_arriving_soon',
    'drop_point_approaching',
    'driver_offline_alert',
    'ticket_cancelled',
    'payment_failure',
    'trip_cancelled_by_vendor',
    'vehicle_breakdown_alert',
    'bus_reached_boarding_point',
  };
}
