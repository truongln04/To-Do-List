import '../database/db_helper.dart';
import '../models/subtask_model.dart';
import '../models/notification_model.dart';
import 'notification_service.dart';

class SubTaskService {

  // CREATE (có notification)
  static Future<int> insert(SubTask s) async {
    final db = await DBHelper.db;

    int subId = await db.insert('subtasks', s.toMap());

    // 👉 tạo notification
    if (s.isReminder == 1 && s.reminderTime != null) {
      await NotificationService.insert(
        AppNotification(
          subtaskId: subId,
          notifyTime: s.reminderTime!,
          type: 2,
        ),
      );
    }

    return subId;
  }

  // READ
  static Future<List<SubTask>> getByTask(int taskId) async {
    final db = await DBHelper.db;
    final res = await db.query(
      'subtasks',
      where: 'task_id=?',
      whereArgs: [taskId],
    );

    return res.map((e) => SubTask.fromMap(e)).toList();
  }

  // UPDATE
  static Future<int> update(SubTask s) async {
    final db = await DBHelper.db;
    return db.update(
      'subtasks',
      s.toMap(),
      where: 'id=?',
      whereArgs: [s.id],
    );
  }

  // DELETE
  static Future<int> delete(int id) async {
    final db = await DBHelper.db;
    return db.delete('subtasks', where: 'id=?', whereArgs: [id]);
  }


}