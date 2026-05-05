import '../../../routes/app_routes.dart';

/// Maps every notification [type] string (set by Cloud Functions) to a named
/// GetX route.  Adding a new notification type only requires a new entry here.
///
/// Rules:
///   - Routes must be defined in [AppRoutes].
///   - Null means the notification has no deep-link target (informational only).
class NotificationRoutes {
  NotificationRoutes._();

  /// Returns the route name for a given notification type, or null if the
  /// notification has no deep-link screen.
  static String? routeFor(String type) => _map[type];

  /// Whether this notification type requires a [bookingId] argument to
  /// navigate correctly.
  static bool requiresBookingId(String type) =>
      _bookingLinked.contains(type);

  /// Whether this notification type requires a [busId] argument.
  static bool requiresBusId(String type) => _busLinked.contains(type);

  // ── Route map ────────────────────────────────────────────────────────────

  static const Map<String, String> _map = {
    // ── Customer ─────────────────────────────────────────────────────────
    'booking_confirmed': AppRoutes.myBookings,
    'payment_success': AppRoutes.myBookings,
    'payment_failure': AppRoutes.myBookings,
    'ticket_cancelled': AppRoutes.myBookings,
    'refund_processed': AppRoutes.myBookings,
    'driver_assigned': AppRoutes.trackBus,
    'trip_started': AppRoutes.trackBus,
    'bus_arriving_soon': AppRoutes.trackBus,
    'boarding_reminder': AppRoutes.trackBus,
    'drop_point_approaching': AppRoutes.trackBus,
    'destination_reached': AppRoutes.myBookings,
    'bus_delayed': AppRoutes.trackBus,
    'route_changed': AppRoutes.trackBus,
    'unexpected_stop': AppRoutes.trackBus,
    'trip_cancelled_by_vendor': AppRoutes.myBookings,
    'vehicle_breakdown_alert': AppRoutes.trackBus,
    'bus_reached_boarding_point': AppRoutes.trackBus,
    'boarding_point_nearby': AppRoutes.trackBus,
    'seat_updated': AppRoutes.myBookings,
    'trip_reminder_24hr': AppRoutes.myBookings,
    'trip_reminder_2hr': AppRoutes.myBookings,
    'delay_recovered': AppRoutes.trackBus,
    'ticket_email_fallback': AppRoutes.myBookings,  // v3: push fallback when email fails

    // ── Vendor ────────────────────────────────────────────────────────────
    'new_booking_received': AppRoutes.vendorViewTickets,
    'booking_cancellation_alert': AppRoutes.vendorViewTickets,
    'bus_nearly_full': AppRoutes.vendorViewTickets,
    'bus_fully_booked': AppRoutes.vendorViewTickets,
    'driver_assigned_confirmation': AppRoutes.vendorDriverManagement,
    'driver_route_deviation': AppRoutes.vendorFleetTracking,
    'driver_offline_alert': AppRoutes.vendorFleetTracking,
    'unexpected_long_stop': AppRoutes.vendorFleetTracking,
    'trip_delay_warning': AppRoutes.vendorFleetTracking,
    'trip_start_reminder': AppRoutes.vendorFleetTracking,
    'driver_late_start_alert': AppRoutes.vendorFleetTracking,
    'low_occupancy_alert': AppRoutes.vendorViewTickets,
    'high_demand_alert': AppRoutes.vendorViewTickets,
    'cancellation_spike_alert': AppRoutes.vendorViewTickets,

    // ── Driver ────────────────────────────────────────────────────────────
    'new_trip_assigned': AppRoutes.driverHome,
    'trip_status_changed': AppRoutes.driverHome,
    'boarding_reminder_driver': AppRoutes.driverHome,
    'passenger_waiting_alert': AppRoutes.driverHome,
    'speed_warning': AppRoutes.driverHome,
  };

  static const Set<String> _bookingLinked = {
    'booking_confirmed',
    'payment_success',
    'payment_failure',
    'ticket_cancelled',
    'refund_processed',
    'destination_reached',
    'new_booking_received',
    'booking_cancellation_alert',
    'seat_updated',
    'trip_reminder_24hr',
    'trip_reminder_2hr',
    'ticket_email_fallback',  // v3: push fallback when email fails
  };

  static const Set<String> _busLinked = {
    'driver_assigned',
    'trip_started',
    'bus_arriving_soon',
    'boarding_reminder',
    'drop_point_approaching',
    'bus_delayed',
    'route_changed',
    'unexpected_stop',
    'bus_nearly_full',
    'bus_fully_booked',
    'driver_route_deviation',
    'driver_offline_alert',
    'unexpected_long_stop',
    'trip_delay_warning',
    'trip_start_reminder',
    'trip_cancelled_by_vendor',
    'vehicle_breakdown_alert',
    'bus_reached_boarding_point',
    'boarding_point_nearby',
    'driver_late_start_alert',
    'low_occupancy_alert',
    'passenger_waiting_alert',
  };
}
