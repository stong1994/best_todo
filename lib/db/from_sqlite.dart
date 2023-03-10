import 'dart:developer';

import 'package:best_todo/model/navigator.dart';

import '../model/task.dart';
import './task_data.dart';
import 'package:uuid/uuid.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../config/config.dart';
import 'navigator_data.dart';

class SqliteData implements TaskData, NavigatorData {
  // WidgetsFlutterBinding.ensureInitialized();
  Future<Database> createDatabase() async {
    print(join(await getDatabasesPath(), sqliteDBName));
    return await openDatabase(
      join(await getDatabasesPath(), sqliteDBName),
      version: 1,
      onCreate: (db, version) {
        db.execute(
            'CREATE TABLE tasks(id TEXT PRIMARY KEY, parent_id TEXT, navigator_id TEXT, title TEXT, detail TEXT, is_done INTEGER, is_important INTEGER, is_urgent INTEGER, create_dt INTEGER, update_dt INTEGER, sort INTEGER)');
        db.execute(
            'CREATE TABLE navigators(id TEXT PRIMARY KEY, title TEXT, create_dt INTEGER, update_dt INTEGER, sort INTEGER)');
      },
    );
  }

  @override
  Future<void> clean(String parentID) async {
    final db = await createDatabase();
    await db.delete(
      sqliteTableName,
      where: 'parent_id = ?',
      whereArgs: [parentID],
    );
    return;
  }

  @override
  Future<Task> addTask(Task task) async {
    final db = await createDatabase();
    task.createDt = Timeline.now;
    task.id = Uuid().v4();
    task.sort = await getTaskMaxSort(task.parentID) + 1;
    await db.insert(sqliteTableName, task.toSqlite());
    return task;
  }

  @override
  Future<Task> getTask(String id) async {
    if (id == rootParentID) {
      return rootParent;
    }
    final db = await createDatabase();
    final tasks =
        await db.query(sqliteTableName, where: 'id = ?', whereArgs: [id]);
    return Task.fromSqlite(tasks.first);
  }

  Future<int> getTaskMaxSort(String parentID) async {
    final db = await createDatabase();
    final result = await db.rawQuery(
        'SELECT IFNULL(MAX(sort), 1) as max_sort FROM $sqliteTableName WHERE parent_id = "$parentID"');
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
  Future<Task> updateTaskBlock(Task task) async {
    final maxSort = await getTaskMaxSort(task.parentID);
    final db = await createDatabase();
    task.updateDt = Timeline.now;
    task.sort = maxSort + 1;
    await db.update(
      sqliteTableName,
      task.toSqlite(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
    return task;
  }

  @override
  Future<List<Task>> getSubTasks(
      String? parentID, bool? important, bool? urgent) async {
    final db = await createDatabase();
    List<String> where = [];
    List<dynamic> args = [];
    if (parentID != Null) {
      where.add('parent_id = ?');
      args.add(parentID!);
    }
    if (important != Null) {
      where.add('is_important = ?');
      args.add(important!);
    }
    if (urgent != Null) {
      where.add('is_urgent = ?');
      args.add(urgent!);
    }
    final tasks = await db.query(sqliteTableName,
        where: where.isNotEmpty ? where.join(' and ') : null,
        whereArgs: args.isNotEmpty ? args : null);

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

  @override
  Future<Navigator> addNavigator(Navigator navigator) async {
    final db = await createDatabase();
    navigator.createDt = Timeline.now;
    navigator.id = Uuid().v4();
    navigator.sort = await getNavigatorMaxSort() + 1;
    await db.insert(sqliteNavigatorTableName, navigator.toSqlite());
    return navigator;
  }

  Future<int> getNavigatorMaxSort() async {
    final db = await createDatabase();
    final result = await db.rawQuery(
        'SELECT IFNULL(MAX(sort), 1) as max_sort FROM $sqliteNavigatorTableName');
    return result.first['max_sort'] as int;
  }

  @override
  Future deleteNavigator(Navigator navigator) async {
    final db = await createDatabase();
    await db.delete(
      sqliteNavigatorTableName,
      where: 'id = ?',
      whereArgs: [navigator.id],
    );
  }

  @override
  Future<List<Navigator>> fetchNavigators() async {
    final db = await createDatabase();
    final navigators = await db.query(sqliteNavigatorTableName);
    List<Navigator> rst = List.generate(
        navigators.length, (index) => Navigator.fromSqlite(navigators[index]));
    rst.sort((a, b) => a.compareTo(b));
    return rst;
  }

  @override
  Future<Navigator> getNavigator(String id) async {
    final db = await createDatabase();
    final navigators = await db
        .query(sqliteNavigatorTableName, where: 'id = ?', whereArgs: [id]);
    return Navigator.fromSqlite(navigators.first);
  }

  @override
  Future<Navigator> updateNavigator(Navigator navigator) async {
    final db = await createDatabase();
    navigator.updateDt = Timeline.now;
    await db.update(
      sqliteNavigatorTableName,
      navigator.toSqlite(),
      where: 'id = ?',
      whereArgs: [navigator.id],
    );
    return navigator;
  }
}
