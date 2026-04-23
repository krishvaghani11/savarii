/// Model representing a live_tracking/{trip_id} document in Firebase RTDB.
class LiveTrackingModel {
  final double latitude;
  final double longitude;
  final double heading; // degrees 0–360
  final double speed; // km/h
  final int updatedAt; // Unix timestamp in seconds

  const LiveTrackingModel({
    required this.latitude,
    required this.longitude,
    required this.heading,
    required this.speed,
    required this.updatedAt,
  });

  factory LiveTrackingModel.fromMap(Map<dynamic, dynamic> map) {
    return LiveTrackingModel(
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      heading: (map['heading'] as num?)?.toDouble() ?? 0.0,
      speed: (map['speed'] as num?)?.toDouble() ?? 0.0,
      updatedAt: (map['updated_at'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'heading': heading,
      'speed': speed,
      'updated_at': updatedAt,
    };
  }

  /// Returns true if the last update was more than [seconds] ago.
  bool isStale({int seconds = 30}) {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return (now - updatedAt) > seconds;
  }

  @override
  String toString() =>
      'LiveTrackingModel(lat: $latitude, lng: $longitude, heading: $heading°, speed: ${speed}km/h)';
}
