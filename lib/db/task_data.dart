import '../model/task.dart';

abstract class TaskData {
  Future<List<Task>> fetchTasks(bool important, bool urgent);
  Future<Task> addTask(Task task);
  Future<Task> updateTask(Task task);
  Future deleteTask(Task task);
}
