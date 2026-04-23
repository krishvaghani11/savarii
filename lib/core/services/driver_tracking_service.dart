import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:savarii/core/services/realtime_db_service.dart';
import 'package:savarii/models/live_tracking_model.dart';

class DriverTrackingService extends GetxService {
  final RealtimeDbService _rtdbService = Get.find<RealtimeDbService>();
  
  StreamSubscription<Position>? _positionStreamSubscription;
  Timer? _heartbeatTimer;
  String? _activeBusId;
  
  /// Start listening to location updates and pushing them to RTDB for the given busId
  Future<void> startTracking(String busId) async {
    // If already tracking this bus, do nothing
    if (_activeBusId == busId && _positionStreamSubscription != null) {
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
    debugPrint('DriverTrackingService: Started tracking for bus $busId');
    
    // Configure location stream settings for driving (accuracy and update distance)
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Minimum distance (in meters) before an update is generated
    );

    // Fetch initial position immediately so tracking starts even if not moving
    try {
      Position initialPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _updateLocation(initialPosition);
    } catch (e) {
      debugPrint('DriverTrackingService: Failed to get initial position: $e');
    }

    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      (Position position) {
        _updateLocation(position);
      },
      onError: (e) {
        debugPrint('DriverTrackingService: Location stream error: $e');
      },
    );

    // Setup a heartbeat timer to broadcast the location every 5 seconds, 
    // ensuring the customer app doesn't mark it as stale if the bus is stopped at a traffic light
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      if (_activeBusId != null) {
        try {
          Position currentPos = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          );
          _updateLocation(currentPos);
        } catch (e) {
          debugPrint('DriverTrackingService: Heartbeat location failed: $e');
        }
      }
    });
  }

  void _updateLocation(Position position) {
    if (_activeBusId == null) return;
    
    final trackingModel = LiveTrackingModel(
      latitude: position.latitude,
      longitude: position.longitude,
      heading: position.heading,
      speed: position.speed * 3.6, // m/s to km/h
      updatedAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
    );

    _rtdbService.updateLiveLocation(_activeBusId!, trackingModel);
  }

  /// Stop tracking and writing to RTDB
  void stopTracking() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    
    if (_positionStreamSubscription != null) {
      _positionStreamSubscription!.cancel();
      _positionStreamSubscription = null;
      debugPrint('DriverTrackingService: Stopped tracking for bus $_activeBusId');
      _activeBusId = null;
    }
  }

  @override
  void onClose() {
    stopTracking();
    super.onClose();
  }
}
