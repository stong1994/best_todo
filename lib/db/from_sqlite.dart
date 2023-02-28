import '../model/task.dart';
import './task_data.dart';
import 'package:uuid/uuid.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// import 'dart:convert';

class SqliteData implements TaskData {
  final TABLE = "tasks";
  // WidgetsFlutterBinding.ensureInitialized();
  Future<Database> createDatabase() async {
    final path = join(await getDatabasesPath(), 'best_todo.db');
    print("path: " + path);
    return await openDatabase(
      join(await getDatabasesPath(), 'best_todo.db'),
      version: 1,
      onCreate: (db, version) {
        db.execute(
            'CREATE TABLE tasks(id TEXT PRIMARY KEY, title TEXT, is_done INTEGER, is_important INTEGER, is_urgent INTEGER)');
      },
    );
  }

  @override
  Future<Task> addTask(Task task) async {
    final db = await createDatabase();
    task.id = Uuid().v4();
    await db.insert(TABLE, task.toJson());
    return task;
  }

  @override
  Future deleteTask(Task task) async {
    final db = await createDatabase();
    await db.delete(
      TABLE,
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  @override
  Future<List<Task>> fetchTasks(bool important, bool urgent) async {
    final db = await createDatabase();
    final tasks = await db.query(TABLE,
        columns: ['id', 'title', 'is_done', 'is_important', 'is_urgent'],
        where: 'is_important = ? and is_urgent = ?',
        whereArgs: [important, urgent]);
    return List.generate(
        tasks.length, (index) => Task.fromSqlite(tasks[index]));
  }

  @override
  Future<Task> updateTask(Task task) async {
    final db = await createDatabase();
    await db.update(
      TABLE,
      task.toJson(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
    return task;
  }
}
