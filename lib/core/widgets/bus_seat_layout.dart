import 'package:flutter/material.dart';
import 'package:savarii/core/theme/app_colors.dart';
import 'package:savarii/core/theme/app_text_styles.dart';

/// A shared bus seat layout widget used by both vendor and customer screens.
///
/// Seat ID standard (5-row × 3-seat bus: 1 left + 2 right):
///   Lower deck:  L1–L5 (left), R1–R5 (right-inner), R6–R10 (right-outer)
///   Upper deck: UL1–UL5,       UR1–UR5,              UR6–UR10
///
/// This ensures vendor and customer always see the same seat at the same position.
class BusSeatLayout extends StatelessWidget {
  final List<String> bookedSeats;
  final List<String> selectedSeats;
  final bool isUpperDeck;
  final void Function(String seatId) onSeatTap;

  const BusSeatLayout({
    super.key,
    required this.bookedSeats,
    required this.selectedSeats,
    required this.isUpperDeck,
    required this.onSeatTap,
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

          // 5 rows of seats
          ...List.generate(5, (index) {
            final row = index + 1;
            final leftId      = seatId(upper: isUpperDeck, side: 'left',       row: row);
            final rightInnerId = seatId(upper: isUpperDeck, side: 'rightInner', row: row);
            final rightOuterId = seatId(upper: isUpperDeck, side: 'rightOuter', row: row);

            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _SeatTile(
                    seatId: leftId,
                    isBooked: bookedSeats.contains(leftId),
                    isSelected: selectedSeats.contains(leftId),
                    onTap: onSeatTap,
                  ),
                  const Spacer(), // aisle gap
                  _SeatTile(
                    seatId: rightInnerId,
                    isBooked: bookedSeats.contains(rightInnerId),
                    isSelected: selectedSeats.contains(rightInnerId),
                    onTap: onSeatTap,
                  ),
                  const SizedBox(width: 10),
                  _SeatTile(
                    seatId: rightOuterId,
                    isBooked: bookedSeats.contains(rightOuterId),
                    isSelected: selectedSeats.contains(rightOuterId),
                    onTap: onSeatTap,
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

/// Individual seat tile — purely presentational.
class _SeatTile extends StatelessWidget {
  final String seatId;
  final bool isBooked;
  final bool isSelected;
  final void Function(String) onTap;

  const _SeatTile({
    required this.seatId,
    required this.isBooked,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor = AppColors.white;
    Color borderColor = AppColors.secondaryGreyBlue.withOpacity(0.25);
    Color textColor = AppColors.primaryDark;

    if (isBooked) {
      bgColor = AppColors.secondaryGreyBlue.withOpacity(0.15);
      borderColor = Colors.transparent;
      textColor = AppColors.secondaryGreyBlue.withOpacity(0.5);
    } else if (isSelected) {
      bgColor = AppColors.primaryAccent.withOpacity(0.07);
      borderColor = AppColors.primaryAccent;
      textColor = AppColors.primaryAccent;
    }

    return GestureDetector(
      onTap: isBooked ? null : () => onTap(seatId),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 54,
            height: 70,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: borderColor,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Center(
              child: Text(
                seatId,
                style: AppTextStyles.caption.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
          ),
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
