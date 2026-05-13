import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_export.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  final List<Map<String, dynamic>> _notifications = const [
    {
      'title': 'Booking Confirmed',
      'message': 'Your booking with Elena Petrova has been confirmed for tomorrow at 10:00 AM.',
      'time': '2 mins ago',
      'type': 'booking',
      'isUnread': true,
    },
    {
      'title': 'New Message',
      'message': 'Priya Nair sent you a message regarding your electrical repair request.',
      'time': '1 hour ago',
      'type': 'message',
      'isUnread': true,
    },
    {
      'title': 'Payment Successful',
      'message': 'Your payment of \$45.00 for House Cleaning has been processed successfully.',
      'time': 'Yesterday',
      'type': 'payment',
      'isUnread': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: theme.colorScheme.onSurface,
          ),
        ),
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _notifications.isEmpty
          ? const Center(
              child: EmptyStateWidget(
                icon: Icons.notifications_off_outlined,
                title: 'No notifications yet',
                description: 'We will notify you when something important happens.',
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _notifications.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final notification = _notifications[index];
                return _NotificationItem(notification: notification);
              },
            ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final Map<String, dynamic> notification;

  const _NotificationItem({required this.notification});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUnread = notification['isUnread'] as bool;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUnread ? AppTheme.primary.withAlpha(10) : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnread ? AppTheme.primary.withAlpha(50) : theme.colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _getIconBgColor(notification['type']),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getIcon(notification['type']),
              color: _getIconColor(notification['type']),
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      notification['title'],
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      notification['time'],
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  notification['message'],
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'booking': return Icons.calendar_today_rounded;
      case 'message': return Icons.chat_bubble_outline_rounded;
      case 'payment': return Icons.account_balance_wallet_outlined;
      default: return Icons.notifications_none_rounded;
    }
  }

  Color _getIconBgColor(String type) {
    switch (type) {
      case 'booking': return Colors.blue.withAlpha(20);
      case 'message': return Colors.purple.withAlpha(20);
      case 'payment': return Colors.green.withAlpha(20);
      default: return Colors.grey.withAlpha(20);
    }
  }

  Color _getIconColor(String type) {
    switch (type) {
      case 'booking': return Colors.blue;
      case 'message': return Colors.purple;
      case 'payment': return Colors.green;
      default: return Colors.grey;
    }
  }
}
