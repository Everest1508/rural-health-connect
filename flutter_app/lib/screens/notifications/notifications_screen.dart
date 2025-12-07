import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import '../../core/theme/app_theme.dart';
import '../../core/api/notification_service.dart';
import '../../models/notification_model.dart' as models;

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _notificationService = NotificationService();
  List<models.AppNotification> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    try {
      final notifications = await _notificationService.getNotifications();
      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _markAsRead(models.AppNotification notification) async {
    if (!notification.isRead) {
      final success = await _notificationService.markAsRead(int.parse(notification.id));
      if (success) {
        _loadNotifications();
      }
    }
  }

  Future<void> _markAllAsRead() async {
    final success = await _notificationService.markAllAsRead();
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All notifications marked as read'),
          backgroundColor: AppTheme.successColor,
        ),
      );
      _loadNotifications();
    }
  }

  IconData _getIconForType(models.NotificationType type) {
    switch (type) {
      case models.NotificationType.appointment:
      case models.NotificationType.appointmentReminder:
      case models.NotificationType.appointmentConfirmed:
      case models.NotificationType.appointmentCancelled:
        return BoxIcons.bx_calendar;
      case models.NotificationType.prescription:
        return BoxIcons.bx_capsule;
      case models.NotificationType.labResult:
        return BoxIcons.bx_test_tube;
      case models.NotificationType.vaccination:
        return BoxIcons.bx_plus_medical;
      case models.NotificationType.system:
        return BoxIcons.bx_cog;
      default:
        return BoxIcons.bx_info_circle;
    }
  }

  Color _getColorForType(models.NotificationType type) {
    switch (type) {
      case models.NotificationType.appointment:
      case models.NotificationType.appointmentReminder:
      case models.NotificationType.appointmentConfirmed:
        return AppTheme.primaryColor;
      case models.NotificationType.appointmentCancelled:
        return AppTheme.destructiveColor;
      case models.NotificationType.prescription:
        return AppTheme.accentColor;
      case models.NotificationType.labResult:
        return AppTheme.infoColor;
      case models.NotificationType.vaccination:
        return AppTheme.successColor;
      default:
        return AppTheme.mutedForeground;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (_notifications.any((n) => !n.isRead))
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text('Mark all read'),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        BoxIcons.bx_bell_off,
                        size: 64,
                        color: theme.textTheme.bodySmall?.color,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No notifications',
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'You\'re all caught up!',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadNotifications,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      final notification = _notifications[index];
                      final type = notification.type;
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: notification.isRead
                              ? theme.cardColor
                              : theme.colorScheme.primary.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: notification.isRead
                                ? theme.dividerColor.withOpacity(0.1)
                                : theme.colorScheme.primary.withOpacity(0.2),
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: _getColorForType(type).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _getIconForType(type),
                              color: _getColorForType(type),
                              size: 24,
                            ),
                          ),
                          title: Text(
                            notification.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: notification.isRead
                                  ? FontWeight.w500
                                  : FontWeight.w700,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                notification.message,
                                style: theme.textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                notification.timeAgo,
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                          trailing: !notification.isRead
                              ? Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                )
                              : null,
                          onTap: () {
                            _markAsRead(notification);
                            // TODO: Navigate to related content if applicable
                            if (notification.relatedAppointmentId != null) {
                              // Navigate to appointment details
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
