import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:savarii/core/services/realtime_db_service.dart';
import 'package:savarii/core/services/background_location_task.dart';

class DriverTrackingService extends GetxService {
  final RealtimeDbService _rtdbService = Get.find<RealtimeDbService>();
  
  String? _activeBusId;
  final FlutterBackgroundService _backgroundService = FlutterBackgroundService();

  @override
  void onInit() {
    super.onInit();
    _initializeBackgroundService();
  }

  Future<void> _initializeBackgroundService() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'my_foreground', // id
      'Driver Tracking Service', // title
      description: 'This channel is used for tracking driver location in background.', // description
      importance: Importance.low, // importance must be at low or higher level
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    if (Platform.isAndroid) {
      // Create the channel on the device (if a channel with an id already exists, it will be updated)
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }

    await _backgroundService.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: false,
        isForegroundMode: true,
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
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      debugPrint('DriverTrackingService: Location permissions are denied.');
      return;
    }

    // Stop any existing stream
    stopTracking();
    
    _activeBusId = busId;
    debugPrint('DriverTrackingService: Started tracking for bus $busId via background service');
    
    await _backgroundService.startService();
    // Give the background isolate enough time to run Firebase.initializeApp()
    // and register its event listeners before we invoke 'setBusId'.
    // Firebase init alone can take 1–2 s on a cold start.
    await Future.delayed(const Duration(milliseconds: 2500));
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
    stopTracking();
    super.onClose();
  }
}
