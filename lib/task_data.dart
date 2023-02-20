import 'package:flutter/foundation.dart';
import 'task.dart';

class TaskData extends ChangeNotifier {
  List<Task> _tasks = [
    Task(title: 'Buy milk', id: "1"),
    Task(title: 'Buy eggs', id: "2"),
    Task(title: 'Buy bread', id: "3"),
  ];

  List<Task> get tasks {
    return _tasks;
  }

  List<Task> getTask(bool important, bool urgent) {
    return _tasks;
  }

  int get taskCount {
    return _tasks.length;
  }

  void addTask(String newTaskTitle) {
    final task = Task(title: newTaskTitle, id: "100");
    _tasks.add(task);
    notifyListeners();
  }

  void updateTask(Task task) {
    // task.toggleDone();
    // _tasks.forEach((element) {
    //   if (element.hashCode == task.hashCode) {
    //     element = task;
    //   }
    // });
    int i = _tasks.indexOf(task);
    if (i >= 0) {
      _tasks[i] = task;
    } 
    
    notifyListeners();
  }

  void deleteTask(Task task) {
    _tasks.remove(task);
    notifyListeners();
  }

}
