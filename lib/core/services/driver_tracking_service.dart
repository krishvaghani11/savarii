import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:savarii/core/services/realtime_db_service.dart';
import 'package:savarii/core/services/background_location_task.dart';

class DriverTrackingService extends GetxService with WidgetsBindingObserver {
  final RealtimeDbService _rtdbService = Get.find<RealtimeDbService>();

  String? _activeBusId;
  final FlutterBackgroundService _backgroundService =
      FlutterBackgroundService();

  /// True if there is an active GPS tracking session.
  bool get isTracking => _activeBusId != null;

  /// The bus currently being tracked, or null if not tracking.
  String? get activeBusId => _activeBusId;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _initializeBackgroundService();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_activeBusId == null) return; // Only toggle if tracking is active

    if (state == AppLifecycleState.resumed) {
      // App is in foreground, set service to background mode to hide notification
      _backgroundService.invoke('setAsBackground');
      debugPrint('DriverTrackingService: App resumed, hiding notification');
    } else if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive || state == AppLifecycleState.hidden) {
      // App is in background, set service to foreground mode to show notification and keep alive
      _backgroundService.invoke('setAsForeground');
      debugPrint('DriverTrackingService: App in background, showing notification');
    }
  }

  Future<void> _initializeBackgroundService() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'my_foreground', // id
      'Driver Tracking Service', // title
      description:
          'This channel is used for tracking driver location in background.', // description
      importance: Importance.low, // importance must be at low or higher level
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    if (Platform.isAndroid) {
      // Create the channel on the device (if a channel with an id already exists, it will be updated)
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(channel);
    }

    await _backgroundService.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: false,
        isForegroundMode: false, // Start as background mode (hidden) since app is open
        notificationChannelId: 'my_foreground',
        initialNotificationTitle: 'Savarii Driver Active',
        initialNotificationContent: 'Tracking location in background',
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: onStart,
      ),
    );
  }

  /// Start listening to location updates and pushing them to RTDB for the given busId
  Future<void> startTracking(String busId) async {
    // If already tracking this bus, do nothing
    if (_activeBusId == busId) {
      return;
    }

    // Check permissions before starting
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('DriverTrackingService: Location services are disabled.');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      debugPrint('DriverTrackingService: Location permissions are denied.');
      return;
    }

    // Stop any existing stream
    stopTracking();

    _activeBusId = busId;
    debugPrint(
      'DriverTrackingService: Started tracking for bus $busId via background service',
    );

    await _backgroundService.startService();

    // Wait for the background isolate to signal it finished Firebase init.
    // This is a proper handshake — no blind delay needed.
    // Timeout after 10 s in case something goes wrong in the isolate.
    try {
      await _backgroundService
          .on('ready')
          .first
          .timeout(const Duration(seconds: 10));
      debugPrint('DriverTrackingService: background isolate is ready.');
    } catch (_) {
      debugPrint('DriverTrackingService: ready timeout — sending setBusId anyway.');
    }

    _backgroundService.invoke('setBusId', {'busId': busId});
  }

  /// Stop tracking and writing to RTDB
  void stopTracking() {
    debugPrint('DriverTrackingService: Stopped tracking for bus $_activeBusId');
    _backgroundService.invoke('stopService');

    if (_activeBusId != null) {
      _rtdbService.clearLiveLocation(_activeBusId!);
      _activeBusId = null;
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    stopTracking();
    super.onClose();
  }
}
