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

  @override
  _TaskListState createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  late String title;

  final _scrollController = ScrollController();
  late final TaskData _taskData;
  late Future<List<Task>> _tasks;

  @override
  void dispose() {
    super.dispose();
  }

  // Timer(Duration(milliseconds: 50), () {
  //   _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  //   FocusScope.of(context).requestFocus(_focusNode);

  // });

  @override
  void initState() {
    super.initState();
    title = getTitle();
    _taskData = TaskData();
    _tasks = _taskData.fetchTasks();
    // taskDataRepository = TaskData(provider: taskDataProvider);
  }

  String getTitle() {
    if (widget.important && widget.urgent) {
      return "重要&紧急";
    } else if (widget.important && !widget.urgent) {
      return "重要&不紧急";
    } else if (!widget.important && widget.urgent) {
      return "不重要&紧急";
    } else {
      return "不重要&不紧急";
    }
  }

  void onTaskDelete(Task task) {
    // widget.onTaskDelete(task);
    setState(() {
      _taskData.deleteTask(task);
      _tasks = _taskData.getTasksFromMem();
    });
  }

  void onTaskUpdate(Task task) {
    setState(() {
      if (task.id == "") {
        _taskData.addTask(task);
      } else {
        _taskData.updateTask(task);
      }
      _tasks = _taskData.getTasksFromMem();
    });
  }

  void _addTask() {
    setState(() {
      _tasks.then((tasks) {
        tasks.add(Task(isImportant: widget.important, isUrgent: widget.urgent));
        Future.delayed(Duration(milliseconds: 300), () {
          final index = tasks.length - 1;
          final scrollPosition = _scrollController.position;

          _scrollController.animateTo(
            scrollPosition.maxScrollExtent,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );

          final focusNode = FocusNode();
          FocusScope.of(context).requestFocus(focusNode);
          WidgetsBinding.instance!.addPostFrameCallback((_) {
            focusNode.requestFocus();
          });
        });
        return tasks;
      });
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
          IconButton(icon: Icon(Icons.add), onPressed: _addTask), // 添加任务按钮
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
                future: _tasks,
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
}
