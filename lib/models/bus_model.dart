class BusModel {
  final String id;
  final String busName;
  final List<String> route; // List of city IDs in order
  final String fromCity; // Boarding city name
  final String toCity; // Dropping city name
  final int totalSeats;
  final String departureTime;
  final String arrivalTime;
  final int price;
  final String? description;
  final String vendorId;

  BusModel({
    required this.id,
    required this.busName,
    required this.route,
    required this.fromCity,
    required this.toCity,
    required this.totalSeats,
    required this.departureTime,
    required this.arrivalTime,
    required this.price,
    required this.vendorId,
    this.description,
  });

  factory BusModel.fromMap(Map<String, dynamic> map, String id) {
    List<String> generatedRoute = [];
    String fCity = map['fromCity'] ?? '';
    String tCity = map['toCity'] ?? '';
    String depTime = map['departureTime'] ?? '';
    String arrTime = map['arrivalTime'] ?? '';
    int ticketPrice = map['price'] ?? 0;

    if (map['route'] is Map) {
      final routeMap = map['route'] as Map<String, dynamic>;
      fCity = routeMap['from']?.toString() ?? '';
      tCity = routeMap['to']?.toString() ?? '';
      depTime = routeMap['departureTime']?.toString() ?? '';
      arrTime = routeMap['arrivalTime']?.toString() ?? '';
      
      final priceVal = routeMap['ticketPrice'];
      if (priceVal != null) {
        ticketPrice = priceVal is int ? priceVal : int.tryParse(priceVal.toString()) ?? 0;
      }

      if (fCity.isNotEmpty) generatedRoute.add(fCity);

      final bpList = routeMap['boardingPoints'] as List<dynamic>? ?? [];
      for (var bp in bpList) {
        if (bp is Map && bp['pointName'] != null) {
          generatedRoute.add(bp['pointName'].toString());
        }
      }

      final dpList = routeMap['droppingPoints'] as List<dynamic>? ?? [];
      for (var dp in dpList) {
        if (dp is Map && dp['pointName'] != null) {
          generatedRoute.add(dp['pointName'].toString());
        }
      }

      if (tCity.isNotEmpty) generatedRoute.add(tCity);
    } else if (map['route'] is List) {
      generatedRoute = List<String>.from(map['route']);
    }

    return BusModel(
      id: id,
      busName: map['busName'] ?? '',
      route: generatedRoute,
      fromCity: fCity,
      toCity: tCity,
      totalSeats: map['totalSeats'] ?? 0,
      departureTime: depTime,
      arrivalTime: arrTime,
      price: ticketPrice,
      description: map['description'],
      vendorId: map['vendorId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'busName': busName,
      'route': route,
      'fromCity': fromCity,
      'toCity': toCity,
      'totalSeats': totalSeats,
      'departureTime': departureTime,
      'arrivalTime': arrivalTime,
      'price': price,
      'description': description,
      'vendorId': vendorId,
    };
  }
}
