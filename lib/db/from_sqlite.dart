import '../model/sub_task.dart';
import '../model/task.dart';
import './task_data.dart';
import 'package:uuid/uuid.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../config/config.dart';

class SqliteData implements TaskData, SubTaskData {
  // WidgetsFlutterBinding.ensureInitialized();
  Future<Database> createDatabase() async {
    print(join(await getDatabasesPath(), sqliteDBName));
    return await openDatabase(
      join(await getDatabasesPath(), sqliteDBName),
      version: 1,
      onCreate: (db, version) {
        db.execute(
            'CREATE TABLE tasks(id TEXT PRIMARY KEY, title TEXT, is_done INTEGER, is_important INTEGER, is_urgent INTEGER)');
        db.execute(
            'CREATE TABLE sub_tasks(id TEXT PRIMARY KEY, parent_id TEXT, title TEXT, is_done INTEGER)');
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

  @override
  Future<SubTask> addSubTask(SubTask task) async {
    final db = await createDatabase();
    task.id = Uuid().v4();
    await db.insert(sqliteSubTaskTableName, task.toSqlite());
    return task;
  }

  @override
  Future deleteSubTask(SubTask task) async {
    final db = await createDatabase();
    await db.delete(
      sqliteSubTaskTableName,
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  @override
  Future<List<SubTask>> fetchSubTasks(String parentID) async {
    final db = await createDatabase();
    final tasks = await db.query(sqliteSubTaskTableName,
        columns: ['id', 'title', 'is_done', 'parent_id'],
        where: 'parent_id = ?',
        whereArgs: [parentID]);
    return List.generate(
        tasks.length, (index) => SubTask.fromSqlite(tasks[index]));
  }

  @override
  Future<SubTask> updateSubTask(SubTask task) async {
    final db = await createDatabase();
    await db.update(
      sqliteSubTaskTableName,
      task.toSqlite(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
    return task;
  }

  @override
  Future<void> cleanSubTasks(String parentID) async {
    final db = await createDatabase();
    await db.delete(
      sqliteSubTaskTableName,
      where: 'parent_id = ?',
      whereArgs: [parentID],
    );
  }
}
