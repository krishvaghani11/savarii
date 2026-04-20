import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:savarii/core/theme/app_colors.dart';
import 'package:savarii/core/theme/app_text_styles.dart';

class DriverBusDetailsView extends StatelessWidget {
  const DriverBusDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> bus = Get.arguments as Map<String, dynamic>? ?? {};
    final route = bus['route'] as Map<String, dynamic>? ?? {};
    
    final bps = (route['boardingPoints'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
    final dps = (route['droppingPoints'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
    final rss = (route['restStops'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        title: Text('Bus Information', style: AppTextStyles.h3.copyWith(color: AppColors.primaryDark)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.primaryDark),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeaderCard(bus, route),
              const SizedBox(height: 24),
              _buildPointsSection('Boarding Points', bps, true),
              const SizedBox(height: 24),
              _buildPointsSection('Dropping Points', dps, false),
              const SizedBox(height: 24),
              _buildRestStops(rss),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(Map<String, dynamic> bus, Map<String, dynamic> route) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
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
          Row(
            children: [
              const Icon(Icons.directions_bus, color: AppColors.primaryAccent),
              const SizedBox(width: 8),
              Text(bus['busName'] ?? 'Unknown Bus', style: AppTextStyles.h2),
            ],
          ),
          const SizedBox(height: 8),
          Text(bus['busType'] ?? 'Type N/A', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.secondaryGreyBlue)),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          _buildRow('Bus Number', bus['busNumber'] ?? 'N/A'),
          const SizedBox(height: 8),
          _buildRow('Total Seats', (bus['totalSeats'] ?? 'N/A').toString()),
          const SizedBox(height: 8),
          _buildRow('Ticket Price', '₹${route['ticketPrice'] ?? 'N/A'}'),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.secondaryGreyBlue)),
        Text(value, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
      ],
    );
  }

  Widget _buildPointsSection(String title, List<Map<String, dynamic>> points, bool isBoarding) {
    if (points.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.h3.copyWith(fontSize: 18, color: AppColors.primaryDark)),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.secondaryGreyBlue.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: points.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final point = points[index];
              return ListTile(
                leading: Icon(
                  isBoarding ? Icons.my_location : Icons.location_on, 
                  color: isBoarding ? Colors.green : AppColors.primaryAccent,
                  size: 20,
                ),
                title: Text(point['pointName'] ?? '', style: AppTextStyles.bodyLarge),
                trailing: Text(point['time'] ?? '', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primaryDark, fontWeight: FontWeight.bold)),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRestStops(List<Map<String, dynamic>> stops) {
    if (stops.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Rest Stops', style: AppTextStyles.h3.copyWith(fontSize: 18, color: AppColors.primaryDark)),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.secondaryGreyBlue.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: stops.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final stop = stops[index];
              return ListTile(
                leading: const Icon(Icons.coffee, color: Colors.orange, size: 20),
                title: Text(stop['stopName'] ?? '', style: AppTextStyles.bodyLarge),
                trailing: Text('${stop['duration'] ?? 'N/A'} mins', style: AppTextStyles.caption.copyWith(color: AppColors.secondaryGreyBlue)),
              );
            },
          ),
        ),
      ],
    );
  }
}
