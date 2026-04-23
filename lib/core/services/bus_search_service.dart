import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:savarii/models/bus_search_model.dart';

class BusSearchService extends GetxService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Cache for locations to avoid repeated Firestore calls
  final Map<String, String> _locationCache = {};

  /// Fetch location name by ID from Firestore with caching
  Future<String?> getLocationName(String locationId) async {
    // Check cache first
    if (_locationCache.containsKey(locationId)) {
      return _locationCache[locationId];
    }

    try {
      final doc = await _db.collection('locations').doc(locationId).get();
      if (doc.exists) {
        final name = doc.data()?['name'] as String? ?? '';
        // Cache the result
        _locationCache[locationId] = name;
        return name;
      }
    } catch (e) {
      print('Error fetching location: $e');
    }
    return null;
  }

  /// Get all locations (for initial load)
  Future<Map<String, String>> getAllLocations() async {
    try {
      final snapshot = await _db.collection('locations').get();
      for (var doc in snapshot.docs) {
        final name = doc.data()['name'] as String? ?? '';
        _locationCache[doc.id] = name;
      }
      return _locationCache;
    } catch (e) {
      print('Error fetching locations: $e');
      return {};
    }
  }

  /// Search buses based on route (Firestore query)
  /// Step 1: Query buses where route contains fromId
  Future<List<BusSearchResult>> searchBusesFromLocation(String fromId) async {
    try {
      final snapshot = await _db
          .collection('buses')
          .where('route', arrayContains: fromId)
          .where('isActive', isEqualTo: true)
          .where('vendorApproved', isEqualTo: true)
          .get();

      final results = <BusSearchResult>[];
      for (var doc in snapshot.docs) {
        final bus = BusSearchResult.fromMap(doc.data(), doc.id);
        results.add(bus);
      }
      return results;
    } catch (e) {
      print('Error searching buses from location: $e');
      return [];
    }
  }

  /// Filter buses by complete route validation
  /// Step 2: Apply filtering logic (route order, availability, etc.)
  List<BusSearchResult> filterBusesByRoute(
    List<BusSearchResult> buses,
    String fromId,
    String toId,
  ) {
    final filtered = <BusSearchResult>[];

    for (var bus in buses) {
      // Find indexes in route array
      final fromIndex = bus.route.indexOf(fromId);
      final toIndex = bus.route.indexOf(toId);

      // Validation checks
      if (fromIndex == -1 || toIndex == -1) {
        continue; // toId not in route
      }

      if (fromIndex >= toIndex) {
        continue; // fromId must come before toId
      }

      // Check seat availability
      if (bus.availableSeats <= 0) {
        continue; // No available seats
      }

      // All validations passed - add to results
      filtered.add(bus);
    }

    return filtered;
  }

  /// Extract departure and arrival times from stops
  BusSearchResult enrichBusWithTimes(
    BusSearchResult bus,
    String fromId,
    String toId,
  ) {
    String departureTime = '';
    String arrivalTime = '';

    // Find departure time (stop at fromId)
    for (var stop in bus.stops) {
      if (stop.locationId == fromId) {
        departureTime = stop.time;
      }
      if (stop.locationId == toId) {
        arrivalTime = stop.time;
      }
    }

    // Create new BusSearchResult with times
    return BusSearchResult(
      busId: bus.busId,
      busName: bus.busName,
      vendorId: bus.vendorId,
      route: bus.route,
      stops: bus.stops,
      price: bus.price,
      totalSeats: bus.totalSeats,
      availableSeats: bus.availableSeats,
      isActive: bus.isActive,
      vendorApproved: bus.vendorApproved,
      departureTime: departureTime,
      arrivalTime: arrivalTime,
    );
  }

  /// Complete search process
  /// Step 1: Query from Firestore
  /// Step 2: Filter by route logic
  /// Step 3: Extract times
  /// Step 4: Return results
  Future<List<BusSearchResult>> searchBuses(String fromId, String toId) async {
    try {
      // Step 1: Fetch buses where route contains fromId (active & approved)
      final busesFromQuery = await searchBusesFromLocation(fromId);

      // Step 2: Filter by route logic (fromId before toId, toId exists, seats available)
      final filteredBuses = filterBusesByRoute(busesFromQuery, fromId, toId);

      // Step 3: Enrich with departure/arrival times
      final enrichedBuses = filteredBuses.map((bus) {
        return enrichBusWithTimes(bus, fromId, toId);
      }).toList();

      return enrichedBuses;
    } catch (e) {
      print('Error during bus search: $e');
      return [];
    }
  }

  /// Clear location cache (optional, for memory management)
  void clearLocationCache() {
    _locationCache.clear();
  }
}

