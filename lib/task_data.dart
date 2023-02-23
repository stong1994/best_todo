import 'package:flutter/foundation.dart';
import 'task.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TaskData extends ChangeNotifier {
  Future<List<Task>> fetchTasks() async {
    final response = await http.get(Uri.parse('http://127.0.0.1:8000/tasks'), headers: {"Content-Type": "application/json; charset=utf-8"});
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return List<Task>.from(data.map((json) => Task.fromJson(json)));
    } else {
      throw Exception('Failed to fetch tasks');
    }
  }

  Future<List<Task>> getTask(bool important, bool urgent) async {
    List<Task> tasks = await fetchTasks();
    return tasks;
  }

  Future<Task> updateTask(Task task) async {
    final response = await http.put(
      Uri.parse('http://127.0.0.1:8000/task/${task.id}'),
      headers: {"Content-Type": "application/json; charset=utf-8"},
      body: jsonEncode(task));
    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return Task.fromJson(data);
    } else {
      throw Exception('Failed to fetch tasks');
    }
    notifyListeners();
  }

  // int get taskCount {
  //   return _tasks.length;
  // }

  // void addTask(String newTaskTitle) {
  //   final task = Task(title: newTaskTitle, id: "100");
  //   _tasks.add(task);
  //   notifyListeners();
  // }

  // void updateTask(Task task) {
  //   // task.toggleDone();
  //   // _tasks.forEach((element) {
  //   //   if (element.hashCode == task.hashCode) {
  //   //     element = task;
  //   //   }
  //   // });

  //   int i = _tasks.indexOf(task);
  //   if (i >= 0) {
  //     _tasks[i] = task;
  //   } 
    
  //   notifyListeners();
  // }

  // void deleteTask(Task task) {
  //   _tasks.remove(task);
  //   notifyListeners();
  // }

}
