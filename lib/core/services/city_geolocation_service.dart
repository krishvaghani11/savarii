import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CitySuggestion {
  final String city;
  final String country;
  final String state;
  final String fullName; // e.g., "Surat, Gujarat, India"
  final String placeId;
  final double lat;
  final double lng;

  CitySuggestion({
    required this.city,
    required this.country,
    this.state = '',
    required this.fullName,
    required this.placeId,
    this.lat = 0.0,
    this.lng = 0.0,
  });
}

class CityGeolocationService {
  static String get googleApiKey => dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
  
  // Cache for storing previous queries to minimize API calls
  static final Map<String, List<CitySuggestion>> _cache = {};

  /// Fetch city suggestions from OpenStreetMap Photon API
  /// Returns city-level results
  static Future<List<CitySuggestion>> fetchCitySuggestions(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }

    final normalizedQuery = query.trim().toLowerCase();

    // 1. Check Cache
    if (_cache.containsKey(normalizedQuery)) {
      return _cache[normalizedQuery]!;
    }

    try {
      // 2. Use Photon API (Free, based on OSM Nominatim data)
      final url = 'https://photon.komoot.io/api/?q=${Uri.encodeComponent(query)}&limit=15';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'SavariiApp/1.0',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final features = data['features'] as List<dynamic>? ?? [];

        final List<CitySuggestion> suggestions = [];
        final uniqueCheck = <String>{};

        for (var f in features) {
          final properties = f['properties'] as Map<String, dynamic>? ?? {};
          final geometry = f['geometry'] as Map<String, dynamic>? ?? {};
          
          final key = properties['osm_key'] as String? ?? '';
          
          // Filter to populate primarily places/boundaries
          if (key != 'place' && key != 'boundary' && key != 'highway') continue;

          final name = properties['name'] as String? ?? properties['city'] as String? ?? '';
          if (name.isEmpty) continue;

          final state = properties['state'] as String? ?? '';
          final country = properties['country'] as String? ?? '';
          
          final lat = (geometry['coordinates'] as List<dynamic>?)?[1] as double? ?? 0.0;
          final lng = (geometry['coordinates'] as List<dynamic>?)?[0] as double? ?? 0.0;
          
          final placeId = (properties['osm_id']?.toString()) ?? '${lat}_$lng';

          // Build full name correctly avoiding duplicates like "Surat, Surat, India"
          List<String> parts = [name];
          if (state.isNotEmpty && state != name) parts.add(state);
          if (country.isNotEmpty && country != name && country != state) parts.add(country);
          
          final fullName = parts.join(', ');

          // Deduplication key based on normalized name + state + country
          final dedupKey = '$name, $state, $country'.toLowerCase();

          if (!uniqueCheck.contains(dedupKey)) {
            uniqueCheck.add(dedupKey);
            suggestions.add(CitySuggestion(
              city: name,
              country: country,
              state: state,
              fullName: fullName,
              placeId: placeId,
              lat: lat,
              lng: lng,
            ));
          }
        }

        // 3. Save to cache before returning
        _cache[normalizedQuery] = suggestions;
        return suggestions;
      } else {
        print('Error fetching city suggestions from Photon: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error in fetchCitySuggestions: $e');
      return [];
    }
  }

  /// Get detailed city information (Currently a stub as Photon returns lat/lng directly)
  static Future<Map<String, dynamic>?> getCityDetails(String placeId) async {
    // Left for backwards compatibility if needed, but we don't need Google API details anymore
    return null;
  }
}
