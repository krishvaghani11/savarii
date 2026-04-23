import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:savarii/core/services/realtime_db_service.dart';
import 'package:savarii/models/live_tracking_model.dart';

enum TrackingStatus {
  loading,
  waitingForBus,
  active,
  paused,
  completed,
  tripNotFound,
}

class TrackBusController extends GetxController {
  final RealtimeDbService _rtdbService = Get.find<RealtimeDbService>();

  // ── Input ────────────────────────────────────────────────────────────────────
  late final String tripId;

  // ── Trip / Bus / Driver Info ─────────────────────────────────────────────────
  final RxString busNumber = ''.obs;
  final RxString driverName = ''.obs;
  final RxString driverPhone = ''.obs;

  // ── Live Location ────────────────────────────────────────────────────────────
  final Rx<LatLng> busPosition = const LatLng(23.0225, 72.5714).obs;
  final RxDouble busHeading = 0.0.obs;
  final RxDouble busSpeed = 0.0.obs;
  final RxString lastUpdatedText = '--'.obs;

  // ── Tracking State ───────────────────────────────────────────────────────────
  final Rx<TrackingStatus> trackingStatus = TrackingStatus.loading.obs;

  // ── Map Controller ───────────────────────────────────────────────────────────
  GoogleMapController? mapController;
  final RxSet<Marker> markers = <Marker>{}.obs;

  // ── Internals ────────────────────────────────────────────────────────────────
  StreamSubscription<LiveTrackingModel?>? _trackingSubscription;
  Timer? _animationTimer;
  Timer? _stalenessTimer;

  // Previous position for smooth interpolation
  LatLng _prevPosition = const LatLng(23.0225, 72.5714);
  LatLng _targetPosition = const LatLng(23.0225, 72.5714);

  // Custom marker icon (loaded once)
  BitmapDescriptor? _busIcon;

  @override
  void onInit() {
    super.onInit();

    // Read trip_id from navigation arguments
    final args = Get.arguments as Map<String, dynamic>?;
    tripId = args?['trip_id']?.toString() ?? '';

    if (tripId.isEmpty) {
      trackingStatus.value = TrackingStatus.tripNotFound;
      return;
    }

    _initialize();
  }

  Future<void> _initialize() async {
    trackingStatus.value = TrackingStatus.loading;

    // 1. Load custom bus marker icon
    await _loadBusIcon();

    // 2. Fetch bus metadata directly using tripId (which acts as busId)
    final busId = tripId;
    final bus = await _rtdbService.getBusDetails(busId);
    if (bus == null) {
      trackingStatus.value = TrackingStatus.tripNotFound;
      return;
    }

    busNumber.value = bus['busNumber']?.toString() ?? 'N/A';
    
    // Check if bus is active (or driver status)
    if (bus['isActive'] == false) {
      // Might be completed or not running
    }

    // Load driver info from bus document
    final driverData = bus['driver'] as Map<String, dynamic>?;
    if (driverData != null) {
      driverName.value = driverData['name']?.toString() ?? 'Driver';
      driverPhone.value = driverData['mobile']?.toString() ?? driverData['phone']?.toString() ?? '';
    }

    // 4. Subscribe to RTDB live tracking
    _subscribeLiveTracking();

    // 5. Staleness check every 10 seconds
    _stalenessTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _checkStaleness();
    });
  }

  // ── RTDB Listener ─────────────────────────────────────────────────────────────

  void _subscribeLiveTracking() {
    _trackingSubscription =
        _rtdbService.trackingStream(tripId).listen((data) {
      if (data == null) {
        if (trackingStatus.value != TrackingStatus.active) {
          trackingStatus.value = TrackingStatus.waitingForBus;
        }
        return;
      }

      final newTarget = LatLng(data.latitude, data.longitude);

      // Animate to new position
      _prevPosition = busPosition.value;
      _targetPosition = newTarget;
      _animateMarker();

      busHeading.value = data.heading;
      busSpeed.value = data.speed;

      // Update "last updated" text
      _updateLastUpdatedText(data.updatedAt);

      // Mark as active if not stale (120 seconds = 2 mins)
      if (!data.isStale(seconds: 120)) {
        trackingStatus.value = TrackingStatus.active;
      } else {
        trackingStatus.value = TrackingStatus.paused;
      }
    }, onError: (e) {
      debugPrint('TrackBusController: RTDB error: $e');
    });
  }

  // ── Smooth Marker Animation ───────────────────────────────────────────────────

  void _animateMarker() {
    _animationTimer?.cancel();

    const animationDuration = 500; // ms
    const tickInterval = 16; // ms (~60fps)
    final totalTicks = animationDuration ~/ tickInterval;
    int tick = 0;

    _animationTimer = Timer.periodic(
      const Duration(milliseconds: tickInterval),
      (timer) {
        tick++;
        final t = tick / totalTicks;
        if (t >= 1.0) {
          timer.cancel();
          busPosition.value = _targetPosition;
          _updateMarker(_targetPosition);
          _moveCameraTo(_targetPosition);
          return;
        }

        // Linear interpolation
        final lat =
            _prevPosition.latitude + (_targetPosition.latitude - _prevPosition.latitude) * t;
        final lng =
            _prevPosition.longitude + (_targetPosition.longitude - _prevPosition.longitude) * t;
        final interpolated = LatLng(lat, lng);

        busPosition.value = interpolated;
        _updateMarker(interpolated);
      },
    );
  }

  void _updateMarker(LatLng position) {
    final marker = Marker(
      markerId: const MarkerId('bus'),
      position: position,
      rotation: busHeading.value,
      flat: true, // Rotate with map heading
      anchor: const Offset(0.5, 0.5),
      icon: _busIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      infoWindow: InfoWindow(
        title: busNumber.value.isEmpty ? 'Bus' : busNumber.value,
        snippet: '${busSpeed.value.toStringAsFixed(0)} km/h',
      ),
    );
    markers.assignAll({marker});
  }

  void _moveCameraTo(LatLng position) {
    mapController?.animateCamera(CameraUpdate.newLatLng(position));
  }

  // ── Staleness Check ──────────────────────────────────────────────────────────

  void _checkStaleness() {
    if (trackingStatus.value != TrackingStatus.active &&
        trackingStatus.value != TrackingStatus.paused) {
      return;
    }

    // If no position update for >30s, mark as paused
    // We do this via the isStale check in the stream listener,
    // but also re-check here for UI freshness.
    if (trackingStatus.value == TrackingStatus.active) {
      final lastUpdated = _lastUpdatedEpoch;
      if (lastUpdated > 0) {
        final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        if ((now - lastUpdated) > 120) {
          trackingStatus.value = TrackingStatus.paused;
        }
      }
    }
  }

  int _lastUpdatedEpoch = 0;

  void _updateLastUpdatedText(int epoch) {
    _lastUpdatedEpoch = epoch;
    final dt = DateTime.fromMillisecondsSinceEpoch(epoch * 1000);
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inSeconds < 10) {
      lastUpdatedText.value = 'Just now';
    } else if (diff.inSeconds < 60) {
      lastUpdatedText.value = '${diff.inSeconds}s ago';
    } else if (diff.inMinutes < 60) {
      lastUpdatedText.value = '${diff.inMinutes}m ago';
    } else {
      lastUpdatedText.value =
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
  }

  // ── Custom Bus Icon ──────────────────────────────────────────────────────────

  Future<void> _loadBusIcon() async {
    try {
      _busIcon = await _createRedCarMarker();
    } catch (e) {
      // Fallback to default red marker if asset not found
      _busIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      debugPrint('TrackBusController: Using default bus marker icon. $e');
    }
  }

  Future<BitmapDescriptor> _createRedCarMarker() async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint()..color = Colors.red;
    
    // Draw a red circle
    const double radius = 30.0;
    canvas.drawCircle(const Offset(radius, radius), radius, paint);

    // Draw car icon inside the circle
    final TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: String.fromCharCode(Icons.directions_car.codePoint),
      style: TextStyle(
        fontSize: 36.0,
        fontFamily: Icons.directions_car.fontFamily,
        package: Icons.directions_car.fontPackage,
        color: Colors.white,
      ),
    );
    textPainter.layout();
    
    // Center the icon
    textPainter.paint(
      canvas, 
      Offset((radius * 2 - textPainter.width) / 2, (radius * 2 - textPainter.height) / 2)
    );

    final ui.Picture picture = pictureRecorder.endRecording();
    final ui.Image image = await picture.toImage((radius * 2).toInt(), (radius * 2).toInt());
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    
    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }

  // ── Map Callbacks ────────────────────────────────────────────────────────────

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    // Move camera to current bus position immediately
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: busPosition.value, zoom: 15.0),
      ),
    );
  }

  void recenterMap() {
    _moveCameraTo(busPosition.value);
  }

  // ── Driver Call ──────────────────────────────────────────────────────────────

  Future<void> callDriver() async {
    final phone = driverPhone.value;
    if (phone.isEmpty) {
      Get.snackbar('No Contact', 'Driver phone number not available.',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      Get.snackbar('Error', 'Cannot open phone dialer.',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  // ── Getters for UI ───────────────────────────────────────────────────────────

  String get statusLabel {
    switch (trackingStatus.value) {
      case TrackingStatus.loading:
        return 'Loading...';
      case TrackingStatus.waitingForBus:
        return 'Waiting for bus to start';
      case TrackingStatus.active:
        return busSpeed.value > 2 ? 'Running' : 'Stopped';
      case TrackingStatus.paused:
        return 'Tracking paused';
      case TrackingStatus.completed:
        return 'Trip completed';
      case TrackingStatus.tripNotFound:
        return 'Trip not found';
    }
  }

  bool get isRunning =>
      trackingStatus.value == TrackingStatus.active && busSpeed.value > 2;

  // ── Cleanup ──────────────────────────────────────────────────────────────────

  @override
  void onClose() {
    _trackingSubscription?.cancel();
    _animationTimer?.cancel();
    _stalenessTimer?.cancel();
    mapController?.dispose();
    super.onClose();
  }
}
