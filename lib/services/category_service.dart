import '../database/db_helper.dart';
import '../models/category_model.dart';
import '../services/task_service.dart';
class CategoryService {

  static Future<int> insert(Category c) async {
    final db = await DBHelper.db;
    return db.insert('categories', c.toMap());
  }

  static Future<List<Category>> getAll() async {
    final db = await DBHelper.db;
    final res = await db.query('categories', orderBy: 'id DESC');
    return res.map((e) => Category.fromMap(e)).toList();
  }

  static Future<int> update(Category c) async {
    final db = await DBHelper.db;
    return db.update(
      'categories',
      c.toMap(),
      where: 'id=?',
      whereArgs: [c.id],
    );
  }

  static Future<int> delete(int id) async {
    final db = await DBHelper.db;
    return db.delete(
      'categories',
      where: 'id=?',
      whereArgs: [id],
    );
  }

  static Future<int> getTaskCount(int categoryId) async {
    final allTasks = await TaskService.getAll();
    return allTasks.where((t) => t.categoryId == categoryId).length;
  }

  static Future<Category?> getById(int id) async {
    final db = await DBHelper.db; // dùng giống các hàm khác
    final maps = await db.query(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return Category.fromMap(maps.first);
    }
    return null;
  }

}