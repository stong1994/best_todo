import '../config/config.dart';
import '../model/sub_task.dart';
import '../model/task.dart';
import 'from_api.dart';
import 'from_mem.dart';
import 'from_sqlite.dart';

abstract class TaskData {
  Future<void> clean();
  Future<List<Task>> fetchTasks(bool important, bool urgent);
  Future<Task> addTask(Task task);
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

abstract class SubTaskData {
  Future<void> cleanSubTasks(String parentID);
  Future<List<SubTask>> fetchSubTasks(String parentID);
  Future<SubTask> addSubTask(SubTask task);
  Future<SubTask> updateSubTask(SubTask task);
  Future<void> updateSubTaskSort(Map<String, int> data);
  Future deleteSubTask(SubTask task);
}

SubTaskData getSubTaskData() {
  return SqliteData();
}
