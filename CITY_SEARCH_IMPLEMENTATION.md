# City-Based Bus Search Implementation Guide

## Overview
This implementation provides a city-based bus search system using the Google Geolocation API for city suggestions and Firestore for bus route matching.

## Architecture

### 1. **City Geolocation Service** (`city_geolocation_service.dart`)
- Uses Google Places API with `(cities)` type filter
- Returns only city-level results, not full addresses
- Extracts city names from results (e.g., "Surat, Gujarat, India" → "Surat")
- Removes duplicate cities

**Key Methods:**
```dart
fetchCitySuggestions(String query) // Returns List<CitySuggestion>
getCityDetails(String placeId)     // Get detailed city info
```

### 2. **Updated BookTicketController**
- Uses `CitySuggestionModel` instead of `LocationModel`
- Listens to text input and calls geolocation API
- Shows city suggestions with full names as subtitles
- Stores only city names (not IDs) for search

**Flow:**
1. User types in "From" field → API called for city suggestions
2. User selects a city → Only city name stored
3. Same for "To" field
4. Click "Search Buses" → Pass city names to search results

### 3. **Updated SearchResultsController**
- Receives `fromCity` and `toCity` from BookTicketController
- Fetches ALL buses from Firestore
- Filters buses by matching `bus.fromCity == searchFromCity && bus.toCity == searchToCity`
- Fetches seat availability for matching buses

**Key Changes:**
```dart
// Old approach (using location IDs)
final allBusesMatchedFrom = await _firestoreService.searchBuses(fromId);

// New approach (using city names)
final allBuses = await _getAllBuses();
final filteredBuses = allBuses.where((bus) {
  final busFromCity = bus.fromCity.toLowerCase().trim();
  final busToCity = bus.toCity.toLowerCase().trim();
  
  final searchFromCity = fromCity.toLowerCase().trim();
  final searchToCity = toCity.toLowerCase().trim();
  
  return busFromCity == searchFromCity && busToCity == searchToCity;
}).toList();
```

### 4. **Updated BusModel**
Added new fields:
```dart
String fromCity;     // Boarding city name (e.g., "Surat")
String toCity;       // Dropping city name (e.g., "Ahmedabad")
```

Kept `route` field as a list of city IDs for future ordering/stops.

## Data Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│ 1. SEARCH PAGE (BookTicketView)                             │
│    - User types city name                                   │
└──────────────────┬──────────────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────────────┐
│ 2. GEOLOCATION API (CityGeolocationService)                 │
│    - Google Places API with (cities) filter                 │
│    - Returns: [CitySuggestion, CitySuggestion, ...]        │
│    - Example: "Surat, Gujarat, India"                       │
└──────────────────┬──────────────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────────────┐
│ 3. CITY SELECTION (BookTicketController)                    │
│    - User selects city from suggestions                     │
│    - Stores: citySuggestionModel.city = "Surat"            │
└──────────────────┬──────────────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────────────┐
│ 4. SEARCH BUSES (searchBuses() method)                       │
│    - Pass fromCity and toCity to search results             │
└──────────────────┬──────────────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────────────┐
│ 5. SEARCH RESULTS PAGE (SearchResultsController)            │
│    - Fetch all buses from Firestore                         │
│    - Filter: bus.fromCity == "Surat" && bus.toCity == "..."│
│    - Result: [BusModel, BusModel, ...]                      │
└──────────────────┬──────────────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────────────┐
│ 6. SEAT AVAILABILITY (SearchResultsView)                    │
│    - Query bookings for selected date                       │
│    - Lock booked seats                                      │
│    - Show available seats count                             │
└─────────────────────────────────────────────────────────────┘
```

## Firestore Data Structure

### Buses Collection
```json
{
  "buses": {
    "bus_doc_1": {
      "busName": "Express Travel Co.",
      "fromCity": "Surat",           // NEW
      "toCity": "Ahmedabad",          // NEW
      "route": ["surat_id", "ahmedabad_id"],
      "totalSeats": 45,
      "departureTime": "10:00 AM",
      "arrivalTime": "1:30 PM",
      "price": 350,
      "description": "Comfortable AC bus",
      "bookedSeatsByDate": {
        "12-04-2026": ["A1", "A2", "B3"],
        "13-04-2026": ["A1", "C2"]
      }
    }
  }
}
```

## Implementation Steps

### Step 1: Add Dependencies
```yaml
# pubspec.yaml
http: ^1.1.0
cloud_firestore: latest
shared_preferences: latest
get: latest
```

### Step 2: Firestore Migration
Update existing bus documents to include `fromCity` and `toCity`:
```dart
// In Firestore console or via admin SDK
db.collection('buses').doc('bus_id').update({
  'fromCity': 'Surat',
  'toCity': 'Ahmedabad'
});
```

### Step 3: Test the Flow
1. Go to Book Ticket page
2. Type "Su" in From field → See city suggestions
3. Select "Surat, Gujarat, India"
4. Type "Ah" in To field → See suggestions
5. Select "Ahmedabad, Gujarat, India"
6. Click Search → See matching buses

## Seat Availability Logic

Seats are locked based on bookings for the selected date:

```dart
// In SearchResultsController._fetchSeatAvailability()
final formattedDate = '12-04-2026'; // DD-MM-YYYY format
final bookedSeats = bus.bookedSeatsByDate[formattedDate] ?? [];
final availableSeats = bus.totalSeats - bookedSeats.length;

// In SearchResultsView._buildBusCard()
if (availableSeats > 0) {
  // Show "Select" button
} else {
  // Show "Full" button (disabled)
}
```

## Error Handling

1. **No cities match**: Show "No buses found" message
2. **API error**: Fallback to empty suggestions
3. **Same From/To cities**: Show error snackbar
4. **Empty selection**: Show error snackbar

## Future Enhancements

1. **Multiple stops**: Parse route array to show intermediate cities
2. **Sorting**: Filter by price, time, ratings
3. **Advanced filters**: AC/Non-AC, Seater/Sleeper
4. **Recent searches**: Display frequently booked routes
5. **Caching**: Store API responses locally

## Code Changes Summary

### Files Modified:
1. `lib/models/bus_model.dart` - Added fromCity, toCity fields
2. `lib/features/customer/home/controller/book_ticket_controller.dart` - Updated to use CityGeolocationService
3. `lib/features/customer/home/view/book_ticket_view.dart` - Updated suggestion display
4. `lib/features/customer/home/controller/search_results_controller.dart` - Changed filtering logic
5. `lib/features/customer/home/view/search_results_view.dart` - Minor updates for city names

### Files Created:
1. `lib/core/services/city_geolocation_service.dart` - New geolocation service

## Testing Checklist

- [ ] City suggestions appear after typing 2+ characters
- [ ] Correct cities are filtered (not full addresses)
- [ ] Selected city displays in input field
- [ ] Search results show only buses with matching from/to cities
- [ ] Booked seats are counted correctly
- [ ] "Select" button disabled for fully booked buses
- [ ] Recent searches work correctly
- [ ] Swap locations button works

## Troubleshooting

**Issue**: No suggestions appearing
- Check Google API key in CityGeolocationService
- Ensure Places API is enabled in Google Cloud Console
- Check network connectivity

**Issue**: Wrong buses showing in results
- Verify bus documents have `fromCity` and `toCity` fields
- Check city names match exactly (case-insensitive, trimmed)

**Issue**: Seat availability incorrect
- Check `bookedSeatsByDate` format is "DD-MM-YYYY"
- Verify bookings are stored correctly in Firestore


