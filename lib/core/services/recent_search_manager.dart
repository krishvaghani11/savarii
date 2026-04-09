import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:savarii/models/bus_search_model.dart';

class RecentSearchManager {
  static const String _storageKey = 'recent_searches';
  static const int _maxRecentSearches = 5;

  late SharedPreferences _prefs;

  /// Initialize the manager
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Save a recent search
  Future<void> saveRecentSearch(RecentSearch search) async {
    try {
      final searches = await getRecentSearches();

      // Remove duplicate if exists
      searches.removeWhere(
        (s) => s.fromId == search.fromId && s.toId == search.toId,
      );

      // Add new search at the beginning
      searches.insert(0, search);

      // Keep only last 5 searches
      if (searches.length > _maxRecentSearches) {
        searches.removeRange(_maxRecentSearches, searches.length);
      }

      // Save to SharedPreferences
      final jsonList = searches.map((s) => jsonEncode(s.toMap())).toList();
      await _prefs.setStringList(_storageKey, jsonList);
    } catch (e) {
      print('Error saving recent search: $e');
    }
  }

  /// Get all recent searches
  Future<List<RecentSearch>> getRecentSearches() async {
    try {
      final jsonList = _prefs.getStringList(_storageKey) ?? [];
      return jsonList
          .map((json) => RecentSearch.fromMap(jsonDecode(json)))
          .toList();
    } catch (e) {
      print('Error getting recent searches: $e');
      return [];
    }
  }

  /// Clear all recent searches
  Future<void> clearRecentSearches() async {
    try {
      await _prefs.remove(_storageKey);
    } catch (e) {
      print('Error clearing recent searches: $e');
    }
  }

  /// Delete a specific recent search
  Future<void> deleteRecentSearch(String fromId, String toId) async {
    try {
      final searches = await getRecentSearches();
      searches.removeWhere((s) => s.fromId == fromId && s.toId == toId);

      final jsonList = searches.map((s) => jsonEncode(s.toMap())).toList();
      await _prefs.setStringList(_storageKey, jsonList);
    } catch (e) {
      print('Error deleting recent search: $e');
    }
  }
}

