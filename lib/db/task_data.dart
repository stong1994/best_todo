import '../config/config.dart';
import '../model/task.dart';
import 'from_api.dart';
import 'from_mem.dart';
import 'from_sqlite.dart';

const String rootParentID = "";

abstract class TaskData {
  Future<void> clean();
  Future<List<Task>> fetchRootTasks(bool important, bool urgent);
  Future<List<Task>> getSubTasks(String parentID);
  Future<Task> addTask(Task task);
  Future<Task> getTask(String id);
  Future<Task> updateTask(Task task);
  Future<void> updateTaskSort(Map<String, int> data);
  Future deleteTask(Task task);
}

TaskData getTaskData() {
  if (storeType == 'mem') {
    return MemData();
  } else if (storeType == 'api') {
    return ApiData();
  } else {
    return SqliteData();
  }
}
