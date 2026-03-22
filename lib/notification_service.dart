import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();

    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initializationSettings);
  }

  Future<void> scheduleTaskReminder({
    required int id,
    required String title,
    required DateTime dueDate,
    required int reminderMinutes,
  }) async {
    final scheduledDate = dueDate.subtract(Duration(minutes: reminderMinutes));
    
    if (scheduledDate.isBefore(DateTime.now())) {
      return; // Cannot schedule in the past
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
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
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
