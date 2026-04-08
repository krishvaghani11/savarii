class BusModel {
  final String id;
  final String busName;
  final List<String> route;
  final int totalSeats;
  final String departureTime;
  final String arrivalTime;
  final int price;

  BusModel({
    required this.id,
    required this.busName,
    required this.route,
    required this.totalSeats,
    required this.departureTime,
    required this.arrivalTime,
    required this.price,
  });

  factory BusModel.fromMap(Map<String, dynamic> map, String id) {
    return BusModel(
      id: id,
      busName: map['busName'] ?? '',
      route: List<String>.from(map['route'] ?? []),
      totalSeats: map['totalSeats'] ?? 0,
      departureTime: map['departureTime'] ?? '',
      arrivalTime: map['arrivalTime'] ?? '',
      price: map['price'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'busName': busName,
      'route': route,
      'totalSeats': totalSeats,
      'departureTime': departureTime,
      'arrivalTime': arrivalTime,
      'price': price,
    };
  }
}
