import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones();
    final dynamic tzInfo = await FlutterTimezone.getLocalTimezone();
    String timeZoneName;
    if (tzInfo is String) {
      timeZoneName = tzInfo;
    } else {
      // Handle TimezoneInfo object if returned by some versions
      timeZoneName = (tzInfo as dynamic).name?.toString() ?? 
                     (tzInfo as dynamic).zone?.toString() ?? 
                     tzInfo.toString();
    }
    tz.setLocalLocation(tz.getLocation(timeZoneName));

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

    await _notifications.zonedSchedule(
      id,
      'Task Reminder',
      'Your task "$title" is due soon!',
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidDetails(
          'task_reminders',
          'Task Reminders',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
        // Windows/Desktop support is often through the basic notification details
        // but we can add more if needed using platform-specific packages.
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
    return true;
  }

  Future<void> cancelReminder(int id) async {
    await _notifications.cancel(id);
  }
}

class AndroidDetails extends AndroidNotificationDetails {
  const AndroidDetails(
    super.channelId,
    super.channelName, {
    super.importance,
    super.priority,
  });
}
