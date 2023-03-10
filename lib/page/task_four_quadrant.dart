import 'package:best_todo/db/task_data.dart';
import 'package:best_todo/model/task.dart';
import 'package:flutter/material.dart';

import 'task_block.dart';

class FourQuadrant extends StatefulWidget {
  final Task parent;

  FourQuadrant({super.key, required this.parent});

  @override
  FourQuadrantState createState() => FourQuadrantState();

  GetTaskFunc getTasks(bool important, bool urgent) {
    return () async {
      return await getTaskData().getSubTasks(
          parent.id,
          important,
          urgent,
          parent.navigatorID == ""
              ? null
              : parent.navigatorID); // todo 临时处理没有navigatorID的老数据
    };
  }

  AddTaskFunc addTask(bool important, bool urgent) {
    return (String title) async {
      return await getTaskData().addTask(Task(
        parentID: parent.id,
        isImportant: important,
        isUrgent: urgent,
        title: title,
        navigatorID: parent.navigatorID,
      ));
    };
  }

  String getTitle(important, urgent) {
    if (important && urgent) {
      return "重要&紧急";
    } else if (important && !urgent) {
      return "重要&不紧急";
    } else if (!important && urgent) {
      return "不重要&紧急";
    } else {
      return "不重要&不紧急";
    }
  }
}

class FourQuadrantState extends State<FourQuadrant> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TaskBlock(
                  backgroundColor: Color.fromARGB(255, 246, 148, 129),
                  taskListColor: Color.fromARGB(255, 187, 152, 145),
                  getTasks: widget.getTasks(true, true),
                  title: widget.getTitle(true, true),
                  important: true,
                  urgent: true,
                  addTask: widget.addTask(true, true)),
              TaskBlock(
                  backgroundColor: Color.fromARGB(211, 139, 207, 93),
                  taskListColor: Color.fromARGB(211, 192, 237, 162),
                  getTasks: widget.getTasks(true, false),
                  title: widget.getTitle(true, false),
                  important: true,
                  urgent: false,
                  addTask: widget.addTask(true, false)),
            ],
          ),
        ),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TaskBlock(
                  backgroundColor: Color.fromARGB(255, 92, 199, 249),
                  taskListColor: Color.fromARGB(255, 161, 205, 226),
                  getTasks: widget.getTasks(false, true),
                  title: widget.getTitle(false, true),
                  important: false,
                  urgent: true,
                  addTask: widget.addTask(false, true)),
              TaskBlock(
                  backgroundColor: Color.fromARGB(255, 158, 160, 158),
                  taskListColor: Color.fromARGB(255, 191, 193, 191),
                  getTasks: widget.getTasks(false, false),
                  title: widget.getTitle(false, false),
                  important: false,
                  urgent: false,
                  addTask: widget.addTask(false, false)),
            ],
          ),
        ),
      ],
    );
  }
}
