import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'dart:io';
import 'package:local_notifier/local_notifier.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  final List<_DesktopReminder> _desktopReminders = [];
  Timer? _desktopTimer;

  Future<void> initialize() async {
    tz.initializeTimeZones();
    final dynamic tzInfo = await FlutterTimezone.getLocalTimezone();
    String? timeZoneName;
    
    if (tzInfo is String) {
      timeZoneName = tzInfo;
    } else {
      try {
        // Try getting it from the 'timezone' property (List<String>)
        final List<dynamic>? list = (tzInfo as dynamic).timezone;
        if (list != null && list.isNotEmpty) {
          timeZoneName = list.first.toString();
        }
      } catch (_) {}
      
      // If that failed, parse the toString() which looks like "TimezoneInfo(Europe/Paris, ...)"
      if (timeZoneName == null) {
        final String raw = tzInfo.toString();
        final match = RegExp(r'\(([^,\)]+)').firstMatch(raw);
        if (match != null) {
          timeZoneName = match.group(1);
        }
      }
    }

    try {
      tz.setLocalLocation(tz.getLocation(timeZoneName ?? 'UTC'));
    } catch (e) {
      debugPrint('Could not set local timezone "$timeZoneName", falling back to UTC: $e');
      tz.setLocalLocation(tz.UTC);
    }

    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      await localNotifier.setup(
        appName: 'Smart Student AI',
      );
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();

    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initializationSettings);
  }

  Future<bool> scheduleTaskReminder({
    required int id,
    required String title,
    required DateTime dueDate,
    required int reminderMinutes,
  }) async {
    final scheduledDate = dueDate.subtract(Duration(minutes: reminderMinutes));
    
    if (scheduledDate.isBefore(DateTime.now())) {
      return false; // Cannot schedule in the past
    }

    if (Platform.isWindows || Platform.isLinux) {
      // Manual scheduling for Desktop since zonedSchedule is not implemented
      _desktopReminders.removeWhere((r) => r.id == id);
      _desktopReminders.add(_DesktopReminder(
        id: id,
        title: title,
        description: 'Your task "$title" is due soon!',
        time: scheduledDate,
      ));
      debugPrint('NotificationService: Scheduled for Windows/Desktop at $scheduledDate (ID: $id)');
      _startDesktopTimer();
      return true;
    }

    await _notifications.zonedSchedule(
      id,
      'Task Reminder',
      'Your task "$title" is due soon!',
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'task_reminders',
          'Task Reminders',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
    return true;
  }

  void _startDesktopTimer() {
    _desktopTimer?.cancel();
    _desktopTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      final now = DateTime.now();
      debugPrint('NotificationService: Checking ${_desktopReminders.length} reminders at $now');
      final toRemove = <int>[];

      for (final reminder in _desktopReminders) {
        if (reminder.time.isBefore(now)) {
          debugPrint('NotificationService: Triggering reminder "${reminder.title}"');
          _showImmediateNotification(
            id: reminder.id,
            title: 'Task Reminder',
            body: reminder.description,
          );
          toRemove.add(reminder.id);
        }
      }

      for (final id in toRemove) {
        _desktopReminders.removeWhere((r) => r.id == id);
      }

      if (_desktopReminders.isEmpty) {
        debugPrint('NotificationService: No more reminders, stopping timer.');
        _desktopTimer?.cancel();
        _desktopTimer = null;
      }
    });
  }

  Future<void> _showImmediateNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      LocalNotification notification = LocalNotification(
        identifier: id.toString(),
        title: title,
        body: body,
      );
      notification.show();
      return;
    }

    await _notifications.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'task_reminders',
          'Task Reminders',
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  Future<void> cancelReminder(int id) async {
    _desktopReminders.removeWhere((r) => r.id == id);
    await _notifications.cancel(id);
  }
}

class _DesktopReminder {
  _DesktopReminder({
    required this.id,
    required this.title,
    required this.description,
    required this.time,
  });

  final int id;
  final String title;
  final String description;
  final DateTime time;
}
