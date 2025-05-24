import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'confirmation_reservation_controller.dart';

class NotificationsController extends GetxController {
  final RxList<Map<String, dynamic>> notifications = <Map<String, dynamic>>[].obs;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final notificationsEnabled = true.obs;

  Timer? _reminderTimer;

  @override
  void onInit() {
    super.onInit();
    _initNotifications();
    loadNotificationsFromStorage();
    final box = GetStorage();
    notificationsEnabled.value = box.read('notifications') ?? true;
    _startReminderCheck();
  }

  @override
  void onClose() {
    _reminderTimer?.cancel();
    super.onClose();
  }

  Future<void> _initNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);
    await flutterLocalNotificationsPlugin.initialize(initSettings);
  }

  void sendSuccessNotification(String tableName, String time, String mealType) {
    if (!notificationsEnabled.value) return;

    final message = 'Réservation confirmée à $mealType pour la table "$tableName" à $time.';
    _addToListUI("✅ Réservation confirmée", message, Icons.check_circle, Colors.green);

    _scheduleSafeSystemNotification(
      id: 2,
      title: '✅ Réservation confirmée',
      body: message,
      channelId: 'reservation_success',
      channelName: 'Confirmation',
      color: Colors.green,
    );
  }

  void sendCancelNotification(String reservationName) {
    if (!notificationsEnabled.value) return;

    final message = 'Votre réservation "$reservationName" a été annulée.';
    _addToListUI("❌ Réservation annulée", message, Icons.cancel, Colors.red);

    _scheduleSafeSystemNotification(
      id: 1,
      title: '❌ Réservation annulée',
      body: message,
      channelId: 'reservation_cancel',
      channelName: 'Annulation',
      color: Colors.red,
    );
  }

  void _sendReminderNotification(String name, String date, String time) {
    if (!notificationsEnabled.value) return;

    final message = 'Vous avez "$name" prévu le $date à $time. N’oubliez pas !';
    _addToListUI("⏰ Rappel de réservation", message, Icons.notifications_active, Colors.indigo);

    _scheduleSafeSystemNotification(
      id: 0,
      title: '⏰ Rappel de réservation',
      body: message,
      channelId: 'reservation_reminder',
      channelName: 'Rappel',
      color: Colors.indigo,
    );
  }

  void _addToListUI(String title, String description, IconData icon, Color color) {
    notifications.insert(0, {
      "title": title,
      "description": description,
      "time": "Maintenant",
      "icon": icon,
      "color": color,
    });
    saveNotificationsToStorage();
  }

  void _scheduleSafeSystemNotification({
    required int id,
    required String title,
    required String body,
    required String channelId,
    required String channelName,
    required Color color,
  }) {
    Future.delayed(Duration(milliseconds: 300), () async {
      final androidDetails = AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: 'Notification $channelName',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        color: color,
        ticker: 'Notification',
      );

      final details = NotificationDetails(android: androidDetails);
      await flutterLocalNotificationsPlugin.show(id, title, body, details);
    });
  }

  Future<void> saveNotificationsToStorage() async {
    final box = GetStorage();
    final data = notifications.map((n) => {
      'title': n['title'],
      'description': n['description'],
      'time': n['time'],
      'iconCode': (n['icon'] as IconData).codePoint,
      'iconFontFamily': (n['icon'] as IconData).fontFamily,
      'colorValue': (n['color'] as Color).value,
    }).toList();
    box.write('user_notifications', data);
  }

  Future<void> loadNotificationsFromStorage() async {
    final box = GetStorage();
    final data = box.read<List>('user_notifications');

    if (data != null) {
      notifications.value = data.map<Map<String, dynamic>>((item) {
        return {
          'title': item['title'],
          'description': item['description'],
          'time': item['time'],
          'icon': IconData(item['iconCode'], fontFamily: item['iconFontFamily']),
          'color': Color(item['colorValue']),
        };
      }).toList();
    }
  }

  void _startReminderCheck() {
    _reminderTimer = Timer.periodic(Duration(minutes: 1), (_) {
      final reservations = Get.find<ConfirmationReservationController>().reservations;

      for (final reservation in reservations) {
        final details = reservation['details'];
        final dateStr = details['date'];
        final timeStr = details['selectedExactTime'];

        if (dateStr == null || timeStr == null) continue;

        final isoDate = convertFrenchDateToIso(dateStr);
        if (isoDate == null) continue;

        final reservationDateTime = DateTime.parse("$isoDate $timeStr:00");
        final now = DateTime.now();
        final diff = reservationDateTime.difference(now);

        if (diff.inMinutes >= 59 && diff.inMinutes <= 61) {
          _sendReminderNotification(reservation['name'], dateStr, timeStr);
        }
      }
    });
  }

  String? convertFrenchDateToIso(String frenchDate) {
    final mois = {
      'janvier': '01', 'février': '02', 'mars': '03', 'avril': '04',
      'mai': '05', 'juin': '06', 'juillet': '07', 'août': '08',
      'septembre': '09', 'octobre': '10', 'novembre': '11', 'décembre': '12'
    };
    try {
      final parts = frenchDate.toLowerCase().split(' ');
      final day = parts[0].padLeft(2, '0');
      final month = mois[parts[1]];
      final year = parts[2];
      if (month == null) return null;
      return "$year-$month-$day";
    } catch (_) {
      return null;
    }
  }
}
