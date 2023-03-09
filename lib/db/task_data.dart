import '../config/config.dart';
import '../model/task.dart';
import 'from_api.dart';
import 'from_sqlite.dart';

const String rootParentID = "";

Task rootParent = Task(id: rootParentID);

abstract class TaskData {
  Future<void> clean(String parentID);
  Future<List<Task>> fetchRootTasks(bool important, bool urgent);
  Future<List<Task>> getSubTasks(
      String? parentID, bool? important, bool? urgent);
  Future<Task> addTask(Task task);
  Future<Task> getTask(String id);
  Future<Task> updateTask(Task task);
  Future<Task> updateTaskBlock(Task task);
  Future<void> updateTaskSort(Map<String, int> data);
  Future deleteTask(Task task);
}

TaskData getTaskData() {
  if (storeType == 'api') {
    return ApiData();
  } else {
    return SqliteData();
  }
}
