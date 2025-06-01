import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Notifikasi',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all, color: Colors.white),
            tooltip: 'Tandai semua sudah dibaca',
            onPressed: _markAllAsRead,
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF05606B),
                  Color(0xFF88C1D0),
                  Color(0xFFB5D8E2),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                SizedBox(height: 12), // Extra space below status bar
                _buildAnimatedHeader(),
                Expanded(
                  child:
                      _notifications.isEmpty
                          ? _buildEmptyState()
                          : _buildNotificationsList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 8), // Reduced top padding
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_active,
              color: Colors.white,
              size: 32,
            ),
          ).animate().fadeIn(duration: 400.ms).scale(duration: 400.ms),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Semua Notifikasi',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white.withOpacity(0.95),
              ),
            ).animate(delay: 100.ms).fadeIn(duration: 400.ms),
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
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.notifications_off_outlined,
              size: 64,
              color: Colors.teal.shade700,
            ),
          ).animate().fadeIn(duration: 600.ms).scale(duration: 600.ms),
          const SizedBox(height: 24),
          const Text(
            'Tidak ada notifikasi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Anda akan melihat notifikasi di sini',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      itemCount: _notifications.length,
      itemBuilder: (context, index) {
        final notification = _notifications[index];
        return _buildNotificationCard(notification, index)
            .animate(delay: (80 * index).ms)
            .fadeIn(duration: 400.ms, curve: Curves.easeOut)
            .slideY(begin: 0.2, end: 0);
      },
    );
  }

  Widget _buildNotificationCard(NotificationItem notification, int index) {
    final Color accent =
        notification.isRead ? Colors.grey.shade200 : Colors.teal.shade100;
    final Color iconBg =
        notification.isRead ? Colors.grey.shade100 : Colors.teal.shade200;
    final Color iconColor =
        notification.isRead ? Colors.grey.shade600 : Colors.teal.shade700;
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: Colors.red.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(Icons.delete_outline, color: Colors.red.shade700, size: 32),
      ),
      onDismissed: (direction) => _deleteNotification(notification),
      child: GestureDetector(
        onTap: () => _handleNotificationTap(notification),
        child: Container(
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: accent,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color:
                  notification.isRead
                      ? Colors.grey.shade200
                      : Colors.teal.shade200,
              width: 1.5,
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(notification.icon, color: iconColor, size: 28),
            ),
            title: Text(
              notification.title,
              style: TextStyle(
                fontWeight:
                    notification.isRead ? FontWeight.normal : FontWeight.bold,
                color:
                    notification.isRead
                        ? Colors.grey.shade700
                        : Colors.teal.shade900,
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              notification.subtitle,
              style: TextStyle(
                color:
                    notification.isRead
                        ? Colors.grey.shade600
                        : Colors.teal.shade800,
                fontSize: 14,
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
                            : Colors.teal.shade700,
                  ),
                ),
                if (!notification.isRead)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade700,
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
          ),
        ),
      ),
    );
  }

  void _handleNotificationTap(NotificationItem notification) {
    HapticFeedback.lightImpact();
    setState(() {
      notification.isRead = true;
    });
    // TODO: Add navigation or action based on notification type
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
