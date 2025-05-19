import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  NotificationService._internal() {
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    var iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      notificationCategories: [
        DarwinNotificationCategory(
          'medication_reminder',
          actions: [
            DarwinNotificationAction.plain(
              'TAKE_MEDICATION',
              'Sudah Diminum',
              options: {
                DarwinNotificationActionOption.foreground,
              },
            ),
          ],
        ),
      ],
    );

    var initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
      onDidReceiveBackgroundNotificationResponse:
          _onBackgroundNotificationResponse,
    );
  }

  static void _onBackgroundNotificationResponse(NotificationResponse details) {
    if (details.actionId == 'TAKE_MEDICATION') {
      final medicationId = details.payload;
      if (medicationId != null) {
        NotificationService()._decrementMedicationStock(medicationId);
      }
    }
  }

  void _onNotificationResponse(NotificationResponse details) {
    if (details.actionId == 'TAKE_MEDICATION') {
      final medicationId = details.payload;
      if (medicationId != null) {
        _decrementMedicationStock(medicationId);
      }
    }
  }

  Future<void> _decrementMedicationStock(String medicationId) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;

      final docRef = _firestore
          .collection('users')
          .doc(uid)
          .collection('medications')
          .doc(medicationId);

      final doc = await docRef.get();
      if (!doc.exists) return;

      final data = doc.data()!;
      final currentStock = data['currentStock'] as int;
      final reminderThreshold = data['reminderThreshold'] as int;
      final stockReminderEnabled = data['stockReminderEnabled'] as bool;
      final medicationName = data['medicationName'] as String;
      final unitType = data['unitType'] as String;

      if (currentStock <= 1) {
        await docRef.delete();
        await cancelAllRemindersForMedication(medicationId);
        return;
      }

      final newStock = currentStock - 1;
      await docRef.update({'currentStock': newStock});

      if (stockReminderEnabled && newStock <= reminderThreshold) {
        await scheduleStockReminder(
          medicationId: medicationId,
          medicationName: medicationName,
          currentStock: newStock,
          reminderThreshold: reminderThreshold,
          unitType: unitType,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error decrementing stock: $e');
      }
    }
  }

  Future<void> scheduleMedicationReminder({
    required String medicationId,
    required String medicationName,
    required String time,
    required String dosage,
    required String unitType,
  }) async {
    final timeParts = time.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    final now = DateTime.now();
    final scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate.add(const Duration(days: 1));
    }

    final tzDateTime = tz.TZDateTime.from(scheduledDate, tz.local);

    const androidDetails = AndroidNotificationDetails(
      'medication_reminder',
      'Pengingat Obat',
      channelDescription: 'Notifikasi untuk mengingatkan waktu minum obat',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
      actions: [
        AndroidNotificationAction(
          'TAKE_MEDICATION',
          'Sudah Diminum',
          showsUserInterface: true,
        ),
      ],
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      categoryIdentifier: 'medication_reminder',
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      int.parse(medicationId.hashCode.toString().substring(0, 9)),
      'Waktunya Minum Obat',
      'Jangan lupa minum $medicationName $dosage $unitType',
      tzDateTime,
      details,
      payload: medicationId, 
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, 
    );
  }

  Future<void> scheduleStockReminder({
    required String medicationId,
    required String medicationName,
    required int currentStock,
    required int reminderThreshold,
    required String unitType,
  }) async {
    if (currentStock <= reminderThreshold) {
      const androidDetails = AndroidNotificationDetails(
        'stock_reminder',
        'Pengingat Stok',
        channelDescription:
            'Notifikasi untuk mengingatkan stok obat hampir habis',
        importance: Importance.high,
        priority: Priority.high,
        enableVibration: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        int.parse(medicationId.hashCode.toString().substring(0, 9)) + 1,
        'Stok Obat Hampir Habis',
        'Stok $medicationName tinggal $currentStock $unitType. Segera isi ulang persediaan obat Anda.',
        details,
      );
    }
  }

  Future<void> cancelMedicationReminder(String medicationId) async {
    await _notifications.cancel(
      int.parse(medicationId.hashCode.toString().substring(0, 9)),
    );
  }

  Future<void> cancelStockReminder(String medicationId) async {
    await _notifications.cancel(
      int.parse(medicationId.hashCode.toString().substring(0, 9)) + 1,
    );
  }

  Future<void> cancelAllRemindersForMedication(String medicationId) async {
    await cancelMedicationReminder(medicationId);
    await cancelStockReminder(medicationId);
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
}
