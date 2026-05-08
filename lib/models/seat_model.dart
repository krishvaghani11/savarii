class SeatModel {
  String id;
  int row;
  int col;
  bool isSpace;
  String type; // 'seater' or 'sleeper'
  double price;
  String gender; // 'male', 'female', or 'none'
  String bookingStatus; // 'available', 'booked', 'selected', 'restricted_male', 'restricted_female'

  SeatModel({
    required this.id,
    required this.row,
    required this.col,
    this.isSpace = false,
    this.type = 'seater',
    this.price = 0.0,
    this.gender = 'none',
    this.bookingStatus = 'available',
  });

  factory SeatModel.fromMap(Map<String, dynamic> map) {
    return SeatModel(
      id: map['id'] ?? '',
      row: map['row'] ?? 0,
      col: map['col'] ?? 0,
      isSpace: map['isSpace'] ?? false,
      type: map['type'] ?? 'seater',
      price: (map['price'] ?? 0.0).toDouble(),
      gender: map['gender'] ?? 'none',
      bookingStatus: map['bookingStatus'] ?? 'available',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'row': row,
      'col': col,
      'isSpace': isSpace,
      'type': type,
      'price': price,
      'gender': gender,
      'bookingStatus': bookingStatus,
    };
  }
}

class BusLayoutConfig {
  final int rows;
  final int cols;
  final String preset;
  final String layoutFormat; // e.g. 'sleeper_2x1', 'seater_3x2'
  final List<SeatModel> seats;

  final int upperRows;
  final int upperCols;
  final String upperPreset;
  final String upperLayoutFormat;
  final List<SeatModel> upperSeats;
  final bool hasUpperDeck;

  BusLayoutConfig({
    required this.rows,
    required this.cols,
    required this.preset,
    this.layoutFormat = '',
    required this.seats,
    this.upperRows = 0,
    this.upperCols = 0,
    this.upperPreset = 'custom',
    this.upperLayoutFormat = '',
    this.upperSeats = const [],
    this.hasUpperDeck = false,
  });

  factory BusLayoutConfig.fromMap(Map<String, dynamic> map) {
    return BusLayoutConfig(
      rows: map['rows'] ?? 0,
      cols: map['cols'] ?? 0,
      preset: map['preset'] ?? 'custom',
      layoutFormat: map['layoutFormat'] ?? '',
      seats: (map['seats'] as List<dynamic>? ?? [])
          .map((e) => SeatModel.fromMap(e as Map<String, dynamic>))
          .toList(),
      upperRows: map['upperRows'] ?? 0,
      upperCols: map['upperCols'] ?? 0,
      upperPreset: map['upperPreset'] ?? 'custom',
      upperLayoutFormat: map['upperLayoutFormat'] ?? '',
      upperSeats: (map['upperSeats'] as List<dynamic>? ?? [])
          .map((e) => SeatModel.fromMap(e as Map<String, dynamic>))
          .toList(),
      hasUpperDeck: map['hasUpperDeck'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'rows': rows,
      'cols': cols,
      'preset': preset,
      'layoutFormat': layoutFormat,
      'seats': seats.map((e) => e.toMap()).toList(),
      'upperRows': upperRows,
      'upperCols': upperCols,
      'upperPreset': upperPreset,
      'upperLayoutFormat': upperLayoutFormat,
      'upperSeats': upperSeats.map((e) => e.toMap()).toList(),
      'hasUpperDeck': hasUpperDeck,
    };
  }
}
