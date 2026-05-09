import '../database/db_helper.dart';
import '../models/notification_model.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();

  /// ================= INIT =================
  static Future<void> init() async {
    // Khởi tạo timezone
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));

    // Android settings
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS settings
    const DarwinInitializationSettings iosSettings =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings =
    InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _notifications.initialize(settings);

    // Tạo channel Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'task_channel', // ID phải trùng với ID trong NotificationDetails
      'Task Notifications',
      description: 'Thông báo nhắc việc',
      importance: Importance.max,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Xin quyền iOS
    await _notifications
        .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  /// ================= SCHEDULE =================
  static Future<void> schedule(
      int id,
      String title,
      String body,
      DateTime scheduledTime, {
        int? taskId,
        int? type,
      }) async {
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'task_channel',
          'Task Notifications',
          channelDescription: 'Thông báo nhắc việc',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      // androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// ================= SHOW NOW =================
  static Future<void> showNow(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'task_channel',
      'Task Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    await _notifications.show(0, title, body, details);
  }

  /// ================= CANCEL =================
  static Future<void> cancel(int id) async {
    await _notifications.cancel(id);
  }

  static Future<void> cancelAll() async {
    await _notifications.cancelAll();
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
