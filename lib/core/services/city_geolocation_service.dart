import 'dart:convert';
import 'package:http/http.dart' as http;

class CitySuggestion {
  final String city;
  final String country;
  final String fullName; // e.g., "Surat, Gujarat, India"
  final String placeId;

  CitySuggestion({
    required this.city,
    required this.country,
    required this.fullName,
    required this.placeId,
  });
}

class CityGeolocationService {
  static const String googleApiKey = '';//YOUR API KEY HERE

  /// Fetch city suggestions from Google Places API
  /// Returns only city-level results, not detailed addresses
  static Future<List<CitySuggestion>> fetchCitySuggestions(String query) async {
    if (query.isEmpty) {
      return [];
    }

    try {
      // Use Google Places Autocomplete with (cities) type filter
      final url =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&types=(cities)&key=$googleApiKey';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final predictions = data['predictions'] as List<dynamic>? ?? [];

        final suggestions = predictions.map((p) {
          final description = p['description'] as String? ?? '';
          final placeId = p['place_id'] as String? ?? '';

          // Extract city name from description
          // Format is usually: "City, State/Province, Country"
          final parts = description.split(',').map((s) => s.trim()).toList();
          final city = parts.isNotEmpty ? parts[0] : description;
          final country = parts.length > 1 ? parts.last : '';

          return CitySuggestion(
            city: city,
            country: country,
            fullName: description,
            placeId: placeId,
          );
        }).toList();

        // Remove duplicates based on city name
        final uniqueSuggestions = <String, CitySuggestion>{};
        for (var suggestion in suggestions) {
          uniqueSuggestions[suggestion.city.toLowerCase()] = suggestion;
        }

        return uniqueSuggestions.values.toList();
      } else {
        print('Error fetching city suggestions: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error in fetchCitySuggestions: $e');
      return [];
    }
  }

  /// Get detailed city information using Google Places Details API
  static Future<Map<String, dynamic>?> getCityDetails(String placeId) async {
    try {
      final url =
          'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$googleApiKey';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final result = data['result'] as Map<String, dynamic>? ?? {};
        return result;
      }
      return null;
    } catch (e) {
      print('Error in getCityDetails: $e');
      return null;
    }
  }
}

