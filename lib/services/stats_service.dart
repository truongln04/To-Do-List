import 'package:sqflite/sqflite.dart';
import '../database//db_helper.dart';

class StatsService {
  static Future<Map<String, int>> getOverviewStats() async {
    final db = await DBHelper.db;
    final total = Sqflite.firstIntValue(await db.rawQuery("SELECT COUNT(*) FROM tasks")) ?? 0;
    final done = Sqflite.firstIntValue(await db.rawQuery("SELECT COUNT(*) FROM tasks WHERE status = 1")) ?? 0;
    final overdue = Sqflite.firstIntValue(await db.rawQuery("SELECT COUNT(*) FROM tasks WHERE deadline < date('now') AND status = 0")) ?? 0;
    return {"total": total, "done": done, "overdue": overdue};
  }

  static Future<List<Map<String, dynamic>>> getCategoryStats() async {
    final db = await DBHelper.db;
    return await db.rawQuery('''
      SELECT c.name as categoryName, COUNT(t.id) as count
      FROM categories c
      LEFT JOIN tasks t ON t.category_id = c.id
      GROUP BY c.id
    ''');
  }

  static Future<List<Map<String, dynamic>>> getWeeklyProgress() async {
    final db = await DBHelper.db;
    return await db.rawQuery('''
      SELECT strftime('%w', deadline) as weekday, COUNT(*) as count
      FROM tasks
      WHERE deadline BETWEEN date('now','-6 days') AND date('now')
      GROUP BY weekday
    ''');
  }

  static Future<List<Map<String, dynamic>>> getTasks({bool completedOnly = false}) async {
    final db = await DBHelper.db;
    String sql = "SELECT * FROM tasks";
    if (completedOnly) sql += " WHERE status = 1";
    return await db.rawQuery(sql);
  }
}
