class RecentSearchModel {
  final String fromId;
  final String fromName;
  final String toId;
  final String toName;
  final DateTime timestamp;

  RecentSearchModel({
    required this.fromId,
    required this.fromName,
    required this.toId,
    required this.toName,
    required this.timestamp,
  });

  factory RecentSearchModel.fromJson(Map<String, dynamic> json) {
    return RecentSearchModel(
      fromId: json['fromId'],
      fromName: json['fromName'],
      toId: json['toId'],
      toName: json['toName'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fromId': fromId,
      'fromName': fromName,
      'toId': toId,
      'toName': toName,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
