import '../database/db_helper.dart';
import '../models/category_model.dart';

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
}