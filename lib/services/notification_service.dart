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

    final insertedId = await insert(noti);
    print(
        "✅ Inserted notification with id: $insertedId, taskId: $taskId, time: ${date
            .toString()}");
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
    SELECT n.id, n.task_id as taskId, n.notify_time,
           t.title, t.deadline,
           c.id as categoryId, c.name as categoryName
    FROM notifications n
    LEFT JOIN tasks t ON n.task_id = t.id
    LEFT JOIN categories c ON t.category_id = c.id
    ORDER BY n.notify_time ASC
  ''');
  }
  static Future<List<Map<String, dynamic>>> getFullNotifications() async {
    final db = await DBHelper.db;
    return await db.rawQuery('''
    SELECT n.id, n.notify_time, n.type, n.is_sent,
           n.task_id, t.title as taskTitle, t.deadline,
           n.subtask_id, s.title as subtaskTitle,
           c.id as categoryId, c.name as categoryName
    FROM notifications n
    LEFT JOIN tasks t ON n.task_id = t.id
    LEFT JOIN subtasks s ON n.subtask_id = s.id
    LEFT JOIN categories c ON t.category_id = c.id
    ORDER BY n.notify_time ASC
  ''');
  }



  // Xóa thông báo theo taskId
  static Future deleteByTaskId(int taskId) async {
    final db = await DBHelper.db;
    await db.delete(
      'notifications',
      where: 'task_id = ?',
      whereArgs: [taskId],
    );
  }

// Update thời gian nhắc
  static Future updateNotifyTime(int taskId, String newTime) async {
    final db = await DBHelper.db;
    await db.update(
      'notifications',
      {'notify_time': newTime, 'is_sent': 0},
      where: 'task_id = ?',
      whereArgs: [taskId],
    );
  }

}