import 'dart:async';

import 'package:flutter/material.dart';
import 'task_data.dart';
import 'task.dart';

class FocusMatrix extends StatefulWidget {
  @override
  _FocusMatrixState createState() => _FocusMatrixState();
}

class _FocusMatrixState extends State<FocusMatrix> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Focus Matrix'),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TaskList(
                      backgroundColor: Color.fromARGB(255, 246, 148, 129),
                      taskListColor: Color.fromARGB(255, 187, 152, 145),
                      important: true,
                      urgent: true),
                  TaskList(
                      backgroundColor: Color.fromARGB(211, 139, 207, 93),
                      taskListColor: Color.fromARGB(211, 192, 237, 162),
                      important: true,
                      urgent: false),
                ],
              ),
            ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TaskList(
                      backgroundColor: Color.fromARGB(255, 92, 199, 249),
                      taskListColor: Color.fromARGB(255, 161, 205, 226),
                      important: false,
                      urgent: true),
                  TaskList(
                      backgroundColor: Color.fromARGB(255, 158, 160, 158),
                      taskListColor: Color.fromARGB(255, 191, 193, 191),
                      important: false,
                      urgent: false),
                ],
              ),
            ),
          ],
        ));
  }
}

class TaskList extends StatefulWidget {
  final Color backgroundColor;
  final Color taskListColor;
  final bool important;
  final bool urgent;
  // late List<Task> tasks;

  TaskList({
    required this.backgroundColor,
    required this.taskListColor,
    required this.important,
    required this.urgent,
  });

  String getTitle() {
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
  _TaskListState createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  late String title;

  final _scrollController = ScrollController();
  TextEditingController _textEditingController = TextEditingController();

  late final TaskData _taskData;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    title = widget.getTitle();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Container(
            margin: EdgeInsets.all(16),
            color: widget.backgroundColor,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  header(),
                  mainArea(),
                ])));
  }

  void onTaskDelete(Task task) {
    setState(() {
      _taskData.deleteTask(task);
    });
  }

  void onTaskUpdate(Task task) {
    setState(() {
      _taskData.updateTask(task);
    });
  }

  void onTaskadd(String title) {
    setState(() {
      _taskData.addTask(Task(
          title: title,
          isImportant: widget.important,
          isUrgent: widget.urgent));
    });
  }

  // 象限title
  Widget header() {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(16),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          IconButton(icon: Icon(Icons.add), onPressed: _addArea), // 添加任务按钮
        ]);
  }

  // 任务列表主体
  Widget mainArea() {
    return Expanded(
        child: Container(
            decoration: BoxDecoration(
              color: widget.taskListColor,
            ),
            child: FutureBuilder<List<Task>>(
                future: _taskData.fetchTasks(widget.important, widget.urgent),
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
                  List<Task> tasks = snapshot.data!;
                  return ListView.builder(
                      controller: _scrollController,
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        return TaskAction(
                            task: tasks[index],
                            onTaskUpdated: onTaskUpdate,
                            onTaskDeleted: onTaskDelete);
                      });
                })));
  }

  // 添加任务弹窗
  void _addArea() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('添加任务'),
          content: TextField(
            controller: _textEditingController,
            decoration: const InputDecoration(
              hintText: '输入任务',
            ),
          ),
          actions: [
            TextButton(
              child: const Text('取消'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('完成'),
              onPressed: () {
                String title = _textEditingController.text;
                onTaskadd(title);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
