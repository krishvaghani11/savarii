# Quick Setup Guide - City-Based Bus Search

## Summary of Changes

### ✅ What Was Implemented
1. **CityGeolocationService** - Google Places API integration for city-only suggestions
2. **Updated BusModel** - Added `fromCity` and `toCity` fields
3. **Updated BookTicketController** - Uses geolocation API for city suggestions
4. **Updated SearchResultsController** - Filters buses by city name matching
5. **Updated Views** - BookTicketView and SearchResultsView for proper display

---

## Step-by-Step Setup

### 1️⃣ Update Firestore Bus Documents

Add `fromCity` and `toCity` to all existing bus documents:

```javascript
// In Firestore Console
db.collection('buses').doc('bus_id_1').update({
  'fromCity': 'Surat',
  'toCity': 'Ahmedabad',
  'fromCity': 'Mumbai',
  'toCity': 'Bangalore',
  // ... etc
})
```

**Example Bus Document Structure:**
```json
{
  "busName": "Express Travel Co.",
  "fromCity": "Surat",
  "toCity": "Ahmedabad",
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
```

### 2️⃣ Verify Google API Key

Make sure the Google API key in `city_geolocation_service.dart` is correct:

```dart
static const String googleApiKey = 'AIzaSyAQ4z51oX34F0WzWez-ya-N2IfC6ZAs86w';
```

Enable these APIs in Google Cloud Console:
- ✅ Places API
- ✅ Maps JavaScript API
- ✅ Geolocation API

### 3️⃣ Files Modified/Created

**Created:**
- `lib/core/services/city_geolocation_service.dart` - NEW geolocation service

**Modified:**
- `lib/models/bus_model.dart` - Added fromCity, toCity
- `lib/features/customer/home/controller/book_ticket_controller.dart` - Updated for city suggestions
- `lib/features/customer/home/view/book_ticket_view.dart` - Updated suggestion display
- `lib/features/customer/home/controller/search_results_controller.dart` - Changed filtering logic
- `lib/features/customer/home/view/search_results_view.dart` - Minor updates

### 4️⃣ Test the Feature

**User Flow:**
1. Go to "Book Ticket" page
2. Type "Su" in From field
   - Should see: "Surat, Gujarat, India", "Surapur, Andhra Pradesh, India", etc.
3. Select "Surat, Gujarat, India"
   - Field shows: "Surat"
4. Type "Ah" in To field
   - Should see: "Ahmedabad, Gujarat, India", "Ahemdnagar, Maharashtra, India", etc.
5. Select "Ahmedabad, Gujarat, India"
   - Field shows: "Ahmedabad"
6. Click "Search Buses"
   - Shows all buses where fromCity="Surat" AND toCity="Ahmedabad"
7. Booked seats are locked based on selected date

---

## How It Works

### Search Flow
```
User Input (e.g., "Su")
        ↓
CityGeolocationService.fetchCitySuggestions("Su")
        ↓
Google Places API (only cities)
        ↓
Return: [CitySuggestion{city: "Surat", ...}, ...]
        ↓
Display in Dropdown
        ↓
User Selects City
        ↓
Store: CitySuggestionModel{city: "Surat", ...}
        ↓
Search Buses Button
        ↓
SearchResultsController receives: fromCity="Surat", toCity="Ahmedabad"
        ↓
Fetch all buses, filter by: bus.fromCity == "Surat" && bus.toCity == "Ahmedabad"
        ↓
Fetch seat availability for matching buses
        ↓
Display results with locked seats for booked seats
```

### Seat Locking Logic
```dart
// For each bus on selected date (e.g., "12-04-2026"):
final bookedSeats = bus.bookedSeatsByDate["12-04-2026"] ?? [];
final totalSeats = bus.totalSeats;  // e.g., 45
final bookedCount = bookedSeats.length;  // e.g., 10
final availableCount = totalSeats - bookedCount;  // e.g., 35

// In UI:
if (availableCount > 0) {
  // Show "Select" button (enabled)
} else {
  // Show "Full" button (disabled)
}
```

---

## Data Validation

### City Name Matching
```dart
// All comparisons are case-insensitive and trimmed:
busFromCity.toLowerCase().trim() == searchFromCity.toLowerCase().trim()
```

Examples that MATCH:
- "Surat" == "surat" ✅
- "Surat " == " Surat" ✅
- "SURAT" == "surat" ✅

Examples that DON'T match:
- "Surat" != "Suratgarh" ❌
- "Surat" != "Surat, Gujarat" ❌

---

## Troubleshooting

| Issue | Cause | Solution |
|-------|-------|----------|
| No city suggestions | API key invalid | Verify key in CityGeolocationService |
| | API not enabled | Enable Places API in Google Cloud |
| Wrong buses showing | City names don't match | Check Firestore: `fromCity` == search value |
| Seats not locking | Booked seats not stored | Verify bookings in Firestore |
| | Wrong date format | Use "DD-MM-YYYY" format |

---

## API Response Example

**Request:**
```
GET https://maps.googleapis.com/maps/api/place/autocomplete/json?
  input=Surat&
  types=(cities)&
  key=YOUR_API_KEY
```

**Response:**
```json
{
  "predictions": [
    {
      "description": "Surat, Gujarat, India",
      "place_id": "ChIJ12345...",
      "main_text": "Surat",
      "secondary_text": "Gujarat, India"
    },
    {
      "description": "Surapur, Andhra Pradesh, India",
      "place_id": "ChIJ67890...",
      "main_text": "Surapur",
      "secondary_text": "Andhra Pradesh, India"
    }
  ]
}
```

**Processed Result:**
```dart
CitySuggestion(
  city: "Surat",
  fullName: "Surat, Gujarat, India",
  placeId: "ChIJ12345..."
)
```

---

## Future Enhancements

1. **Multiple Stops** - Show buses with intermediate stops
2. **Smart Sorting** - Sort by price, time, ratings
3. **Filters** - AC/Non-AC, Sleeper/Seater, amenities
4. **Auto-complete** - Show recent cities first
5. **Caching** - Cache API responses locally
6. **Favorites** - Save favorite routes

---

## Contact & Support

For issues with:
- **City suggestions not showing** → Check Google API key
- **Wrong buses displayed** → Verify Firestore `fromCity`/`toCity` values
- **Seat availability incorrect** → Check `bookedSeatsByDate` format


