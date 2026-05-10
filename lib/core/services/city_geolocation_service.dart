import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CitySuggestion {
  final String city;       // e.g., "Gariyadhar"
  final String district;   // e.g., "Bhavnagar"
  final String state;      // e.g., "Gujarat"
  final String country;    // e.g., "India"
  final String fullName;   // canonical: "Gariyadhar, Bhavnagar, Gujarat"
  final String placeId;
  final double lat;
  final double lng;

  CitySuggestion({
    required this.city,
    this.district = '',
    this.state = '',
    this.country = 'India',
    required this.fullName,
    required this.placeId,
    this.lat = 0.0,
    this.lng = 0.0,
  });

  factory CitySuggestion.fromCanonicalString(String canonical) {
    final parts = canonical.split(',').map((p) => p.trim()).toList();
    return CitySuggestion(
      city:     parts.isNotEmpty ? parts[0] : canonical,
      district: parts.length >= 3 ? parts[1] : '',
      state:    parts.length >= 3
                  ? parts[2]
                  : (parts.length == 2 ? parts[1] : ''),
      country:  'India',
      fullName: canonical,
      placeId:  canonical,
    );
  }
}

class CityGeolocationService {
  static final Map<String, List<CitySuggestion>> _cache = {};

  static String get googleApiKey => dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';

  /// Fetch city / town / village suggestions for India.
  /// Uses Google Places API as primary (best for Indian villages) and Nominatim as fallback.
  static Future<List<CitySuggestion>> fetchCitySuggestions(String query) async {
    if (query.trim().length < 2) return [];

    final normalizedQuery = query.trim().toLowerCase();
    if (_cache.containsKey(normalizedQuery)) {
      return _cache[normalizedQuery]!;
    }

    // Try Google Places first for best coverage
    if (googleApiKey.isNotEmpty) {
      try {
        final suggestions = await _fetchGooglePlaces(query);
        if (suggestions.isNotEmpty) {
          _cache[normalizedQuery] = suggestions;
          return suggestions;
        }
      } catch (e) {
        print('Google Places Error: $e');
      }
    }

    // Fallback to Nominatim
    return _fetchNominatim(query, normalizedQuery);
  }

  static Future<List<CitySuggestion>> _fetchGooglePlaces(String query) async {
    // types=geocode covers all geographical locations (cities, villages, districts, etc.)
    final url = 'https://maps.googleapis.com/maps/api/place/autocomplete/json'
        '?input=${Uri.encodeComponent(query)}'
        '&components=country:in'
        '&types=geocode'
        '&key=$googleApiKey';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      print('Google Places API status code: ${response.statusCode}');
      return [];
    }

    final data = json.decode(response.body);
    if (data['status'] != 'OK') {
      print('Google Places API Status: ${data['status']}');
      if (data['error_message'] != null) print('Error: ${data['error_message']}');
      return [];
    }

    final List<dynamic> predictions = data['predictions'] ?? [];
    final List<CitySuggestion> suggestions = [];

    for (var p in predictions) {
      // Parse terms: Google returns [Name, Area, District, State, Country]
      final terms = (p['terms'] as List<dynamic>?)?.map((t) => t['value'] as String).toList() ?? [];
      
      if (terms.isEmpty) continue;

      String city = terms[0]; // The specific place/village name
      String district = '';
      String state = '';

      // India is usually the last term
      final indiaIdx = terms.indexOf('India');
      final relevantTerms = indiaIdx != -1 ? terms.sublist(0, indiaIdx) : terms;

      if (relevantTerms.length >= 3) {
        // e.g., [Village, District, State]
        city = relevantTerms[0];
        district = relevantTerms[1];
        state = relevantTerms[relevantTerms.length - 1];
      } else if (relevantTerms.length == 2) {
        // e.g., [City, State]
        city = relevantTerms[0];
        state = relevantTerms[1];
      }

      // Build canonical fullName
      final List<String> parts = [city];
      if (district.isNotEmpty && district != city) parts.add(district);
      if (state.isNotEmpty && state != city && state != district) parts.add(state);
      
      final fullName = parts.join(', ');

      suggestions.add(CitySuggestion(
        city: city,
        district: district,
        state: state,
        fullName: fullName,
        placeId: p['place_id'] ?? fullName,
      ));
    }
    return suggestions;
  }

  static Future<List<CitySuggestion>> _fetchNominatim(String query, String normalizedQuery) async {
    try {
      final url = 'https://nominatim.openstreetmap.org/search'
          '?q=${Uri.encodeComponent(query)}'
          '&countrycodes=in'
          '&format=jsonv2'
          '&addressdetails=1'
          '&limit=20';

      final response = await http.get(Uri.parse(url), headers: {
        'User-Agent': 'SavariiApp/1.0',
        'Accept-Language': 'en',
      });

      if (response.statusCode != 200) return [];

      final List<dynamic> results = json.decode(response.body);
      final List<CitySuggestion> suggestions = [];
      final Set<String> seen = {};

      for (final r in results) {
        final category = r['category'] as String? ?? '';
        if (category != 'place' && category != 'boundary') continue;

        final address = r['address'] as Map<String, dynamic>? ?? {};
        final city = _extractCityName(address, r['display_name'] as String? ?? '');
        if (city.isEmpty) continue;

        final type = r['type'] as String? ?? '';
        if (type == 'country' || type == 'state') continue;

        final district = _extractDistrict(address);
        final state = address['state'] as String? ?? '';
        if (state.isEmpty) continue;

        final List<String> parts = [city];
        if (district.isNotEmpty && district != city) parts.add(district);
        if (state.isNotEmpty && state != city && state != district) parts.add(state);
        final fullName = parts.join(', ');

        if (seen.contains(fullName.toLowerCase())) continue;
        seen.add(fullName.toLowerCase());

        suggestions.add(CitySuggestion(
          city: city,
          district: district,
          state: state,
          fullName: fullName,
          placeId: r['osm_id']?.toString() ?? fullName,
        ));
      }

      if (suggestions.isNotEmpty) _cache[normalizedQuery] = suggestions;
      return suggestions;
    } catch (e) {
      print('Nominatim Error: $e');
      return [];
    }
  }

  static String _extractCityName(Map<String, dynamic> address, String displayName) {
    const keys = ['village', 'town', 'city', 'hamlet', 'suburb', 'municipality', 'neighbourhood', 'locality'];
    for (final key in keys) {
      final v = address[key] as String?;
      if (v != null && v.isNotEmpty) return v;
    }
    if (displayName.isNotEmpty) return displayName.split(',').first.trim();
    return '';
  }

  static String _extractDistrict(Map<String, dynamic> address) {
    const keys = ['county', 'state_district', 'district', 'city_district'];
    for (final key in keys) {
      final v = address[key] as String?;
      if (v != null && v.isNotEmpty) {
        return v.replaceAll(RegExp(r'\s*(District|Taluka|Tehsil)\s*$', caseSensitive: false), '').trim();
      }
    }
    return '';
  }

  static void clearCache() => _cache.clear();
}
