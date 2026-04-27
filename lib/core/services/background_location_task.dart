import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:savarii/firebase_options.dart';

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase init error in background: $e");
  }
  
  String? activeBusId;
  StreamSubscription<Position>? positionStream;

  service.on('setBusId').listen((event) {
    activeBusId = event?['busId'];
    debugPrint("Background Service tracking busId: $activeBusId");
  });

  service.on('stopService').listen((event) {
    positionStream?.cancel();
    service.stopSelf();
  });

  // Start Location Stream
  positionStream = Geolocator.getPositionStream(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    ),
  ).listen((Position position) {
    if (activeBusId != null) {
      final dbRef = FirebaseDatabase.instance.ref();
      dbRef.child('live_tracking').child(activeBusId!).update({
        'latitude': position.latitude,
        'longitude': position.longitude,
        'heading': position.heading,
        'speed': position.speed * 3.6,
        'updatedAt': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      });
    }
  });

  // Heartbeat timer for foreground notification
  Timer.periodic(const Duration(seconds: 5), (timer) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
         service.setForegroundNotificationInfo(
            title: "Savarii Driver Active",
            content: "Tracking location in background",
         );
      }
    }
  });
}
