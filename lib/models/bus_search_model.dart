class BusSearchResult {
  final String busId;
  final String busName;
  final String vendorId;
  final List<String> route;
  final List<BusStop> stops;
  final int price;
  final int totalSeats;
  final int availableSeats;
  final bool isActive;
  final bool vendorApproved;
  final String departureTime;
  final String arrivalTime;

  BusSearchResult({
    required this.busId,
    required this.busName,
    required this.vendorId,
    required this.route,
    required this.stops,
    required this.price,
    required this.totalSeats,
    required this.availableSeats,
    required this.isActive,
    required this.vendorApproved,
    required this.departureTime,
    required this.arrivalTime,
  });

  factory BusSearchResult.fromMap(Map<String, dynamic> map, String busId) {
    // Parse stops
    List<BusStop> stops = [];
    if (map['stops'] != null) {
      stops = (map['stops'] as List<dynamic>).map((stop) {
        return BusStop.fromMap(stop as Map<String, dynamic>);
      }).toList();
    }

    return BusSearchResult(
      busId: busId,
      busName: map['busName'] ?? '',
      vendorId: map['vendorId'] ?? '',
      route: List<String>.from(map['route'] ?? []),
      stops: stops,
      price: map['price'] ?? 0,
      totalSeats: map['totalSeats'] ?? 0,
      availableSeats: map['availableSeats'] ?? 0,
      isActive: map['isActive'] ?? false,
      vendorApproved: map['vendorApproved'] ?? false,
      departureTime: '',
      arrivalTime: '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'busName': busName,
      'vendorId': vendorId,
      'route': route,
      'stops': stops.map((s) => s.toMap()).toList(),
      'price': price,
      'totalSeats': totalSeats,
      'availableSeats': availableSeats,
      'isActive': isActive,
      'vendorApproved': vendorApproved,
    };
  }
}

class BusStop {
  final String locationId;
  final String time;

  BusStop({
    required this.locationId,
    required this.time,
  });

  factory BusStop.fromMap(Map<String, dynamic> map) {
    return BusStop(
      locationId: map['locationId'] ?? '',
      time: map['time'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'locationId': locationId,
      'time': time,
    };
  }
}

class RecentSearch {
  final String fromId;
  final String fromName;
  final String toId;
  final String toName;
  final DateTime timestamp;

  RecentSearch({
    required this.fromId,
    required this.fromName,
    required this.toId,
    required this.toName,
    required this.timestamp,
  });

  factory RecentSearch.fromMap(Map<String, dynamic> map) {
    return RecentSearch(
      fromId: map['fromId'] ?? '',
      fromName: map['fromName'] ?? '',
      toId: map['toId'] ?? '',
      toName: map['toName'] ?? '',
      timestamp: DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fromId': fromId,
      'fromName': fromName,
      'toId': toId,
      'toName': toName,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

