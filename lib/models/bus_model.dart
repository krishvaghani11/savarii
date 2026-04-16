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
  final String busNumber;
  final List<String> boardingPoints;
  final List<String> droppingPoints;
  final String driverName;
  final String driverPhone;

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
    required this.busNumber,
    required this.boardingPoints,
    required this.droppingPoints,
    this.driverName = 'Unknown Driver',
    this.driverPhone = 'No Contact Info',
    this.description,
  });

  factory BusModel.fromMap(Map<String, dynamic> map, String id) {
    List<String> generatedRoute = [];
    List<String> bps = [];
    List<String> dps = [];
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

      // Automatically include main departure city as a boarding point
      if (fCity.isNotEmpty) {
        generatedRoute.add(fCity);
        bps.add("$fCity - $depTime");
      }

      final bpList = routeMap['boardingPoints'] as List<dynamic>? ?? [];
      for (var bp in bpList) {
        if (bp is Map && bp['pointName'] != null) {
          final pName = bp['pointName'].toString();
          final pTime = bp['pointTime']?.toString() ?? '';
          bps.add("$pName - $pTime");
          generatedRoute.add(pName);
        }
      }

      final dpList = routeMap['droppingPoints'] as List<dynamic>? ?? [];
      for (var dp in dpList) {
        if (dp is Map && dp['pointName'] != null) {
          final pName = dp['pointName'].toString();
          final pTime = dp['pointTime']?.toString() ?? '';
          dps.add("$pName - $pTime");
          generatedRoute.add(pName);
        }
      }

      // Automatically include main arrival city as a dropping point
      if (tCity.isNotEmpty) {
        generatedRoute.add(tCity);
        dps.add("$tCity - $arrTime");
      }
    } else if (map['route'] is List) {
      generatedRoute = List<String>.from(map['route']);
    }

    final driverMap = map['driver'] as Map<String, dynamic>? ?? {};
    final drName = driverMap['name']?.toString() ?? 'Unknown Driver';
    final drPhone = driverMap['mobile']?.toString() ?? 'No Contact Info';

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
      busNumber: map['busNumber'] ?? '',
      boardingPoints: bps,
      droppingPoints: dps,
      driverName: drName,
      driverPhone: drPhone,
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
      'busNumber': busNumber,
      'boardingPoints': boardingPoints,
      'droppingPoints': droppingPoints,
      'driverName': driverName,
      'driverPhone': driverPhone,
    };
  }
}
