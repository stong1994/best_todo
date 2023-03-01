import '../config/config.dart';
import '../model/task.dart';
import 'from_api.dart';
import 'from_mem.dart';
import 'from_sqlite.dart';

abstract class TaskData {
  Future<void> clean();
  Future<List<Task>> fetchTasks(bool important, bool urgent);
  Future<Task> addTask(Task task);
  Future<Task> updateTask(Task task);
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
