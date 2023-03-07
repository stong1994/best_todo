import 'dart:developer';

import '../model/task.dart';
import './task_data.dart';
import 'package:uuid/uuid.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../config/config.dart';

class SqliteData implements TaskData {
  // WidgetsFlutterBinding.ensureInitialized();
  Future<Database> createDatabase() async {
    print(join(await getDatabasesPath(), sqliteDBName));
    return await openDatabase(
      join(await getDatabasesPath(), sqliteDBName),
      version: 1,
      onCreate: (db, version) {
        db.execute(
            'CREATE TABLE tasks(id TEXT PRIMARY KEY, parent_id TEXT, title TEXT, detail TEXT, is_done INTEGER, is_important INTEGER, is_urgent INTEGER, create_dt INTEGER, update_dt INTEGER, sort INTEGER)');
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
    task.createDt = Timeline.now;
    task.id = Uuid().v4();
    task.sort = await getTaskMaxSort() + 1;
    await db.insert(sqliteTableName, task.toSqlite());
    return task;
  }

  @override
  Future<Task> getTask(String id) async {
    final db = await createDatabase();
    final tasks =
        await db.query(sqliteTableName, where: 'id = ?', whereArgs: [id]);
    return Task.fromSqlite(tasks.first);
  }

  Future<int> getTaskMaxSort() async {
    final db = await createDatabase();
    final result = await db.rawQuery(
        'SELECT IFNULL(MAX(sort), 1) as max_sort FROM $sqliteTableName');
    return result.first['max_sort'] as int;
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
  Future<List<Task>> fetchRootTasks(bool important, bool urgent) async {
    final db = await createDatabase();
    final tasks = await db.query(sqliteTableName,
        where: 'parent_id = ? and is_important = ? and is_urgent = ?',
        whereArgs: [rootParentID, important ? 1 : 0, urgent ? 1 : 0]);
    List<Task> rst =
        List.generate(tasks.length, (index) => Task.fromSqlite(tasks[index]));
    rst.sort((a, b) => a.compareTo(b));
    return rst;
  }

  @override
  Future<Task> updateTask(Task task) async {
    final db = await createDatabase();
    task.updateDt = Timeline.now;
    await db.update(
      sqliteTableName,
      task.toSqlite(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
    return task;
  }

  @override
  Future<List<Task>> getSubTasks(String parentID) async {
    final db = await createDatabase();
    final tasks = await db
        .query(sqliteTableName, where: 'parent_id = ?', whereArgs: [parentID]);

    List<Task> rst =
        List.generate(tasks.length, (index) => Task.fromSqlite(tasks[index]));
    rst.sort((a, b) => a.compareTo(b));
    return rst;
  }

  @override
  Future<void> updateTaskSort(Map<String, int> data) async {
    final db = await createDatabase();
    final batch = db.batch();
    data.forEach((id, sort) {
      batch.update(
        sqliteTableName,
        {'sort': sort},
        where: 'id = ?',
        whereArgs: [id],
      );
    });
    batch.commit();
    return;
  }
}
