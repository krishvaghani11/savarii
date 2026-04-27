import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
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
    await _backgroundService.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: false,
        isForegroundMode: true,
        notificationChannelId: 'my_foreground',
        initialNotificationTitle: 'Driver Tracking',
        initialNotificationContent: 'Initializing',
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
