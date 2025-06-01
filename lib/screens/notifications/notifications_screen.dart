import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '/utils/colors.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<NotificationItem> _notifications = [
    NotificationItem(
      id: '1',
      icon: Icons.medication,
      title: 'Pengingat Obat',
      subtitle: 'Waktunya minum obat',
      time: '10:00',
      isRead: false,
      type: NotificationType.medication,
    ),
    NotificationItem(
      id: '2',
      icon: Icons.calendar_today,
      title: 'Jadwal Konsultasi',
      subtitle: 'Konsultasi dengan Dr. Budi',
      time: '14:30',
      isRead: true,
      type: NotificationType.appointment,
    ),
    NotificationItem(
      id: '3',
      icon: Icons.health_and_safety,
      title: 'Pemeriksaan Rutin',
      subtitle: 'Jadwal pemeriksaan bulanan',
      time: 'Kemarin',
      isRead: true,
      type: NotificationType.checkup,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child:
                _notifications.isEmpty
                    ? _buildEmptyState()
                    : _buildNotificationsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF05606B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Notifikasi',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.done_all, color: Colors.white),
                onPressed: _markAllAsRead,
                tooltip: 'Tandai semua sudah dibaca',
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak ada notifikasi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Anda akan melihat notifikasi di sini',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _notifications.length,
      itemBuilder: (context, index) {
        final notification = _notifications[index];
        return _buildNotificationItem(notification)
            .animate(delay: (50 * index).ms)
            .fadeIn(duration: 400.ms, curve: Curves.easeOut)
            .slideX(begin: 0.2, end: 0);
      },
    );
  }

  Widget _buildNotificationItem(NotificationItem notification) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.red.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.delete_outline, color: Colors.red.shade700),
      ),
      onDismissed: (direction) => _deleteNotification(notification),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color:
              notification.isRead ? Colors.grey.shade50 : Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                notification.isRead
                    ? Colors.grey.shade200
                    : Colors.blue.shade100,
          ),
        ),
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color:
                  notification.isRead
                      ? Colors.grey.shade200
                      : Colors.blue.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              notification.icon,
              color:
                  notification.isRead
                      ? Colors.grey.shade600
                      : Colors.blue.shade700,
            ),
          ),
          title: Text(
            notification.title,
            style: TextStyle(
              fontWeight:
                  notification.isRead ? FontWeight.normal : FontWeight.bold,
              color: notification.isRead ? Colors.grey.shade700 : Colors.black,
            ),
          ),
          subtitle: Text(
            notification.subtitle,
            style: TextStyle(
              color:
                  notification.isRead ? Colors.grey.shade600 : Colors.black87,
            ),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                notification.time,
                style: TextStyle(
                  fontSize: 12,
                  color:
                      notification.isRead
                          ? Colors.grey.shade600
                          : Colors.blue.shade700,
                ),
              ),
              if (!notification.isRead)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade700,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Baru',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          onTap: () => _handleNotificationTap(notification),
        ),
      ),
    );
  }

  void _handleNotificationTap(NotificationItem notification) {
    HapticFeedback.lightImpact();

    // Mark as read
    setState(() {
      notification.isRead = true;
    });

    // Handle different notification types
    switch (notification.type) {
      case NotificationType.medication:
        // Navigate to medication reminder
        Navigator.pop(context);
        // Add navigation to medication screen
        break;
      case NotificationType.appointment:
        // Navigate to appointment details
        Navigator.pop(context);
        // Add navigation to appointment screen
        break;
      case NotificationType.checkup:
        // Navigate to checkup details
        Navigator.pop(context);
        // Add navigation to checkup screen
        break;
    }
  }

  void _markAllAsRead() {
    HapticFeedback.mediumImpact();
    setState(() {
      for (var notification in _notifications) {
        notification.isRead = true;
      }
    });
  }

  void _deleteNotification(NotificationItem notification) {
    HapticFeedback.mediumImpact();
    setState(() {
      _notifications.remove(notification);
    });
  }
}

enum NotificationType { medication, appointment, checkup }

class NotificationItem {
  final String id;
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;
  bool isRead;
  final NotificationType type;

  NotificationItem({
    required this.id,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.isRead,
    required this.type,
  });
}
