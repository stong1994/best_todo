import '../model/task.dart';
import './task_data.dart';
import 'package:uuid/uuid.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../config/config.dart';

class SqliteData implements TaskData {
  // WidgetsFlutterBinding.ensureInitialized();
  Future<Database> createDatabase() async {
    return await openDatabase(
      join(await getDatabasesPath(), sqliteDBName),
      version: 1,
      onCreate: (db, version) {
        db.execute(
            'CREATE TABLE tasks(id TEXT PRIMARY KEY, title TEXT, is_done INTEGER, is_important INTEGER, is_urgent INTEGER)');
      },
    );
  }

  @override
  Future<void> clean() async {
    final db = await createDatabase();
    await db.delete(sqliteTableName);
    return;
  }

  @override
  Future<Task> addTask(Task task) async {
    final db = await createDatabase();
    task.id = Uuid().v4();
    await db.insert(sqliteTableName, task.toSqlite());
    return task;
  }

  @override
  Future deleteTask(Task task) async {
    final db = await createDatabase();
    await db.delete(
      sqliteTableName,
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  @override
  Future<List<Task>> fetchTasks(bool important, bool urgent) async {
    final db = await createDatabase();
    final tasks = await db.query(sqliteTableName,
        columns: ['id', 'title', 'is_done', 'is_important', 'is_urgent'],
        where: 'is_important = ? and is_urgent = ?',
        whereArgs: [important ? 1 : 0, urgent ? 1 : 0]);
    return List.generate(
        tasks.length, (index) => Task.fromSqlite(tasks[index]));
  }

  @override
  Future<Task> updateTask(Task task) async {
    final db = await createDatabase();
    await db.update(
      sqliteTableName,
      task.toSqlite(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
    return task;
  }
}
