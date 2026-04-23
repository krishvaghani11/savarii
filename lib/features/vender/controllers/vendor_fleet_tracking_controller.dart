import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:savarii/core/services/firestore_service.dart';
import 'package:savarii/core/services/realtime_db_service.dart';
import 'package:savarii/features/auth/controllers/auth_controller.dart';
import 'package:savarii/models/live_tracking_model.dart';

class FleetBusModel {
  final String id;
  final String busNumber;
  final bool isActive;
  final bool isRunning;
  final String status;
  final String speed;
  final String condition;
  final bool isDelayed;
  final String driverName;
  final String driverPhone;

  FleetBusModel({
    required this.id,
    required this.busNumber,
    required this.isActive,
    required this.isRunning,
    required this.status,
    required this.speed,
    required this.condition,
    this.isDelayed = false,
    this.driverName = 'Unknown Driver',
    this.driverPhone = 'N/A',
  });
}

class VendorFleetTrackingController extends GetxController {
  final FirestoreService _firestoreService = Get.find<FirestoreService>();
  final RealtimeDbService _rtdbService = Get.find<RealtimeDbService>();
  final AuthController _authController = Get.find<AuthController>();

  final TextEditingController searchController = TextEditingController();
  final RxString selectedFilter = 'Active'.obs;

  // Real data lists
  final RxList<Map<String, dynamic>> rawBuses = <Map<String, dynamic>>[].obs;
  
  final RxMap<String, LiveTrackingModel?> liveTrackingData = <String, LiveTrackingModel?>{}.obs;

  // Track the selected bus for the map
  final RxString selectedBusId = ''.obs;

  // ── Map State ────────────────────────────────────────────────────────────
  GoogleMapController? mapController;
  final Rx<LatLng> busPosition = const LatLng(23.0225, 72.5714).obs;
  final RxDouble busHeading = 0.0.obs;
  final RxDouble selectedBusSpeed = 0.0.obs;
  final RxSet<Marker> markers = <Marker>{}.obs;

  StreamSubscription? _vendorBusesSubscription;
  final Map<String, StreamSubscription> _trackingSubscriptions = {};
  Timer? _animationTimer;

  LatLng _prevPosition = const LatLng(23.0225, 72.5714);
  LatLng _targetPosition = const LatLng(23.0225, 72.5714);

  BitmapDescriptor? _busIcon;

  @override
  void onInit() {
    super.onInit();
    _loadBusIcon();
    _fetchVendorBuses();
  }

  Future<void> _loadBusIcon() async {
    try {
      _busIcon = await _createRedCarMarker();
    } catch (e) {
      _busIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
    }
  }

  Future<BitmapDescriptor> _createRedCarMarker() async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint()..color = Colors.red;
    const double radius = 30.0;
    canvas.drawCircle(const Offset(radius, radius), radius, paint);

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
    textPainter.paint(
      canvas, 
      Offset((radius * 2 - textPainter.width) / 2, (radius * 2 - textPainter.height) / 2)
    );

    final ui.Picture picture = pictureRecorder.endRecording();
    final ui.Image image = await picture.toImage((radius * 2).toInt(), (radius * 2).toInt());
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }

  void _fetchVendorBuses() {
    final vendorId = _authController.uid;
    if (vendorId == null) return;

    _vendorBusesSubscription = _firestoreService.getVendorBusesStream(vendorId).listen((buses) {
      rawBuses.value = buses;
      
      for (var bus in buses) {
        final busId = bus['id'];
        final isActive = bus['isActive'] == true;
        
        if (isActive && !_trackingSubscriptions.containsKey(busId)) {
          _trackingSubscriptions[busId] = _rtdbService.trackingStream(busId).listen((data) {
            liveTrackingData[busId] = data;
            
            if (selectedBusId.value == busId && data != null) {
              _updateSelectedBusMap(data);
            }
          });
        } else if (!isActive && _trackingSubscriptions.containsKey(busId)) {
          _trackingSubscriptions[busId]?.cancel();
          _trackingSubscriptions.remove(busId);
          liveTrackingData.remove(busId);
        }
      }
      
      if (selectedBusId.value.isEmpty && buses.isNotEmpty) {
        final activeBus = buses.firstWhereOrNull((b) => b['isActive'] == true);
        if (activeBus != null) {
          selectBus(activeBus['id']);
        }
      }
    });
  }

  void _updateSelectedBusMap(LiveTrackingModel data) {
    final newTarget = LatLng(data.latitude, data.longitude);
    _prevPosition = busPosition.value;
    _targetPosition = newTarget;
    busHeading.value = data.heading;
    selectedBusSpeed.value = data.speed;
    _animateMarker();
  }

  void _animateMarker() {
    _animationTimer?.cancel();
    const animationDuration = 500;
    const tickInterval = 16;
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

        final lat = _prevPosition.latitude + (_targetPosition.latitude - _prevPosition.latitude) * t;
        final lng = _prevPosition.longitude + (_targetPosition.longitude - _prevPosition.longitude) * t;
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
      flat: true,
      anchor: const Offset(0.5, 0.5),
      icon: _busIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );
    markers.assignAll({marker});
  }

  void _moveCameraTo(LatLng position) {
    mapController?.animateCamera(CameraUpdate.newLatLng(position));
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    if (busPosition.value.latitude != 0.0) {
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: busPosition.value, zoom: 15.0),
        ),
      );
    }
  }

  void recenterMap() {
    _moveCameraTo(busPosition.value);
  }

  void selectBus(String busId) {
    if (selectedBusId.value == busId) return;
    selectedBusId.value = busId;
    
    final data = liveTrackingData[busId];
    if (data != null) {
      _updateSelectedBusMap(data);
    } else {
      // Clear marker if no data yet
      markers.clear();
    }
  }

  List<FleetBusModel> get fleet {
    final filter = selectedFilter.value;
    final searchQuery = searchController.text.toLowerCase();
    
    return rawBuses.where((bus) {
      final busId = bus['id'];
      final isActive = bus['isActive'] == true;
      final liveData = liveTrackingData[busId];
      final isRunning = isActive && liveData != null && !liveData.isStale(seconds: 120);

      bool matchesFilter = true;
      if (filter == 'Active') {
        matchesFilter = isActive && !isRunning;
      } else if (filter == 'Is Running') {
        matchesFilter = isRunning;
      } else if (filter == 'Offline') {
        matchesFilter = !isActive;
      }

      if (!matchesFilter) return false;

      if (searchQuery.isNotEmpty) {
        final busNumber = bus['busNumber']?.toString().toLowerCase() ?? '';
        if (!busNumber.contains(searchQuery)) return false;
      }

      return true;
    }).map((bus) {
      final busId = bus['id'];
      final busNumber = bus['busNumber']?.toString() ?? 'N/A';
      final isActive = bus['isActive'] == true;
      final liveData = liveTrackingData[busId];
      final isRunning = isActive && liveData != null && !liveData.isStale(seconds: 120);
      
      String status = 'OFFLINE';
      String condition = 'NOT RUNNING';
      if (isRunning) {
        status = 'IN TRANSIT';
        condition = 'CRUISING';
      } else if (isActive) {
        status = 'ACTIVE';
        condition = 'WAITING';
      }

      String speedStr = '0';
      if (liveData != null && isRunning) {
        speedStr = liveData.speed.toStringAsFixed(0);
      }

      final driverData = bus['driver'] as Map<String, dynamic>?;
      final driverName = driverData?['name']?.toString() ?? 'Driver';
      final driverPhone = driverData?['mobile']?.toString() ?? driverData?['phone']?.toString() ?? 'No Contact';

      return FleetBusModel(
        id: busId,
        busNumber: busNumber,
        isActive: isActive,
        isRunning: isRunning,
        status: status,
        speed: speedStr,
        condition: condition,
        isDelayed: false, 
        driverName: driverName,
        driverPhone: driverPhone,
      );
    }).toList();
  }

  void setFilter(String filter) => selectedFilter.value = filter;

  @override
  void onClose() {
    searchController.dispose();
    _vendorBusesSubscription?.cancel();
    for (var sub in _trackingSubscriptions.values) {
      sub.cancel();
    }
    _animationTimer?.cancel();
    mapController?.dispose();
    super.onClose();
  }
}
