import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

class Task {
  String title;
  bool isDone;

  Task({required this.title, this.isDone = false});

  void toggleDone() {
    isDone = !isDone;
  }

  // void updateTitle(String newTitle) {
  //   final task =
  //       Provider.of<TaskData>(context, listen: false).tasks[widget.index];
  //   task.setTitle(newTitle);
  //   Provider.of<TaskData>(context, listen: false).updateTask(task);
  // }
}
