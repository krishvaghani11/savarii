import 'package:flutter/material.dart';
import 'package:savarii/core/theme/app_colors.dart';
import 'package:savarii/core/theme/app_text_styles.dart';

class SeatStatusLegend extends StatelessWidget {
  const SeatStatusLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secondaryGreyBlue.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryGreyBlue.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SEAT STATUS LEGEND',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.secondaryGreyBlue.withOpacity(0.8),
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: [
              _buildLegendItem(
                borderColor: Colors.green.withOpacity(0.7),
                label: 'Available',
              ),
              _buildLegendItem(
                bgColor: AppColors.secondaryGreyBlue.withOpacity(0.15),
                label: 'Already booked',
              ),
              _buildLegendItem(
                borderColor: const Color(0xFFFF69B4),
                icon: Icons.female,
                iconColor: const Color(0xFFFF69B4),
                label: 'Available only for female',
              ),
              _buildLegendItem(
                bgColor: const Color(0xFFFFE4E1).withOpacity(0.8),
                label: 'Booked by female passenger',
              ),
              _buildLegendItem(
                borderColor: const Color(0xFF1E90FF),
                icon: Icons.male,
                iconColor: const Color(0xFF1E90FF),
                label: 'Available only for male',
              ),
              _buildLegendItem(
                bgColor: const Color(0xFFE0F7FA).withOpacity(0.8),
                label: 'Booked by male passenger',
              ),
              _buildLegendItem(
                bgColor: AppColors.primaryAccent,
                label: 'Selected',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({
    Color? bgColor,
    Color? borderColor,
    IconData? icon,
    Color? iconColor,
    required String label,
  }) {
    return SizedBox(
      width: 140, // Fixed width for better grid alignment in Wrap
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: bgColor ?? Colors.transparent,
              borderRadius: BorderRadius.circular(4),
              border: borderColor != null ? Border.all(color: borderColor, width: 1.5) : null,
            ),
            child: icon != null
                ? Icon(icon, size: 12, color: iconColor)
                : null,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.secondaryGreyBlue,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
