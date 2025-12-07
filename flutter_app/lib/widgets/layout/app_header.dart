import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../core/api/notification_service.dart';
import '../../core/theme/app_theme.dart';
import '../../screens/notifications/notifications_screen.dart';

class AppHeader extends StatefulWidget {
  const AppHeader({super.key});

  @override
  State<AppHeader> createState() => _AppHeaderState();
}

class _AppHeaderState extends State<AppHeader> {
  final NotificationService _notificationService = NotificationService();
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUnreadCount();
  }

  Future<void> _loadUnreadCount() async {
    final count = await _notificationService.getUnreadCount();
    if (mounted) {
      setState(() => _unreadCount = count);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = context.watch<AppState>();
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // User Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1FA89E), Color(0xFF2BB8AD)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                appState.userName.split(' ').where((n) => n.isNotEmpty).map((n) => n[0]).join('').toUpperCase(),
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getGreeting(),
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 2),
                Text(
                  appState.userName,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 14,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      appState.userLocation,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Notification Icon with Badge
          Stack(
            children: [
              IconButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationsScreen(),
                    ),
                  );
                  // Reload unread count when returning
                  _loadUnreadCount();
                },
                icon: const Icon(Icons.notifications_outlined),
                style: IconButton.styleFrom(
                  backgroundColor: theme.cardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              if (_unreadCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppTheme.destructiveColor,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      _unreadCount > 99 ? '99+' : _unreadCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }
}
