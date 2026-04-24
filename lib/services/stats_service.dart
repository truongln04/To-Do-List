// lib/services/stats_service.dart
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../database/db_helper.dart';

class StatsService {
  static List<String> _rangeArgs(DateTimeRange range) =>
      [range.start.toIso8601String(), range.end.toIso8601String()];

  /// Overview: trả Map<String,int> với keys: total, done, doing, overdue
  static Future<Map<String, int>> getOverviewStats({DateTimeRange? range}) async {
    final db = await DBHelper.db;

    // total tasks
    final taskTotalSql = StringBuffer('SELECT COUNT(*) as cnt FROM tasks');
    final taskTotalArgs = <dynamic>[];
    if (range != null) {
      taskTotalSql.write(' WHERE deadline BETWEEN ? AND ?');
      taskTotalArgs.addAll(_rangeArgs(range));
    }
    final taskTotalRes = await db.rawQuery(taskTotalSql.toString(), taskTotalArgs);
    final taskTotal = Sqflite.firstIntValue(taskTotalRes) ?? 0;

    // total subtasks
    final subTotalSql = StringBuffer('SELECT COUNT(*) as cnt FROM subtasks');
    final subTotalArgs = <dynamic>[];
    if (range != null) {
      subTotalSql.write(' WHERE deadline BETWEEN ? AND ?');
      subTotalArgs.addAll(_rangeArgs(range));
    }
    final subTotalRes = await db.rawQuery(subTotalSql.toString(), subTotalArgs);
    final subTotal = Sqflite.firstIntValue(subTotalRes) ?? 0;

    final total = taskTotal + subTotal;

    // done (tasks.status=1, subtasks.is_done=1)
    final taskDoneSql = StringBuffer('SELECT COUNT(*) as cnt FROM tasks WHERE status = 1');
    final taskDoneArgs = <dynamic>[];
    if (range != null) {
      taskDoneSql.write(' AND deadline BETWEEN ? AND ?');
      taskDoneArgs.addAll(_rangeArgs(range));
    }
    final taskDone = Sqflite.firstIntValue(await db.rawQuery(taskDoneSql.toString(), taskDoneArgs)) ?? 0;

    final subDoneSql = StringBuffer('SELECT COUNT(*) as cnt FROM subtasks WHERE is_done = 1');
    final subDoneArgs = <dynamic>[];
    if (range != null) {
      subDoneSql.write(' AND deadline BETWEEN ? AND ?');
      subDoneArgs.addAll(_rangeArgs(range));
    }
    final subDone = Sqflite.firstIntValue(await db.rawQuery(subDoneSql.toString(), subDoneArgs)) ?? 0;

    final done = taskDone + subDone;

    // doing (tasks.status = 2). Subtasks model không có trạng thái "doing" mặc định.
    final taskDoingSql = StringBuffer('SELECT COUNT(*) as cnt FROM tasks WHERE status = 2');
    final taskDoingArgs = <dynamic>[];
    if (range != null) {
      taskDoingSql.write(' AND deadline BETWEEN ? AND ?');
      taskDoingArgs.addAll(_rangeArgs(range));
    }
    final doing = Sqflite.firstIntValue(await db.rawQuery(taskDoingSql.toString(), taskDoingArgs)) ?? 0;

    // overdue: deadline < now AND not done
    final nowIso = DateTime.now().toIso8601String();
    final taskOverdueSql = StringBuffer('SELECT COUNT(*) as cnt FROM tasks WHERE status != 1 AND deadline < ?');
    final taskOverdueArgs = <dynamic>[nowIso];
    if (range != null) {
      taskOverdueSql.write(' AND deadline BETWEEN ? AND ?');
      taskOverdueArgs.addAll(_rangeArgs(range));
    }
    final taskOverdue = Sqflite.firstIntValue(await db.rawQuery(taskOverdueSql.toString(), taskOverdueArgs)) ?? 0;

    final subOverdueSql = StringBuffer('SELECT COUNT(*) as cnt FROM subtasks WHERE is_done != 1 AND deadline < ?');
    final subOverdueArgs = <dynamic>[nowIso];
    if (range != null) {
      subOverdueSql.write(' AND deadline BETWEEN ? AND ?');
      subOverdueArgs.addAll(_rangeArgs(range));
    }
    final subOverdue = Sqflite.firstIntValue(await db.rawQuery(subOverdueSql.toString(), subOverdueArgs)) ?? 0;

    final overdue = taskOverdue + subOverdue;

    return {
      'total': total,
      'done': done,
      'doing': doing,
      'overdue': overdue,
    };
  }

  /// Category stats: count tasks + subtasks per category
  static Future<List<Map<String, dynamic>>> getCategoryStats({DateTimeRange? range}) async {
    final db = await DBHelper.db;
    final args = <dynamic>[];

    final taskRangeClause = range != null ? 'AND t.deadline BETWEEN ? AND ?' : '';
    final subRangeClause = range != null ? 'AND s.deadline BETWEEN ? AND ?' : '';
    if (range != null) args.addAll(_rangeArgs(range)); // for tasks subquery
    if (range != null) args.addAll(_rangeArgs(range)); // for subtasks subquery

    final sql = '''
      SELECT c.id as categoryId, c.name as categoryName,
  (SELECT COUNT(*) FROM tasks t WHERE t.category_id = c.id) as count
FROM categories c
ORDER BY count DESC;

    ''';

    return await db.rawQuery(sql, args.isEmpty ? null : args);
  }

  /// Weekly progress: returns list of { "weekday": int(0..6), "count": int }
  static Future<List<Map<String, dynamic>>> getWeeklyProgress({DateTimeRange? range}) async {
    final db = await DBHelper.db;
    final args = <dynamic>[];
    final where = StringBuffer();

    if (range != null) {
      where.write('WHERE deadline BETWEEN ? AND ?');
      args.addAll(_rangeArgs(range));
    } else {
      where.write("WHERE deadline BETWEEN date('now','-6 days') AND date('now')");
    }

    final sql = '''
      SELECT strftime('%w', deadline) as weekday, COUNT(*) as count
      FROM (
        SELECT deadline FROM tasks
        UNION ALL
        SELECT deadline FROM subtasks
      ) as combined
      $where
      GROUP BY weekday
    ''';

    final res = await db.rawQuery(sql, args.isEmpty ? null : args);
    return res.map((r) => {"weekday": int.parse(r['weekday'].toString()), "count": r['count'] as int}).toList();
  }

  /// Tasks list
  static Future<List<Map<String, dynamic>>> getTasks({bool completedOnly = false, DateTimeRange? range}) async {
    final db = await DBHelper.db;
    final where = <String>[];
    final args = <dynamic>[];

    if (completedOnly) {
      where.add('t.status = ?');
      args.add(1);
    }
    if (range != null) {
      where.add('t.deadline BETWEEN ? AND ?');
      args.addAll(_rangeArgs(range));
    }

    final whereClause = where.isNotEmpty ? 'WHERE ' + where.join(' AND ') : '';
    final sql = '''
      SELECT t.*, c.name as categoryName
      FROM tasks t
      LEFT JOIN categories c ON t.category_id = c.id
      $whereClause
      ORDER BY t.deadline ASC
    ''';
    return await db.rawQuery(sql, args.isEmpty ? null : args);
  }

  /// Subtasks list
  static Future<List<Map<String, dynamic>>> getSubtasks({bool completedOnly = false, DateTimeRange? range}) async {
    final db = await DBHelper.db;
    final where = <String>[];
    final args = <dynamic>[];

    if (completedOnly) {
      where.add('s.is_done = ?');
      args.add(1);
    }
    if (range != null) {
      where.add('s.deadline BETWEEN ? AND ?');
      args.addAll(_rangeArgs(range));
    }

    final whereClause = where.isNotEmpty ? 'WHERE ' + where.join(' AND ') : '';
    final sql = '''
      SELECT s.*, t.category_id as category_id, c.name as categoryName
      FROM subtasks s
      LEFT JOIN tasks t ON s.task_id = t.id
      LEFT JOIN categories c ON t.category_id = c.id
      $whereClause
      ORDER BY s.deadline ASC
    ''';
    return await db.rawQuery(sql, args.isEmpty ? null : args);
  }
}
