import '../model/task.dart';
import './task_data.dart';
import 'package:http/http.dart' as http;
import 'package:sprintf/sprintf.dart';
import 'dart:convert';

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
