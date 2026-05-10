class RecentSearchModel {
  final String fromId;
  final String fromName;        // short city name for display
  final String fromFullName;    // canonical "City, District, State" for matching
  final String toId;
  final String toName;          // short city name for display
  final String toFullName;      // canonical "City, District, State" for matching
  final DateTime timestamp;

  RecentSearchModel({
    required this.fromId,
    required this.fromName,
    this.fromFullName = '',
    required this.toId,
    required this.toName,
    this.toFullName = '',
    required this.timestamp,
  });

  factory RecentSearchModel.fromJson(Map<String, dynamic> json) {
    return RecentSearchModel(
      fromId:       json['fromId']       ?? '',
      fromName:     json['fromName']     ?? '',
      fromFullName: json['fromFullName'] ?? json['fromName'] ?? '', // backward compat
      toId:         json['toId']         ?? '',
      toName:       json['toName']       ?? '',
      toFullName:   json['toFullName']   ?? json['toName'] ?? '', // backward compat
      timestamp:    DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fromId':       fromId,
      'fromName':     fromName,
      'fromFullName': fromFullName,
      'toId':         toId,
      'toName':       toName,
      'toFullName':   toFullName,
      'timestamp':    timestamp.toIso8601String(),
    };
  }
}
