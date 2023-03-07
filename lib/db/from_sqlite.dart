import 'dart:developer';

import 'package:flutter/material.dart';

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
            'CREATE TABLE tasks(id TEXT PRIMARY KEY, title TEXT, is_done INTEGER, is_important INTEGER, is_urgent INTEGER, create_dt INTEGER, update_dt INTEGER, sort INTEGER)');
        db.execute(
            'CREATE TABLE sub_tasks(id TEXT PRIMARY KEY, parent_id TEXT, title TEXT, is_done INTEGER, create_dt INTEGER, update_dt INTEGER, sort INTEGER)');
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

  Future<int> getSubTaskMaxSort(String parentID) async {
    final db = await createDatabase();
    final result = await db.rawQuery(
        'SELECT IFNULL(MAX(sort), 1) as max_sort FROM $sqliteSubTaskTableName WHERE parent_id = "$parentID"');
    return result.first['max_sort'] as int;
  }

  @override
  Future<List<Task>> fetchTasks(bool important, bool urgent) async {
    final db = await createDatabase();
    final tasks = await db.query(sqliteTableName,
        where: 'is_important = ? and is_urgent = ?',
        whereArgs: [important ? 1 : 0, urgent ? 1 : 0]);
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
  Future<void> updateSubTaskSort(Map<String, int> data) async {
    final db = await createDatabase();
    final batch = db.batch();
    data.forEach((id, sort) {
      batch.update(
        sqliteSubTaskTableName,
        {'sort': sort},
        where: 'id = ?',
        whereArgs: [id],
      );
    });
    batch.commit();
    return;
  }

  @override
  Future<SubTask> addSubTask(SubTask task) async {
    final db = await createDatabase();
    task.createDt = Timeline.now;
    task.id = Uuid().v4();
    int maxID = await getSubTaskMaxSort(task.parentID);
    task.sort = maxID + 1;
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
        where: 'parent_id = ?', whereArgs: [parentID]);

    List<SubTask> rst = List.generate(
        tasks.length, (index) => SubTask.fromSqlite(tasks[index]));
    rst.sort((a, b) => a.compareTo(b));
    return rst;
  }

  @override
  Future<SubTask> updateSubTask(SubTask task) async {
    final db = await createDatabase();
    task.updateDt = Timeline.now;
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
