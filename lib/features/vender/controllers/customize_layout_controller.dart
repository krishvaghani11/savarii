import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/seat_model.dart';
import 'add_bus_controller.dart';

class CustomizeLayoutController extends GetxController {
  final AddBusController addBusController = Get.find<AddBusController>();

  // Preset → (leftCols, rightCols, rows)
  static const Map<String, Map<String, int>> _presetConfig = {
    // Sleeper
    'sleeper_2x1': {'left': 1, 'right': 2, 'rows': 6},
    'sleeper_2x2': {'left': 2, 'right': 2, 'rows': 6},
    // Seater
    'seater_3x2': {'left': 2, 'right': 3, 'rows': 12},
    'seater_2x2': {'left': 2, 'right': 2, 'rows': 12},
    'seater_2x1': {'left': 1, 'right': 2, 'rows': 12},
  };

  // Active state bound to UI
  final RxInt rows = 12.obs;
  final RxInt cols = 5.obs;
  final RxString seatType = 'seater'.obs; 
  final RxString selectedPreset = '2x2'.obs;
  final RxList<SeatModel> seats = <SeatModel>[].obs;

  // Deck toggles
  final RxBool isLowerDeck = true.obs;
  final RxBool hasUpperDeck = false.obs;

  // Cached state for swapping
  int _lowerRows = 12;
  int _lowerCols = 5;
  String _lowerType = 'seater';
  String _lowerPreset = '2x2';
  List<SeatModel> _lowerSeats = [];

  int _upperRows = 6;
  int _upperCols = 4;
  String _upperType = 'sleeper';
  String _upperPreset = '2x1';
  List<SeatModel> _upperSeats = [];

  @override
  void onInit() {
    super.onInit();
    if (addBusController.layoutConfig.value != null) {
      final config = addBusController.layoutConfig.value!;
      
      // Load lower deck
      _lowerRows = config.rows;
      _lowerCols = config.cols;
      _lowerPreset = config.preset;
      _lowerType = config.seats.isNotEmpty ? config.seats.first.type : 'seater';
      _lowerSeats = config.seats.toList();
      
      // Load upper deck if present
      hasUpperDeck.value = config.hasUpperDeck;
      if (hasUpperDeck.value) {
        _upperRows = config.upperRows;
        _upperCols = config.upperCols;
        _upperPreset = config.upperPreset;
        _upperType = config.upperSeats.isNotEmpty ? config.upperSeats.first.type : 'sleeper';
        _upperSeats = config.upperSeats.toList();
      }
      
      _loadActiveStateFromCache();
    } else {
      applyPreset(selectedPreset.value);
    }
  }

  void setSeatType(String type) {
    seatType.value = type;
    // Switch to appropriate default preset for the type
    if (type == 'sleeper') {
      selectedPreset.value = '2x2';
    } else {
      selectedPreset.value = '2x2';
    }
    applyPreset(selectedPreset.value);
  }

  void confirmCurrentDeck() {
    Get.snackbar(
      'Deck Confirmed',
      '${isLowerDeck.value ? "Lower" : "Upper"} deck layout has been configured.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
    if (isLowerDeck.value) {
      toggleDeck(false); // Move to upper deck
    }
  }

  void toggleDeck(bool toLower) {
    if (isLowerDeck.value == toLower) return;
    
    // Save current active state to cache before switching
    _saveActiveStateToCache();

    isLowerDeck.value = toLower;

    if (toLower) {
      _loadActiveStateFromCache();
    } else {
      if (!hasUpperDeck.value) {
        hasUpperDeck.value = true;
        // Init upper deck defaults — always sleeper
        seatType.value = 'sleeper';
        selectedPreset.value = '2x1';
        applyPreset(selectedPreset.value);
      } else {
        _loadActiveStateFromCache();
      }
    }
  }

  void _saveActiveStateToCache() {
    if (isLowerDeck.value) {
      _lowerRows = rows.value;
      _lowerCols = cols.value;
      _lowerType = seatType.value;
      _lowerPreset = selectedPreset.value;
      _lowerSeats = seats.toList();
    } else {
      _upperRows = rows.value;
      _upperCols = cols.value;
      _upperType = seatType.value;
      _upperPreset = selectedPreset.value;
      _upperSeats = seats.toList();
    }
  }

  void _loadActiveStateFromCache() {
    if (isLowerDeck.value) {
      rows.value = _lowerRows;
      cols.value = _lowerCols;
      seatType.value = _lowerType;
      selectedPreset.value = _lowerPreset;
      seats.assignAll(_lowerSeats);
    } else {
      rows.value = _upperRows;
      cols.value = _upperCols;
      seatType.value = _upperType;
      selectedPreset.value = _upperPreset;
      seats.assignAll(_upperSeats);
    }
  }

  void applyPreset(String preset) {
    selectedPreset.value = preset;
    final key = '${seatType.value}_$preset'; // e.g. 'sleeper_2x1'
    final config = _presetConfig[key];
    if (config == null) return;

    final int left = config['left']!;
    final int right = config['right']!;
    rows.value = config['rows']!;
    // total cols = left + 1 (aisle) + right
    cols.value = left + 1 + right;
    generateLayout();
  }

  void generateLayout() {
    seats.clear();
    final key = '${seatType.value}_${selectedPreset.value}';
    final config = _presetConfig[key] ?? {'left': 2, 'right': 2, 'rows': 12};

    final int leftCols = config['left']!;
    final int aisleCol = leftCols; // 0-indexed aisle position
    final String deckPrefix = isLowerDeck.value ? '' : 'U';

    for (int r = 0; r < rows.value; r++) {
      int leftLetterIdx = 0;
      int rightLetterIdx = 0;

      for (int c = 0; c < cols.value; c++) {
        final bool isAisle = (c == aisleCol);

        String seatId;
        if (isAisle) {
          seatId = 'space_${r}_$c';
        } else if (c < aisleCol) {
          // Left (non-driver) side
          seatId = '${deckPrefix}L${r + 1}${String.fromCharCode(65 + leftLetterIdx)}';
          leftLetterIdx++;
        } else {
          // Right (driver) side
          seatId = '${deckPrefix}D${r + 1}${String.fromCharCode(65 + rightLetterIdx)}';
          rightLetterIdx++;
        }

        seats.add(SeatModel(
          id: seatId,
          row: r,
          col: c,
          isSpace: isAisle,
          type: seatType.value,
          price: 0.0,
        ));
      }
    }
  }

  void toggleSeatSpace(int index) {
    final seat = seats[index];
    seat.isSpace = !seat.isSpace;
    seats[index] = seat;
    
    // Re-map the IDs of the affected row
    final key = '${seatType.value}_${selectedPreset.value}';
    final config = _presetConfig[key] ?? {'left': 2, 'right': 2, 'rows': 12};
    final int leftCols = config['left']!;
    final int aisleCol = leftCols;
    final String deckPrefix = isLowerDeck.value ? '' : 'U';

    int r = seat.row;
    int leftLetterIdx = 0;
    int rightLetterIdx = 0;
    for (int i = 0; i < seats.length; i++) {
      if (seats[i].row == r) {
        if (!seats[i].isSpace) {
          if (seats[i].col < aisleCol) {
            seats[i].id = '${deckPrefix}L${r + 1}${String.fromCharCode(65 + leftLetterIdx)}';
            leftLetterIdx++;
          } else {
            seats[i].id = '${deckPrefix}D${r + 1}${String.fromCharCode(65 + rightLetterIdx)}';
            rightLetterIdx++;
          }
        } else {
          seats[i].id = 'space_${r}_${seats[i].col}';
        }
      }
    }
    seats.refresh();
  }

  void updateSeatDetails(int index, String newId, double price) {
    final seat = seats[index];
    seat.id = newId;
    seat.price = price;
    seats[index] = seat;
    seats.refresh();
  }

  void updateSeatPrice(int index, double price) {
    final seat = seats[index];
    seat.price = price;
    seats[index] = seat;
    seats.refresh();
  }

  int get totalCapacity {
    int currentActive = seats.where((s) => !s.isSpace).length;
    int hidden = 0;
    if (hasUpperDeck.value) {
      hidden = isLowerDeck.value 
        ? _upperSeats.where((s) => !s.isSpace).length
        : _lowerSeats.where((s) => !s.isSpace).length;
    }
    return currentActive + hidden;
  }

  /// Capacity for the currently visible deck only
  int get currentDeckCapacity {
    return seats.where((s) => !s.isSpace).length;
  }

  double get estimatedRevenue {
    double currentActive = seats.where((s) => !s.isSpace).fold(0.0, (sum, item) => sum + item.price);
    double hidden = 0.0;
    if (hasUpperDeck.value) {
      hidden = isLowerDeck.value 
        ? _upperSeats.where((s) => !s.isSpace).fold(0.0, (sum, item) => sum + item.price)
        : _lowerSeats.where((s) => !s.isSpace).fold(0.0, (sum, item) => sum + item.price);
    }
    return currentActive + hidden;
  }

  void saveLayout() {
    if (totalCapacity <= 0) {
      Get.snackbar(
        'Validation Error',
        'Total capacity cannot be zero. Please ensure at least one valid seat is configured.',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    // Save current active screen back to cache
    _saveActiveStateToCache();

    addBusController.layoutConfig.value = BusLayoutConfig(
      rows: _lowerRows,
      cols: _lowerCols,
      preset: _lowerPreset,
      layoutFormat: '${_lowerType}_$_lowerPreset',
      seats: _lowerSeats.toList(),
      upperRows: _upperRows,
      upperCols: _upperCols,
      upperPreset: _upperPreset,
      upperLayoutFormat: '${_upperType}_$_upperPreset',
      upperSeats: _upperSeats.toList(),
      hasUpperDeck: hasUpperDeck.value,
    );
    
    // Also update total seats in add bus controller
    addBusController.totalSeatsController.text = totalCapacity.toString();

    // Show confirmation and ask if they want to modify another deck
    Get.dialog(
      AlertDialog(
        title: const Text('Layout Saved'),
        content: Text(hasUpperDeck.value 
          ? 'The current layout has been saved. Would you like to modify the other deck or finish?'
          : 'The layout has been saved successfully.'),
        actions: [
          if (hasUpperDeck.value)
            TextButton(
              onPressed: () {
                Get.back(); // close dialog
                toggleDeck(!isLowerDeck.value);
              },
              child: Text('Modify ${isLowerDeck.value ? "Upper" : "Lower"} Deck'),
            ),
          ElevatedButton(
            onPressed: () {
              Get.back(); // close dialog
              Get.back(); // return to previous screen
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Finish'),
          ),
        ],
      ),
    );
  }

  void discardChanges() {
    Get.back();
  }
}
