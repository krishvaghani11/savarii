# City-Based Bus Search - Architecture & Visual Guide

## System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         SAVARII BUS BOOKING APP                         │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────┐
│  1. BOOK TICKET PAGE (book_ticket_view.dart)                            │
│  ┌──────────────────────────────────────────────────────────────────┐   │
│  │ From: [Su           ▼] ← User types city name                   │   │
│  │ ┌──────────────────────────────────┐                             │   │
│  │ │ Surat, Gujarat, India            │ ← API Suggestions          │   │
│  │ │ Suratgarh, Punjab, India         │                             │   │
│  │ │ Surapur, Andhra Pradesh, India   │                             │   │
│  │ └──────────────────────────────────┘                             │   │
│  │                                                                  │   │
│  │ To: [Ah          ▼]                                              │   │
│  │ ┌──────────────────────────────────┐                             │   │
│  │ │ Ahmedabad, Gujarat, India        │                             │   │
│  │ │ Ahmednagar, Maharashtra, India   │                             │   │
│  │ └──────────────────────────────────┘                             │   │
│  │                                                                  │   │
│  │ [Search Buses] Button                                            │   │
│  └──────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────────────┐
│  2. GEOLOCATION API SERVICE (city_geolocation_service.dart)             │
│  ┌──────────────────────────────────────────────────────────────────┐   │
│  │ CityGeolocationService.fetchCitySuggestions("Su")                │   │
│  │                                                                  │   │
│  │ ↓ Google Places API (cities filter)                             │   │
│  │                                                                  │   │
│  │ Response: [                                                     │   │
│  │   {description: "Surat, Gujarat, India", place_id: "..."},      │   │
│  │   {description: "Suratgarh, Punjab, India", place_id: "..."},   │   │
│  │   ...                                                           │   │
│  │ ]                                                               │   │
│  │                                                                  │   │
│  │ ↓ Extract City Names & Remove Duplicates                        │   │
│  │                                                                  │   │
│  │ Return: [                                                       │   │
│  │   CitySuggestion{city: "Surat", fullName: "...", placeId: ...} │   │
│  │   CitySuggestion{city: "Suratgarh", ...}                        │   │
│  │   ...                                                           │   │
│  │ ]                                                               │   │
│  └──────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────────────┐
│  3. BOOK TICKET CONTROLLER (book_ticket_controller.dart)                │
│  ┌──────────────────────────────────────────────────────────────────┐   │
│  │ selectLocation(CitySuggestionModel, isFrom: true)                │   │
│  │                                                                  │   │
│  │ selectedFrom.value = CitySuggestionModel{                        │   │
│  │   city: "Surat",                                                 │   │
│  │   fullName: "Surat, Gujarat, India",                             │   │
│  │   placeId: "ChIJ12345..."                                        │   │
│  │ }                                                               │   │
│  │                                                                  │   │
│  │ fromController.text = "Surat"  ← Display only city name         │   │
│  │ filteredFrom.clear()            ← Hide dropdown                 │   │
│  └──────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────────────┐
│  4. SEARCH BUSES (searchBuses method)                                   │
│  ┌──────────────────────────────────────────────────────────────────┐   │
│  │ Get.toNamed('/search-results', arguments: {                      │   │
│  │   'fromCity': 'Surat',                                           │   │
│  │   'toCity': 'Ahmedabad',                                         │   │
│  │   'date': DateTime(2026, 4, 12),                                 │   │
│  │   'passengers': 2                                                │   │
│  │ })                                                               │   │
│  └──────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────────────┐
│  5. SEARCH RESULTS CONTROLLER (search_results_controller.dart)          │
│  ┌──────────────────────────────────────────────────────────────────┐   │
│  │ fetchResults():                                                  │   │
│  │                                                                  │   │
│  │ Step 1: Fetch ALL buses from Firestore                          │   │
│  │ ┌─────────────────────────────────────────────────────────────┐ │   │
│  │ │ Bus 1: {fromCity: "Surat", toCity: "Ahmedabad", ...}        │ │   │
│  │ │ Bus 2: {fromCity: "Mumbai", toCity: "Bangalore", ...}       │ │   │
│  │ │ Bus 3: {fromCity: "Surat", toCity: "Ahmedabad", ...}        │ │   │
│  │ │ Bus 4: {fromCity: "Delhi", toCity: "Jaipur", ...}           │ │   │
│  │ └─────────────────────────────────────────────────────────────┘ │   │
│  │                                                                  │   │
│  │ Step 2: Filter by city matching                                 │   │
│  │ ┌─────────────────────────────────────────────────────────────┐ │   │
│  │ │ Condition:                                                  │ │   │
│  │ │ bus.fromCity.toLowerCase().trim() == "surat" AND            │ │   │
│  │ │ bus.toCity.toLowerCase().trim() == "ahmedabad"              │ │   │
│  │ │                                                              │ │   │
│  │ │ Result: [Bus 1, Bus 3]  ✓ MATCH                             │ │   │
│  │ └─────────────────────────────────────────────────────────────┘ │   │
│  │                                                                  │   │
│  │ Step 3: Fetch seat availability for each bus                    │   │
│  │ ┌─────────────────────────────────────────────────────────────┐ │   │
│  │ │ For each bus:                                               │ │   │
│  │ │ - Format date: "12-04-2026"                                 │ │   │
│  │ │ - Query: bookedSeatsByDate["12-04-2026"]                    │ │   │
│  │ │ - Result: ["A1", "A2", "B3"] (3 booked)                     │ │   │
│  │ │ - Available: 45 - 3 = 42 seats                               │ │   │
│  │ └─────────────────────────────────────────────────────────────┘ │   │
│  └──────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────────────┐
│  6. SEARCH RESULTS VIEW (search_results_view.dart)                      │
│  ┌──────────────────────────────────────────────────────────────────┐   │
│  │ Surat → Ahmedabad | 12/4/2026 • 2 Travelers                     │   │
│  │                                                                  │   │
│  │ Showing 2 buses                                          Sort by: $ │   │
│  │                                                                  │   │
│  │ ┌──────────────────────────────────────────────────────────────┐│   │
│  │ │ 🚌 Express Travel Co.          4.5★ (120 ratings)  ₹350      ││   │
│  │ │ 10:00 AM ────────────── Estimated ──────────── 1:30 PM       ││   │
│  │ │ Surat                                          Ahmedabad     ││   │
│  │ │ 42 seats available • 3 booked            [Select]  ← Enabled ││   │
│  │ └──────────────────────────────────────────────────────────────┘│   │
│  │                                                                  │   │
│  │ ┌──────────────────────────────────────────────────────────────┐│   │
│  │ │ 🚌 Comfort Travels                4.2★ (89 ratings)   ₹299    ││   │
│  │ │ 2:00 PM ────────────── Estimated ──────────── 5:15 PM        ││   │
│  │ │ Surat                                          Ahmedabad     ││   │
│  │ │ 0 seats available • 45 booked             [Full]  ← Disabled ││   │
│  │ └──────────────────────────────────────────────────────────────┘│   │
│  └──────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────┘
```

## Data Models

### CitySuggestion (from API)
```
CitySuggestion {
  city: String        // e.g., "Surat"
  country: String     // e.g., "India"
  fullName: String    // e.g., "Surat, Gujarat, India"
  placeId: String     // e.g., "ChIJ12345..."
}
```

### CitySuggestionModel (local)
```
CitySuggestionModel {
  city: String        // e.g., "Surat"
  fullName: String    // e.g., "Surat, Gujarat, India"
  placeId: String     // e.g., "ChIJ12345..."
}
```

### BusModel (from Firestore)
```
BusModel {
  id: String
  busName: String              // e.g., "Express Travel Co."
  fromCity: String             // e.g., "Surat" (NEW)
  toCity: String               // e.g., "Ahmedabad" (NEW)
  route: List<String>          // ["surat_id", "ahmedabad_id"]
  totalSeats: int              // e.g., 45
  departureTime: String        // e.g., "10:00 AM"
  arrivalTime: String          // e.g., "1:30 PM"
  price: int                   // e.g., 350
  bookedSeatsByDate: Map       // {"12-04-2026": ["A1", "A2", ...]}
}
```

## Firestore Collection Structure

```
┌─ buses (collection)
│  ├─ bus_doc_1 (document)
│  │  ├─ busName: "Express Travel Co."
│  │  ├─ fromCity: "Surat"
│  │  ├─ toCity: "Ahmedabad"
│  │  ├─ route: ["surat_id", "ahmedabad_id"]
│  │  ├─ totalSeats: 45
│  │  ├─ departureTime: "10:00 AM"
│  │  ├─ arrivalTime: "1:30 PM"
│  │  ├─ price: 350
│  │  └─ bookedSeatsByDate: (map)
│  │     ├─ "12-04-2026": ["A1", "A2", "B3"]
│  │     └─ "13-04-2026": ["A1", "C2"]
│  │
│  ├─ bus_doc_2 (document)
│  │  ├─ busName: "Comfort Travels"
│  │  ├─ fromCity: "Mumbai"
│  │  ├─ toCity: "Bangalore"
│  │  └─ ...
│  │
│  └─ ...
│
└─ tickets (collection)
   └─ ...
```

## Flow Sequence Diagram

```
User                Controller              Service              Firestore
 │                     │                      │                      │
 │─ Type "Su" ────────→│                      │                      │
 │                     │─ Listen to input ────→│                      │
 │                     │                      │─ Google API call ────→
 │                     │                      │← City suggestions ───│
 │←── Show dropdown ───│← Return suggestions ─│                      │
 │                     │                      │                      │
 │─ Select "Surat" ────│                      │                      │
 │                     │─ selectLocation() ──→│                      │
 │←── Hide dropdown ───│─ Clear filtered ────→│                      │
 │                     │                      │                      │
 │─ (Same for "To") ───│                      │                      │
 │                     │                      │                      │
 │─ Click Search ──────│                      │                      │
 │                     │─ searchBuses() ─────→│                      │
 │                     │                      │                      │
 │                     │─ Navigate to results │                      │
 │                     │                      │                      │
 │                     │─────── SearchResultsController ──────────────│
 │                     │                      │                      │
 │                     │                      │ getAllBuses() ──────→│
 │                     │                      │←─ All buses ────────│
 │                     │                      │                      │
 │                     │                      │ Filter by:          │
 │                     │                      │ fromCity="Surat"    │
 │                     │                      │ toCity="Ahmedabad"  │
 │                     │                      │                      │
 │                     │                      │ For each match:     │
 │                     │                      │ getBookedSeats("12-04-2026")
 │                     │                      │←─ Booked count ────│
 │                     │                      │                      │
 │←── Show Results ────│←── Filtered results ─│                      │
 │                     │   with seats count   │                      │
 │                     │                      │                      │
 │─ Click Select ──────│                      │                      │
 │                     │─ Navigate to seats ─→│                      │
```

## Key Logic Points

### 1. City Matching (Case-Insensitive)
```dart
busFromCity.toLowerCase().trim() == searchFromCity.toLowerCase().trim()

// Examples:
"Surat".toLowerCase().trim() == "surat".toLowerCase().trim()    // ✓ Match
"Surat ".toLowerCase().trim() == " Surat".toLowerCase().trim()  // ✓ Match
"SURAT".toLowerCase().trim() == "surat".toLowerCase().trim()    // ✓ Match
"Surat".toLowerCase().trim() == "Suratgarh".toLowerCase().trim() // ✗ No match
```

### 2. Date Formatting
```dart
// Input: DateTime(2026, 4, 12)
// Output: "12-04-2026" (DD-MM-YYYY)

final formattedDate = '${date.day.toString().padLeft(2, '0')}-'
                      '${date.month.toString().padLeft(2, '0')}-'
                      '${date.year}';
```

### 3. Seat Availability Calculation
```dart
final bookedCount = bookedSeats.length;  // e.g., 3
final totalSeats = bus.totalSeats;       // e.g., 45
final availableCount = totalSeats - bookedCount;  // e.g., 42

// UI Decision:
if (availableCount > 0) {
  // Show "Select" button (enabled)
} else {
  // Show "Full" button (disabled, greyed out)
}
```

## Error Handling

```
┌─ No cities typed
│  └─ Clear suggestions
│
├─ API returns no results
│  └─ Show empty suggestions list
│
├─ User doesn't select location
│  └─ Show error: "Please select valid From and To cities"
│
├─ Same From and To city selected
│  └─ Show error: "From and To cities cannot be the same"
│
└─ No buses match criteria
   └─ Show: "No buses found for this route"
```

---

This architecture ensures:
✅ **City-Only Search** - No full addresses, just city names
✅ **Smart Filtering** - Only shows buses on the route
✅ **Real Seat Locking** - Booked seats locked for selected date
✅ **Case-Insensitive Matching** - "SURAT" == "surat"
✅ **Error Handling** - Graceful fallbacks for all scenarios

