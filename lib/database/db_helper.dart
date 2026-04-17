import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _db;

  static Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  static Future<Database> initDB() async {
    String path = join(await getDatabasesPath(), 'todo_full.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {

        await db.execute('''
        CREATE TABLE categories (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          icon TEXT,
          created_at TEXT DEFAULT CURRENT_TIMESTAMP
        )
        ''');

        await db.execute('''
        CREATE TABLE tasks (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          description TEXT,
          deadline TEXT,
          priority INTEGER DEFAULT 2,
          category_id INTEGER,
          progress INTEGER DEFAULT 0,
          status INTEGER DEFAULT 0,
          is_reminder INTEGER DEFAULT 0,
          reminder_time TEXT,
          created_at TEXT DEFAULT CURRENT_TIMESTAMP,
          updated_at TEXT
        )
        ''');

        await db.execute('''
        CREATE TABLE subtasks (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          task_id INTEGER,
          title TEXT NOT NULL,
          description TEXT,
          deadline TEXT,
          is_done INTEGER DEFAULT 0,
          is_reminder INTEGER DEFAULT 0,
          reminder_time TEXT,
          created_at TEXT DEFAULT CURRENT_TIMESTAMP
        )
        ''');

        await db.execute('''
        CREATE TABLE notifications (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          task_id INTEGER,
          subtask_id INTEGER,
          notify_time TEXT,
          type INTEGER,
          is_sent INTEGER DEFAULT 0,
          created_at TEXT DEFAULT CURRENT_TIMESTAMP
        )
        ''');
      },
    );
  }
}