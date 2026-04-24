import 'package:sqflite/sqflite.dart';

import '../database/db_helper.dart';
import '../models/task_model.dart';
import '../models/notification_model.dart';
import 'notification_service.dart';

class TaskService {

  // CREATE (có tạo notification)
  static Future<int> insert(Task t) async {
    final db = await DBHelper.db;

    int taskId = await db.insert('tasks', t.toMap());

    // 👉 tạo notification
    if (t.isReminder == 1 && t.reminderTime != null) {
      await NotificationService.insert(
        AppNotification(
          taskId: taskId,
          notifyTime: t.reminderTime!,
          type: 1,
        ),
      );
    }

    return taskId;
  }

  static Future<List<Task>> getAll() async {
    final db = await DBHelper.db;
    final maps = await db.rawQuery('''
    SELECT t.*, c.name as categoryName, c.icon as categoryIcon
    FROM tasks t
    LEFT JOIN categories c ON t.category_id = c.id
    ORDER BY t.deadline ASC
  ''');
    return maps.map((m) => Task.fromMap(m)).toList();
  }

  static Future<List<String>> getAllCategories() async {
    final db = await DBHelper.db;
    final maps = await db.query('categories', columns: ['name']);
    return maps.map((m) => m['name'] as String).toList();
  }


  // UPDATE
  static Future<int> update(Task t) async {
    final db = await DBHelper.db;
    return db.update(
      'tasks',
      t.toMap(),
      where: 'id=?',
      whereArgs: [t.id],
    );
  }

  // DELETE
  static Future<int> delete(int id) async {
    final db = await DBHelper.db;
    return db.delete('tasks', where: 'id=?', whereArgs: [id]);
  }

  /// Lấy danh sách task hôm nay
  static Future<List<Task>> getTodayTasks() async {
    final db = await DBHelper.db;
    final now = DateTime.now();
    final todayStr = "${now.year}-${now.month}-${now.day}";
    final maps = await db.query(
      'tasks',
      where: "deadline LIKE ?",
      whereArgs: ["$todayStr%"],
    );
    return maps.map((m) => Task.fromMap(m)).toList();
  }



  static Future<List<Task>> getHighPriorityTasks() async {
    final db = await DBHelper.db;
    final todayStr = DateTime.now().toIso8601String().substring(0,10); // yyyy-MM-dd

    final maps = await db.rawQuery('''
    SELECT t.*, c.name as categoryName
    FROM tasks t
    LEFT JOIN categories c ON t.category_id = c.id
    WHERE date(t.deadline) = date(?)
    ORDER BY t.deadline ASC
  ''', [todayStr]);

    return maps.map((m) => Task.fromMap(m)).toList();
  }

  static Future<List<Task>> getUpcomingTasks() async {
    final db = await DBHelper.db;
    final todayStr = DateTime.now().toIso8601String().substring(0,10);

    final maps = await db.rawQuery('''
    SELECT t.*, c.name as categoryName, c.icon as categoryIcon
    FROM tasks t
    LEFT JOIN categories c ON t.category_id = c.id
    WHERE date(t.deadline) > date(?)
    ORDER BY t.deadline ASC
  ''', [todayStr]);

    return maps.map((m) => Task.fromMap(m)).toList();
  }

  static Future<Map<String, int>> getOverviewStats() async {
    final db = await DBHelper.db;
    final now = DateTime.now();
    final todayStr =
        "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    // Đã hoàn thành hôm nay
    final done = Sqflite.firstIntValue(await db.rawQuery(
        "SELECT COUNT(*) FROM tasks WHERE status = 1 AND deadline LIKE ?",
        ["$todayStr%"])) ?? 0;

    // Tổng số hôm nay
    final total = Sqflite.firstIntValue(await db.rawQuery(
        "SELECT COUNT(*) FROM tasks WHERE deadline LIKE ?",
        ["$todayStr%"])) ?? 0;

    // Quá hạn
    final overdue = Sqflite.firstIntValue(await db.rawQuery(
        "SELECT COUNT(*) FROM tasks WHERE status = 0 AND deadline < ?",
        [now.toIso8601String()])) ?? 0;

    return {
      "done": done,
      "total": total,
      "overdue": overdue,
    };
  }
  static Future<List<Task>> searchTasks({
    String? query,
    String? category,
    String? priority,
    String? dateFilter,
  }) async {
    final db = await DBHelper.db;
    String sql = '''
    SELECT t.*, c.name as categoryName, c.icon as categoryIcon
    FROM tasks t
    LEFT JOIN categories c ON t.category_id = c.id
    WHERE 1=1
  ''';
    List<dynamic> args = [];

    if (query != null && query.isNotEmpty) {
      sql += " AND t.title LIKE ?";
      args.add('%$query%');
    }
    if (category != null && category != "Tất cả") {
      sql += " AND c.name = ?";
      args.add(category);
    }
    if (priority != null && priority != "Tất cả") {
      if (priority == "Cao") sql += " AND t.priority = 3";
      if (priority == "Trung bình") sql += " AND t.priority = 2";
      if (priority == "Thấp") sql += " AND t.priority = 1";
    }
    if (dateFilter != null && dateFilter != "Tất cả") {
      final today = DateTime.now();
      if (dateFilter == "Hôm nay") {
        sql += " AND date(t.deadline) = date(?)";
        args.add(today.toIso8601String().substring(0,10));
      } else if (dateFilter == "Tuần này") {
        final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        sql += " AND date(t.deadline) BETWEEN date(?) AND date(?)";
        args.add(startOfWeek.toIso8601String().substring(0,10));
        args.add(endOfWeek.toIso8601String().substring(0,10));
      } else if (dateFilter == "Quá hạn") {
        sql += " AND date(t.deadline) < date(?)";
        args.add(today.toIso8601String().substring(0,10));
      }
    }

    sql += " ORDER BY t.deadline ASC";

    final maps = await db.rawQuery(sql, args);
    return maps.map((m) => Task.fromMap(m)).toList();
  }

}