import 'package:flutter/material.dart';
import 'package:savarii/core/theme/app_colors.dart';
import 'package:savarii/core/theme/app_text_styles.dart';
import 'package:savarii/models/seat_model.dart';

/// A shared bus seat layout widget used by both vendor and customer screens.
///
/// Seat ID standard (5-row × 3-seat bus: 1 left + 2 right):
///   Lower deck:  L1–L5 (left), R1–R5 (right-inner), R6–R10 (right-outer)
///   Upper deck: UL1–UL5,       UR1–UR5,              UR6–UR10
///
/// This ensures vendor and customer always see the same seat at the same position.
class BusSeatLayout extends StatelessWidget {
  final List<String> bookedSeats;
  final Map<String, String> seatGenders; // seatId -> 'male' or 'female'
  final List<String> selectedSeats;
  final bool isUpperDeck;
  final void Function(String seatId) onSeatTap;
  final BusLayoutConfig? layoutConfig;
  final double defaultPrice;

  const BusSeatLayout({
    super.key,
    required this.bookedSeats,
    this.seatGenders = const {},
    required this.selectedSeats,
    required this.isUpperDeck,
    required this.onSeatTap,
    this.layoutConfig,
    this.defaultPrice = 0.0,
  });

  /// Generates the canonical seat ID for a given position.
  static String seatId({
    required bool upper,
    required String side, // 'left', 'rightInner', 'rightOuter'
    required int row,     // 1..5
  }) {
    final p = upper ? 'U' : '';
    switch (side) {
      case 'left':
        return '${p}L$row';
      case 'rightInner':
        return '${p}R$row';
      case 'rightOuter':
        return '${p}R${row + 5}';
      default:
        return '${p}L$row';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondaryGreyBlue.withOpacity(0.02),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.secondaryGreyBlue.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Steering wheel indicator
          const Icon(
            Icons.tune,
            color: AppColors.secondaryGreyBlue,
            size: 22,
          ),
          const SizedBox(height: 16),

          if (layoutConfig != null) ...[
            Builder(
              builder: (context) {
                final bool useUpper = isUpperDeck && layoutConfig!.hasUpperDeck;
                final int gridCols = useUpper ? layoutConfig!.upperCols : layoutConfig!.cols;
                final List<SeatModel> gridSeats = useUpper ? layoutConfig!.upperSeats : layoutConfig!.seats;

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: gridCols,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 14,
                    childAspectRatio: (gridSeats.isNotEmpty && gridSeats.first.type == 'sleeper')
                        ? (0.45 * 5 / gridCols)
                        : (0.65 * 5 / gridCols),
                  ),
                  itemCount: gridSeats.length,
                  itemBuilder: (context, index) {
                    final seat = gridSeats[index];
                    if (seat.isSpace) return const SizedBox();

                    String finalSeatId = seat.id;
                    if (isUpperDeck && !finalSeatId.startsWith('U')) {
                      finalSeatId = 'U$finalSeatId';
                    }

                    bool isBooked = bookedSeats.contains(finalSeatId);
                    String seatGender = seatGenders[finalSeatId] ?? 'none';
                    String effectiveStatus = seat.bookingStatus;

                    if (isBooked) {
                      effectiveStatus = 'booked';
                    } else {
                      // Block-based logic for gender restriction
                      final rowSeats = gridSeats.where((s) => s.row == seat.row).toList();
                      rowSeats.sort((a, b) => a.col.compareTo(b.col));
                      
                      int myIdx = rowSeats.indexWhere((s) => s.col == seat.col);
                      if (myIdx != -1) {
                        // Find continuous block (no aisles)
                        int start = myIdx;
                        while (start > 0 && !rowSeats[start - 1].isSpace) start--;
                        int end = myIdx;
                        while (end < rowSeats.length - 1 && !rowSeats[end + 1].isSpace) end++;
                        
                        final block = rowSeats.sublist(start, end + 1);
                        
                        for (var s in block) {
                          String sId = s.id;
                          if (isUpperDeck && !sId.startsWith('U')) sId = 'U$sId';
                          
                          if (bookedSeats.contains(sId)) {
                            String? nGender = seatGenders[sId];
                            if (nGender == 'female') {
                              effectiveStatus = 'restricted_female';
                              break;
                            } else if (nGender == 'male') {
                              effectiveStatus = 'restricted_male';
                              break;
                            }
                          }
                        }
                      }
                    }
                    
                    return SeatTileWidget(
                      seatId: finalSeatId,
                      isBooked: isBooked,
                      isSelected: selectedSeats.contains(finalSeatId),
                      type: seat.type,
                      onTap: onSeatTap,
                      gender: seatGender,
                      bookingStatus: effectiveStatus,
                      price: seat.price,
                    );
                  },
                );
              }
            )
          ] else
            ...List.generate(5, (index) {
              final row = index + 1;
              final leftId = seatId(upper: isUpperDeck, side: 'left', row: row);
              final rightInnerId = seatId(upper: isUpperDeck, side: 'rightInner', row: row);
              final rightOuterId = seatId(upper: isUpperDeck, side: 'rightOuter', row: row);

              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SeatTileWidget(
                      seatId: leftId,
                      isBooked: bookedSeats.contains(leftId),
                      isSelected: selectedSeats.contains(leftId),
                      type: 'seater',
                      onTap: onSeatTap,
                      price: defaultPrice,
                    ),
                    const Spacer(), // aisle gap
                    SeatTileWidget(
                      seatId: rightInnerId,
                      isBooked: bookedSeats.contains(rightInnerId),
                      isSelected: selectedSeats.contains(rightInnerId),
                      type: 'seater',
                      onTap: onSeatTap,
                      price: defaultPrice,
                    ),
                    const SizedBox(width: 10),
                    SeatTileWidget(
                      seatId: rightOuterId,
                      isBooked: bookedSeats.contains(rightOuterId),
                      isSelected: selectedSeats.contains(rightOuterId),
                      type: 'seater',
                      onTap: onSeatTap,
                      price: defaultPrice,
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

class SeatTileWidget extends StatelessWidget {
  final String seatId;
  final bool isBooked;
  final bool isSelected;
  final String type;
  final void Function(String)? onTap;
  final String gender; // 'male', 'female', 'none'
  final String bookingStatus; // 'available', 'booked', 'selected', 'restricted_male', 'restricted_female'
  final double price;

  const SeatTileWidget({
    super.key,
    required this.seatId,
    required this.isBooked,
    required this.isSelected,
    this.type = 'seater',
    this.onTap,
    this.gender = 'none',
    this.bookingStatus = 'available',
    this.price = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor = AppColors.white;
    Color borderColor = AppColors.secondaryGreyBlue.withOpacity(0.4);
    Color textColor = AppColors.primaryDark;
    IconData? icon;
    Color iconColor = Colors.transparent;

    // Determine colors based on status and gender
    if (isBooked) {
      if (gender == 'female') {
        bgColor = const Color(0xFFFFE4E1).withOpacity(0.8); // Light pink
        borderColor = const Color(0xFFFFB6C1).withOpacity(0.5);
        textColor = const Color(0xFFC71585);
      } else if (gender == 'male') {
        bgColor = const Color(0xFFE0F7FA).withOpacity(0.8); // Light blue
        borderColor = const Color(0xFFB2EBF2).withOpacity(0.5);
        textColor = const Color(0xFF00838F);
      } else {
        bgColor = AppColors.secondaryGreyBlue.withOpacity(0.15);
        borderColor = Colors.transparent;
        textColor = AppColors.secondaryGreyBlue.withOpacity(0.5);
      }
    } else if (isSelected) {
      bgColor = AppColors.primaryAccent.withOpacity(0.07);
      borderColor = AppColors.primaryAccent;
      textColor = AppColors.primaryAccent;
    } else if (bookingStatus == 'restricted_female') {
      bgColor = AppColors.white;
      borderColor = const Color(0xFFFF69B4); // Pink
      textColor = const Color(0xFFFF69B4);
      icon = Icons.female;
      iconColor = const Color(0xFFFF69B4);
    } else if (bookingStatus == 'restricted_male') {
      bgColor = AppColors.white;
      borderColor = const Color(0xFF1E90FF); // Blue
      textColor = const Color(0xFF1E90FF);
      icon = Icons.male;
      iconColor = const Color(0xFF1E90FF);
    } else {
      // Default available
      borderColor = Colors.green.withOpacity(0.7);
      textColor = Colors.green;
    }

    Widget priceLabel = const SizedBox();
    if (!isBooked && price > 0) {
      Color pColor = Colors.green;
      if (bookingStatus == 'restricted_male') pColor = const Color(0xFF1E90FF);
      if (bookingStatus == 'restricted_female') pColor = const Color(0xFFFF69B4);
      
      priceLabel = Text(
        '₹${price.toInt()}',
        style: AppTextStyles.caption.copyWith(
          color: pColor,
          fontSize: 8,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    Widget content;

    if (type == 'sleeper') {
      content = SizedBox(
        width: 48,
        height: 90,
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: borderColor,
              width: (isSelected || bookingStatus.startsWith('restricted'))
                  ? 1.5
                  : 1,
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null)
                        Icon(icon, size: 16, color: iconColor)
                      else
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              seatId,
                              style: AppTextStyles.caption.copyWith(
                                color: textColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                      if (!isBooked && price > 0) ...[
                        const SizedBox(height: 2),
                        priceLabel,
                      ],
                    ],
                  ),
                ),
              ),
              Container(
                height: 12,
                margin: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
                decoration: BoxDecoration(
                  color: borderColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      content = SizedBox(
        width: 48,
        height: 54,
        child: Stack(
          children: [
            Positioned(
              left: 3,
              right: 3,
              top: 2,
              bottom: 8,
              child: Container(
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                    bottomLeft: Radius.circular(4),
                    bottomRight: Radius.circular(4),
                  ),
                  border: Border.all(
                    color: borderColor,
                    width: (isSelected || bookingStatus.startsWith('restricted'))
                        ? 1.5
                        : 1,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null)
                        Icon(icon, size: 14, color: iconColor)
                      else
                        Text(
                          seatId,
                          style: AppTextStyles.caption.copyWith(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      if (!isBooked && price > 0) ...[
                        const SizedBox(height: 1),
                        priceLabel,
                      ],
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 3,
              right: 3,
              bottom: 1,
              height: 6,
              child: Container(
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: borderColor,
                    width: (isSelected || bookingStatus.startsWith('restricted'))
                        ? 1.5
                        : 1,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              top: 8,
              bottom: 12,
              width: 3,
              child: Container(
                decoration: BoxDecoration(
                  color: borderColor.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Positioned(
              right: 0,
              top: 8,
              bottom: 12,
              width: 3,
              child: Container(
                decoration: BoxDecoration(
                  color: borderColor.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ],
        ),
    );
    }

    return GestureDetector(
      onTap: (isBooked || onTap == null) ? null : () => onTap!(seatId),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          content,
          if (isSelected)
            Positioned(
              right: -4,
              top: -4,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: AppColors.primaryAccent,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: AppColors.white, size: 10),
              ),
            ),
        ],
      ),
    );
  }
}
