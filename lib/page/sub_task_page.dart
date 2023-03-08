import 'package:best_todo/model/task.dart';
import 'package:flutter/material.dart';
import 'package:best_todo/db/task_data.dart';
import 'task_common_page.dart';

class SubTaskPage extends StatefulWidget {
  final String parentID;
  final Color backgroundColor;
  final Color taskListColor;
  final String title;

  final Future<Task> taskFuture;

  GetTaskFunc getTasks() {
    return () async {
      return await getTaskData().getSubTasks(parentID);
    };
  }

  AddTaskFunc addTask(important, urgent) {
    return (String title) async {
      return await getTaskData().addTask(Task(
        isImportant: important,
        isUrgent: urgent,
        parentID: parentID,
        title: title,
      ));
    };
  }

  SubTaskPage({
    super.key,
    required this.parentID,
    required this.title,
    required this.taskListColor,
    required this.backgroundColor,
  }) : taskFuture = getTaskData().getTask(parentID);

  @override
  SubTaskState createState() => SubTaskState();
}

class SubTaskState extends State<SubTaskPage> with TickerProviderStateMixin {
  late String title;
  FocusNode focusNode = FocusNode();

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    title = widget.title;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('子任务列表'),
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder<Task>(
        future: widget.taskFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}}"),
            );
          }
          final task = snapshot.data!;
          return Column(
            children: [
              TaskList(
                title: '父任务：${task.title}',
                backgroundColor: widget.backgroundColor,
                taskListColor: widget.taskListColor,
                important: task.isImportant,
                urgent: task.isUrgent,
                addTask: widget.addTask(task.isImportant, task.isUrgent),
                getTasks: widget.getTasks(),
              )
            ],
          );
        },
      ),
    );
  }
}
