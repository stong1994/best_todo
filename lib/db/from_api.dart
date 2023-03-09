import 'package:best_todo/config/config.dart';

import '../model/task.dart';
import './task_data.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiData implements TaskData {
  List<Task> _tasks = [];

  @override
  Future<List<Task>> fetchTasks(bool important, bool urgent) async {
    final response = await http.get(
        Uri.parse('$apiUrl/tasks?important=$important&urgent=$urgent'),
        headers: {"Content-Type": "application/json; charset=utf-8"});
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      _tasks = List<Task>.from(data.map((json) => Task.fromJson(json)));
      return _tasks;
    } else {
      throw Exception('Failed to fetch tasks');
    }
  }

  @override
  Future<Task> addTask(Task task) async {
    final response = await http.post(Uri.parse('$apiUrl/task'),
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

  @override
  Future<Task> updateTask(Task task) async {
    final response = await http.put(Uri.parse('$apiUrl/task/${task.id}'),
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

  @override
  Future deleteTask(Task task) async {
    final response = await http.delete(Uri.parse('$apiUrl/task/${task.id}'),
        headers: {"Content-Type": "application/json; charset=utf-8"});
    if (response.statusCode == 200) {
      _tasks.removeWhere((t) => t.id == task.id);
      return;
    } else {
      throw Exception('Failed to delete task');
    }
  }

  @override
  Future<void> clean() async {
    final response = await http.delete(Uri.parse('$apiUrl/tasks'),
        headers: {"Content-Type": "application/json; charset=utf-8"});
    if (response.statusCode == 200) {
      _tasks = [];
      return;
    } else {
      throw Exception('Failed to delete task');
    }
  }

  @override
  Future<void> updateTaskSort(Map<String, int> data) {
    // TODO: implement updateTaskSort
    throw UnimplementedError();
  }

  @override
  Future<List<Task>> fetchRootTasks(bool important, bool urgent) {
    // TODO: implement fetchRootTasks
    throw UnimplementedError();
  }

  @override
  Future<Task> getTask(String id) {
    // TODO: implement getTask
    throw UnimplementedError();
  }

  @override
  Future<List<Task>> getSubTasks(
      String? parentID, bool? important, bool? urgent) {
    // TODO: implement getSubTasks
    throw UnimplementedError();
  }
}
