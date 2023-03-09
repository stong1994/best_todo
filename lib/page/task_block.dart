import 'package:best_todo/db/task_data.dart';
import 'package:best_todo/model/task.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_reorderable_list/flutter_reorderable_list.dart'
    as reorder;

import 'task_item.dart';

typedef GetTaskFunc = Future<List<Task>> Function();
typedef AddTaskFunc = Future<Task> Function(String title);

class TaskBlock extends StatefulWidget {
  final Color backgroundColor;
  final Color taskListColor;
  final String title;
  final bool important;
  final bool urgent;
  final GetTaskFunc getTasks;
  final AddTaskFunc addTask;

  TaskBlock({
    required this.backgroundColor,
    required this.taskListColor,
    required this.title,
    required this.important,
    required this.urgent,
    required this.getTasks,
    required this.addTask,
  });

  @override
  _TaskBlockState createState() => _TaskBlockState();
}

class _TaskBlockState extends State<TaskBlock> {
  late final TaskData _taskData;

  final _textEditingController = TextEditingController();
  FocusNode focusNode = FocusNode();
  final _notifier = ValueNotifier(0);

  @override
  void dispose() {
    focusNode.dispose();
    _notifier.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _taskData = getTaskData();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        color: widget.backgroundColor,
        child: DragTarget(
          builder: (BuildContext context, List<Task?> candidateData,
              List<dynamic> rejectedData) {
            return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  header(),
                  Expanded(
                    child: mainArea(),
                  ),
                ]);
          },
          onAccept: (Task task) {
            updateTaskAttr(task);
          },
        ),
      ),
    );
  }

  void onTaskDelete(Task task) {
    setState(() {});
  }

  void onTaskAdd(BuildContext context) {
    String title = _textEditingController.text;
    _textEditingController.clear();
    widget.addTask(title).then((_) {
      setState(() {
        Navigator.of(context).pop();
      });
    });
  }

  void updateSort(List<Task> tasks) {
    Map<String, int> rst = {};
    for (var task in tasks) {
      rst[task.id] = task.sort;
    }
    _taskData.updateTaskSort(rst).then((value) {
      setState(() {});
    });
  }

  void updateTaskAttr(Task task) {
    task.isImportant = widget.important;
    task.isUrgent = widget.urgent;
    _taskData.updateTaskBlock(task).then((value) {
      setState(() {});
    });
  }

  // 象限header
  Widget header() {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(16),
            child: Text(
              widget.title,
              style: const TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          IconButton(
              icon: const Icon(Icons.add), onPressed: _addArea), // 添加任务按钮
        ]);
  }

  // 任务列表主体
  Widget mainArea() {
    return Container(
        padding: EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: widget.taskListColor,
        ),
        child: FutureBuilder<List<Task>>(
            future: widget.getTasks(),
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
              return ValueListenableBuilder(
                valueListenable: _notifier,
                builder: (BuildContext context, int _, Widget? __) {
                  return reorder.ReorderableList(
                    child: ListView(
                      // itemExtent: 50,
                      children: List.generate(
                          snapshot.data!.length,
                          (index) => Draggable<Task>(
                              onDragCompleted: () {
                                setState(() {});
                              },
                              // childWhenDragging: // todo not work
                              feedback: Material(
                                  child: MainTaskItemShadow(
                                key: snapshot.data![index].getKey(),
                                task: snapshot.data![index],
                              )),
                              data: snapshot.data![index],
                              child: MainTaskItem(
                                  key: snapshot.data![index].getKey(),
                                  task: snapshot.data![index],
                                  onTaskDeleted: onTaskDelete))),
                    ),
                    onReorder: (draggedItem, newPosition) {
                      return _onRecordSort(snapshot, draggedItem, newPosition);
                    },
                    onReorderDone: (draggedItem) {
                      List<Task> tasks = snapshot.data!;
                      updateSort(tasks);
                    },
                  );
                },
              );
            }));
  }

  bool _onRecordSort(
      AsyncSnapshot<List<Task>> snapshot, Key draggedItem, Key newPosition) {
    List<Task> tasks = snapshot.data!;
    int oldIndex = tasks.indexWhere((task) => task.getKey() == draggedItem);
    int newIndex = tasks.indexWhere((task) => task.getKey() == newPosition);
    final task1 = tasks[oldIndex];
    final task2 = tasks[newIndex];
    final sort1 = task1.sort;
    task1.sort = task2.sort;
    task2.sort = sort1;

    snapshot.data![oldIndex] = task2;
    snapshot.data![newIndex] = task1;
    _notifier.value += 1; // 通知刷新

    return true;
  }

  // 添加任务弹窗
  void _addArea() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return RawKeyboardListener(
            focusNode: focusNode,
            onKey: (event) {
              if (event.logicalKey == LogicalKeyboardKey.enter) {
                onTaskAdd(context);
              }
            },
            child: AlertDialog(
              title: const Text('添加任务',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  )),
              backgroundColor: widget.backgroundColor.withOpacity(0.9),
              content: SingleChildScrollView(
                  child: TextField(
                autofocus: true,
                controller: _textEditingController,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  hintText: '请描述任务...',
                  hintStyle: TextStyle(
                    color: Color.fromARGB(255, 235, 186, 186),
                    fontSize: 16,
                  ),
                  border: UnderlineInputBorder(),
                ),
              )),
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
                    onTaskAdd(context);
                  },
                ),
              ],
            ));
      },
    );
  }
}
