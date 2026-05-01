import 'package:firebase_messaging/firebase_messaging.dart';

/// Every notification sent by Cloud Functions must include these data fields.
/// The [type] field is the single routing key used by [NotificationRoutes].
class NotificationPayload {
  final String type;
  final String title;
  final String body;
  final String? bookingId;
  final String? busId;
  final String? vendorId;
  final String? driverId;
  final String? ticketId;
  final Map<String, String> raw;

  const NotificationPayload({
    required this.type,
    required this.title,
    required this.body,
    this.bookingId,
    this.busId,
    this.vendorId,
    this.driverId,
    this.ticketId,
    required this.raw,
  });

  factory NotificationPayload.fromMessage(RemoteMessage message) {
    final data = message.data;
    final notification = message.notification;
    return NotificationPayload(
      type: data['type'] ?? 'unknown',
      title: notification?.title ?? data['title'] ?? 'Savarii',
      body: notification?.body ?? data['body'] ?? '',
      bookingId: data['bookingId'],
      busId: data['busId'],
      vendorId: data['vendorId'],
      driverId: data['driverId'],
      ticketId: data['ticketId'],
      raw: data.map((k, v) => MapEntry(k, v.toString())),
    );
  }

  @override
  String toString() =>
      'NotificationPayload(type: $type, title: $title, bookingId: $bookingId)';
}
