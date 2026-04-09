class LocationModel {
  final String id;
  final String name;
  final String city;

  LocationModel({
    required this.id,
    required this.name,
    required this.city,
  });

  factory LocationModel.fromMap(Map<String, dynamic> map, String id) {
    return LocationModel(
      id: map['name'] ?? '',
      name: map['name'] ?? '',
      city: map['city'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'city': city,
    };
  }

  @override
  String toString() => name;
}
