import 'package:best_todo/db/task_data.dart';
import 'package:best_todo/model/task.dart';
import 'task_block.dart';
import 'package:flutter/material.dart';

class MainTaskPage extends StatefulWidget {
  final Task parent;

  MainTaskPage({super.key, required this.parent});

  @override
  _MainTaskPageState createState() => _MainTaskPageState();
}

class _MainTaskPageState extends State<MainTaskPage> {
  void onClean() {
    getTaskData().clean().then((value) {
      setState(() {});
    });
  }

  GetTaskFunc getTasks(bool important, bool urgent) {
    return () async {
      return await getTaskData()
          .getSubTasks(widget.parent.id, important, urgent);
    };
  }

  AddTaskFunc addTask(bool important, bool urgent) {
    return (String title) async {
      return await getTaskData().addTask(Task(
        parentID: widget.parent.id,
        isImportant: important,
        isUrgent: urgent,
        title: title,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: widget.parent.id == rootParentID
              ? Container()
              : Text(widget.parent.title),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.cleaning_services_outlined),
              onPressed: onClean,
            ),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TaskBlock(
                      backgroundColor: Color.fromARGB(255, 246, 148, 129),
                      taskListColor: Color.fromARGB(255, 187, 152, 145),
                      getTasks: getTasks(true, true),
                      title: getTitle(true, true),
                      important: true,
                      urgent: true,
                      addTask: addTask(true, true)),
                  TaskBlock(
                      backgroundColor: Color.fromARGB(211, 139, 207, 93),
                      taskListColor: Color.fromARGB(211, 192, 237, 162),
                      getTasks: getTasks(true, false),
                      title: getTitle(true, false),
                      important: true,
                      urgent: false,
                      addTask: addTask(true, false)),
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
                      getTasks: getTasks(false, true),
                      title: getTitle(false, true),
                      important: false,
                      urgent: true,
                      addTask: addTask(false, true)),
                  TaskBlock(
                      backgroundColor: Color.fromARGB(255, 158, 160, 158),
                      taskListColor: Color.fromARGB(255, 191, 193, 191),
                      getTasks: getTasks(false, false),
                      title: getTitle(false, false),
                      important: false,
                      urgent: false,
                      addTask: addTask(false, false)),
                ],
              ),
            ),
          ],
        ));
  }
}
