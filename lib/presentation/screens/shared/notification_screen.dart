import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/service_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/notification_model.dart';
import '../../../data/models/user_model.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserDataProvider).value;
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Please login to see notifications')));
    }

    final firestore = ref.watch(firestoreServiceProvider);
    final stream = user.role == UserRole.admin 
        ? firestore.streamAdminNotifications() 
        : firestore.streamUserNotifications(user.id);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
      ),
      body: StreamBuilder<List<NotificationModel>>(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final notifications = snapshot.data ?? [];
          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none_rounded, size: 80, color: Colors.grey.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  Text('No notifications yet', style: TextStyle(color: Colors.grey.withOpacity(0.7), fontSize: 16)),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: notifications.length,
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return _NotificationTile(notification: notification);
            },
          );
        },
      ),
    );
  }
}

class _NotificationTile extends ConsumerWidget {
  final NotificationModel notification;
  const _NotificationTile({required this.notification});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isRead = notification.isRead;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isRead ? Colors.white : AppColors.lightPink.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isRead ? Colors.grey.withOpacity(0.1) : AppColors.vibrantPink.withOpacity(0.2)),
        boxShadow: isRead ? null : [
          BoxShadow(
            color: AppColors.vibrantPink.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: _getBgColor(notification.type).withOpacity(0.1),
          child: Icon(_getIcon(notification.type), color: _getBgColor(notification.type), size: 20),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: isRead ? FontWeight.w600 : FontWeight.bold,
            color: AppColors.deepMagenta,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(notification.message, style: TextStyle(color: Colors.grey.shade700, height: 1.3)),
            const SizedBox(height: 6),
            Text(
              DateFormat('MMM d, h:mm a').format(notification.createdAt),
              style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
            ),
          ],
        ),
        onTap: () {
          if (!isRead) {
            ref.read(firestoreServiceProvider).markNotificationAsRead(notification.id);
          }
          // Optional: Navigate to detail based on type
        },
      ),
    );
  }

  IconData _getIcon(NotificationType type) {
    switch (type) {
      case NotificationType.bookingApproved: return Icons.check_circle_rounded;
      case NotificationType.bookingRejected: return Icons.cancel_rounded;
      case NotificationType.newBooking: return Icons.calendar_today_rounded;
      default: return Icons.notifications_rounded;
    }
  }

  Color _getBgColor(NotificationType type) {
    switch (type) {
      case NotificationType.bookingApproved: return Colors.teal;
      case NotificationType.bookingRejected: return Colors.red;
      case NotificationType.newBooking: return AppColors.vibrantPink;
      default: return AppColors.roseGold;
    }
  }
}
