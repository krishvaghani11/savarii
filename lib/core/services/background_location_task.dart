import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:savarii/firebase_options.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  if (Firebase.apps.isEmpty) {
    try {
      await dotenv.load(fileName: ".env");
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e) {
      debugPrint("Firebase init error in background: $e");
      return;
    }
  }

  // Handle Android specific foreground/background toggling
  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  // Signal to the main isolate that we are fully initialized and ready
  // to receive events. This replaces the unreliable fixed delay.
  service.invoke('ready', {});

  StreamSubscription<Position>? positionStream;

  // Register event listeners SYNCHRONOUSLY right after Firebase init,
  // so they are ready before the caller invokes 'setBusId'.
  service.on('stopService').listen((event) {
    positionStream?.cancel();
    service.stopSelf();
  });

  service.on('setBusId').listen((event) async {
    final String? busId = event?['busId'] as String?;
    debugPrint("Background: received busId = $busId");
    if (busId == null) return;

    // Cancel any previous stream before starting a new one
    await positionStream?.cancel();
    positionStream = null;

    // Send an immediate one-shot location so the map pin appears instantly
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      await FirebaseDatabase.instance.ref('live_tracking/$busId').update({
        'latitude': position.latitude,
        'longitude': position.longitude,
        'heading': position.heading,
        'speed': position.speed * 3.6,
        'updatedAt': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      });
      debugPrint("Background: initial location sent for $busId");
    } catch (e) {
      debugPrint("Background: initial location error: $e");
    }

    // Start the continuous 5-second GPS stream
    final locationSettings = Platform.isAndroid
        ? AndroidSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 0,
            intervalDuration: const Duration(seconds: 5),
          )
        : const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 0,
          );

    positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (Position position) {
            FirebaseDatabase.instance.ref('live_tracking/$busId').update({
              'latitude': position.latitude,
              'longitude': position.longitude,
              'heading': position.heading,
              'speed': position.speed * 3.6,
              'updatedAt': DateTime.now().millisecondsSinceEpoch ~/ 1000,
            });
            debugPrint("Background: location update sent for $busId");
          },
        );

    debugPrint("Background: GPS stream started for $busId");
  });
}
