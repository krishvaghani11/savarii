import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:savarii/core/theme/app_colors.dart';
import 'package:savarii/core/theme/app_text_styles.dart';
import 'package:savarii/features/customer/home/controller/customer_notifications_controller.dart';

class CustomerNotificationsView extends GetView<CustomerNotificationsController> {
  const CustomerNotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.lightBackground,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primaryDark),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Notifications',
          style: AppTextStyles.h2.copyWith(color: AppColors.primaryDark),
        ),
        actions: [
          Obx(() {
            if (controller.unreadNotificationsCount > 0) {
              return TextButton(
                onPressed: controller.markAllNotificationsAsRead,
                child: Text(
                  'Mark all read',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primaryAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.notifications.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: controller.notifications.length,
            itemBuilder: (context, index) {
              final notification = controller.notifications[index];
              final isRead = notification['readStatus'] as bool? ?? false;
              final title = notification['title'] ?? 'Notification';
              final body = notification['body'] ?? '';
              final type = notification['type'] ?? 'unknown';

              // Format time
              String timeAgo = _formatTimeAgo(notification['createdAt']);

              IconData iconData = Icons.notifications;
              Color iconColor = AppColors.primaryAccent;

              if (type == 'booking_confirmed') {
                iconData = Icons.check_circle;
                iconColor = Colors.green;
              } else if (type == 'ticket_cancelled' || type.contains('fail')) {
                iconData = Icons.cancel;
                iconColor = Colors.red;
              } else if (type == 'driver_assigned' || type.contains('bus')) {
                iconData = Icons.directions_bus;
                iconColor = Colors.blue;
              }

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondaryGreyBlue.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: isRead ? Colors.transparent : AppColors.primaryAccent.withOpacity(0.3),
                    width: isRead ? 0 : 1,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      if (!isRead) {
                        controller.markNotificationAsRead(notification['id']);
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: iconColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(iconData, color: iconColor, size: 24),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        title,
                                        style: AppTextStyles.h3.copyWith(
                                          fontSize: 16,
                                          fontWeight: isRead ? FontWeight.w500 : FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    if (timeAgo.isNotEmpty) ...[
                                      const SizedBox(width: 8),
                                      Text(
                                        timeAgo,
                                        style: AppTextStyles.caption.copyWith(
                                          color: AppColors.secondaryGreyBlue,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  body,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: isRead ? AppColors.secondaryGreyBlue : AppColors.primaryDark,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!isRead) ...[
                            const SizedBox(width: 12),
                            Container(
                              width: 10,
                              height: 10,
                              margin: const EdgeInsets.only(top: 6),
                              decoration: const BoxDecoration(
                                color: AppColors.primaryAccent,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primaryAccent.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_off_outlined,
              size: 64,
              color: AppColors.primaryAccent.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No notifications yet',
            style: AppTextStyles.h2.copyWith(color: AppColors.primaryDark),
          ),
          const SizedBox(height: 8),
          Text(
            'We will let you know when there is an update.',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.secondaryGreyBlue),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(dynamic createdAt) {
    if (createdAt == null) return '';
    try {
      final date = createdAt.toDate();
      final difference = DateTime.now().difference(date);
      if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (_) {
      return '';
    }
  }
}
