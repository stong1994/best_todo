import 'package:path/path.dart';

import 'task.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:sprintf/sprintf.dart';
import 'package:uuid/uuid.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/widgets.dart';

abstract class TaskData {
  Future<List<Task>> fetchTasks(bool important, bool urgent);
  Future<Task> addTask(Task task);
  Future<Task> updateTask(Task task);
  Future deleteTask(Task task);
}

class SqliteData implements TaskData {
  late Database db;
  final TABLE = "tasks";
  // WidgetsFlutterBinding.ensureInitialized();
  Future<Database> createDatabase() async {
    return await openDatabase(
      join(await getDatabasesPath(), 'task.db'),
      version: 1,
      onCreate: (db, version) {
        db.execute(
            'CREATE TABLE tasks(id TEXT PRIMARY KEY, title TEXT, is_done INTEGER, is_important INTEGER, is_urgent INTEGER)');
      },
    );
  }

  @override
  Future<Task> addTask(Task task) async {
    task.id = Uuid().v4();
    await db.insert(TABLE, task.toJson());
    return task;
  }

  @override
  Future deleteTask(Task task) async {
    await db.delete(
      TABLE,
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  @override
  Future<List<Task>> fetchTasks(bool important, bool urgent) async {
    final tasks = await db.query(TABLE);
    return List.generate(tasks.length, (index) => Task.fromJson(tasks[index]));
  }

  @override
  Future<Task> updateTask(Task task) async {
    await db.update(
      TABLE,
      task.toJson(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
    return task;
  }
}

class MemData implements TaskData {
  List<Task> _tasks = [];
  @override
  Future<Task> addTask(Task task) {
    task.id = Uuid().v4();
    _tasks.add(task);
    return Future.value(task);
  }

  @override
  Future deleteTask(Task task) {
    _tasks.removeWhere((t) => t.id == task.id);
    return Future.value(null);
  }

  @override
  Future<List<Task>> fetchTasks(bool important, bool urgent) {
    return Future.value(_tasks);
  }

  @override
  Future<Task> updateTask(Task task) {
    final idx = _tasks.indexWhere((t) => t.id == task.id);
    if (idx >= 0) {
      _tasks[idx] = task;
    }
    return Future.value(task);
  }
}

class ApiData implements TaskData {
  List<Task> _tasks = [];

  // deprecated
  Future<List<Task>> getTasksFromMem(bool important, bool urgent) async {
    final t = _tasks
        .where((task) => task.isImportant == important && task.isUrgent)
        .toList();
    return t;
  }

  Future<List<Task>> fetchTasks(bool important, bool urgent) async {
    final response = await http.get(
        Uri.parse(sprintf('http://127.0.0.1:8000/tasks?important=%s&urgent=%s',
            [important, urgent])),
        headers: {"Content-Type": "application/json; charset=utf-8"});
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      _tasks = List<Task>.from(data.map((json) => Task.fromJson(json)));
      return _tasks;
    } else {
      throw Exception('Failed to fetch tasks');
    }
  }

  Future<Task> addTask(Task task) async {
    final response = await http.post(Uri.parse('http://127.0.0.1:8000/task'),
        headers: {"Content-Type": "application/json; charset=utf-8"},
        body: jsonEncode(task));
    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      final task = Task.fromJson(data);
      _tasks.add(task);
      return task;
    } else {
      throw Exception('Failed to fetch tasks');
    }
  }

  Future<Task> updateTask(Task task) async {
    final response = await http.put(
        Uri.parse('http://127.0.0.1:8000/task/${task.id}'),
        headers: {"Content-Type": "application/json; charset=utf-8"},
        body: jsonEncode(task));
    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      int index = _tasks.indexWhere((t) => t.id == task.id);
      if (index > -1) {
        _tasks[index] = Task.fromJson(data);
      }
      return Task.fromJson(data);
    } else {
      throw Exception('Failed to update task');
    }
  }

  Future deleteTask(Task task) async {
    final response = await http.delete(
        Uri.parse('http://127.0.0.1:8000/task/${task.id}'),
        headers: {"Content-Type": "application/json; charset=utf-8"});
    if (response.statusCode == 200) {
      _tasks.removeWhere((t) => t.id == task.id);
      return;
    } else {
      throw Exception('Failed to delete task');
    }
  }
}
