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
        required int type, // 0 = system, 1 = task, 2 = subtask
      }) async {
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

    final noti = AppNotification(
      taskId: taskId,
      subtaskId: subtaskId,
      notifyTime: date.toString(),
      type: type,
      isSent: 0,
    );

    final insertedId = await insert(noti);
    print("✅ Inserted notification with id: $insertedId, type: $type");
  }

  /// ================= CANCEL =================
  static Future cancel(int id) async {
    await _plugin.cancel(id);
  }

  static Future cancelAll() async {
    await _plugin.cancelAll();
  }

  /// ================= QUERIES =================

  // Lấy thông báo hệ thống (type = 0)
  static Future<List<Map<String, dynamic>>> getSystemNotifications() async {
    final db = await DBHelper.db;
    return await db.query(
      'notifications',
      where: 'type = ?',
      whereArgs: [0],
      orderBy: 'notify_time DESC',
    );
  }

  // Lấy thông báo công việc (type = 1 hoặc 2)
  static Future<List<Map<String, dynamic>>> getTaskNotifications() async {
    final db = await DBHelper.db;
    return await db.rawQuery('''
      SELECT n.id, n.task_id as taskId, n.notify_time,
             t.title, t.deadline,
             c.id as categoryId, c.name as categoryName
      FROM notifications n
      LEFT JOIN tasks t ON n.task_id = t.id
      LEFT JOIN categories c ON t.category_id = c.id
      WHERE n.type IN (1,2)
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

  /// ================= DELETE =================
  static Future deleteNotification(int id) async {
    final db = await DBHelper.db;
    await db.delete('notifications', where: 'id = ?', whereArgs: [id]);
  }

  /// ================= UPDATE =================
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
