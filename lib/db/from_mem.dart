import '../model/task.dart';
import './task_data.dart';
import 'package:uuid/uuid.dart';

class MemData implements TaskData {
  List<Task> _tasks = [];

  @override
  Future<void> clean() async {
    _tasks = [];
  }

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
  Future<Task> updateTask(Task task) {
    final idx = _tasks.indexWhere((t) => t.id == task.id);
    if (idx >= 0) {
      _tasks[idx] = task;
    }
    return Future.value(task);
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
