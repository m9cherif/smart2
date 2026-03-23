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
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      tz.initializeTimeZones();

      String timeZoneName = 'UTC';
      try {
        final result = await FlutterTimezone.getLocalTimezone();
        final raw = result.toString();
        debugPrint('NotificationService: raw timezone result = "$raw"');

        // If it's a plain IANA string like "Europe/Paris", use it directly
        if (raw.contains('/') && !raw.contains('(')) {
          timeZoneName = raw.trim();
        } else {
          // Parse from "TimezoneInfo(Europe/Paris, ...)" or similar
          final match = RegExp(r'([A-Za-z]+/[A-Za-z_]+)').firstMatch(raw);
          if (match != null) {
            timeZoneName = match.group(1)!;
          }
        }
      } catch (e) {
        debugPrint('NotificationService: Failed to get timezone: $e');
      }

      try {
        tz.setLocalLocation(tz.getLocation(timeZoneName));
        debugPrint('NotificationService: Timezone set to $timeZoneName');
      } catch (e) {
        debugPrint('NotificationService: Could not set "$timeZoneName", falling back to UTC: $e');
        tz.setLocalLocation(tz.UTC);
      }

      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        await localNotifier.setup(
          appName: 'Smart Student AI',
        );
      }

      const androidSettings = AndroidInitializationSettings('@mipmap/launcher_icon');
      const iosSettings = DarwinInitializationSettings();

      const initializationSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notifications.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (details) {
          debugPrint('Notification tapped: ${details.payload}');
        },
      );

      // Handle Android 13+ permissions
      if (Platform.isAndroid) {
        final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
        if (androidPlugin != null) {
          await androidPlugin.requestNotificationsPermission();
          await androidPlugin.requestExactAlarmsPermission();
        }
      }

      _isInitialized = true;
    } catch (e) {
      debugPrint('NotificationService: Initialization failed: $e');
    }
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

    if (!_isInitialized) {
      await initialize();
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
    if (_isInitialized) {
      try {
        await _notifications.cancel(id);
      } catch (e) {
        debugPrint('NotificationService: Failed to cancel reminder $id: $e');
      }
    }
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
