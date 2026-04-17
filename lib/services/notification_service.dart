import '../database/db_helper.dart';
import '../models/notification_model.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();

  /// ================= INIT =================
  static Future init() async {
    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);

    await _plugin.initialize(settings);
  }

  /// ================= DB =================
  static Future<int> insert(AppNotification n) async {
    final db = await DBHelper.db;
    return await db.insert('notifications', n.toMap());
  }

  static Future<List<AppNotification>> getAll() async {
    final db = await DBHelper.db;
    final res = await db.query('notifications', orderBy: 'notify_time ASC');

    return res.map((e) => AppNotification.fromMap(e)).toList();
  }

  /// ================= SHOW NOW =================
  static Future showNow(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'task_channel',
      'Task Notification',
      importance: Importance.max,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    await _plugin.show(0, title, body, details);
  }

  /// ================= SCHEDULE =================
  static Future schedule(
      int id,
      String title,
      String body,
      DateTime date, {
        int? taskId,
        int? subtaskId,
        required int type, // 1 = task, 2 = subtask
      }) async {
    /// 🔔 ĐẶT LỊCH NOTIFICATION
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(date, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'task_channel',
          'Task Notification',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );

    /// 💾 LƯU DB
    final noti = AppNotification(
      taskId: taskId,
      subtaskId: subtaskId,
      notifyTime: date.toString(),
      type: type,
      isSent: 0,
    );

    await insert(noti);
  }

  /// ================= CANCEL =================
  static Future cancel(int id) async {
    await _plugin.cancel(id);
  }

  /// ================= CANCEL ALL =================
  static Future cancelAll() async {
    await _plugin.cancelAll();
  }


  static Future<List<Map<String, dynamic>>> getSystemNotifications() async {
    final db = await DBHelper.db;
    return await db.query('system_notifications', orderBy: 'created_at DESC');
  }

  static Future<List<Map<String, dynamic>>> getTaskNotifications() async {
    final db = await DBHelper.db;
    return await db.rawQuery('''
      SELECT t.title, t.deadline, c.name as categoryName
      FROM tasks t
      LEFT JOIN categories c ON t.category_id = c.id
      WHERE t.hasNotification = 1
      ORDER BY t.deadline ASC
    ''');
  }
}