import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart' hide ReorderableList;
import 'package:flutter_reorderable_list/flutter_reorderable_list.dart'
    as reorder;

import 'package:best_todo/db/task_data.dart';
import 'package:best_todo/model/sub_task.dart';
import 'sub_task_item.dart';

class SubTaskPage extends StatefulWidget {
  final String parentID;
  final Color? backgroundColor;
  final Color? taskListColor;
  final String title;

  const SubTaskPage(
      {super.key,
      required this.parentID,
      required this.title,
      required this.taskListColor,
      required this.backgroundColor});

  @override
  SubTaskState createState() => SubTaskState();
}

class SubTaskState extends State<SubTaskPage> with TickerProviderStateMixin {
  late String title;
  late final SubTaskData _taskData;
  FocusNode focusNode = FocusNode();

  final _scrollController = ScrollController();
  final _textEditingController = TextEditingController();
  final _notifier = ValueNotifier(0);

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    title = widget.title;
    _taskData = getSubTaskData();
  }

  void onClean() {
    getSubTaskData().cleanSubTasks(widget.parentID).then((value) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          backgroundColor: widget.backgroundColor,
          actions: [
            IconButton(icon: const Icon(Icons.add), onPressed: _addArea),
            IconButton(
              icon: const Icon(Icons.cleaning_services_outlined),
              onPressed: onClean,
            ),
          ],
        ),
        body: Container(
            margin: EdgeInsets.all(16),
            color: widget.backgroundColor,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  mainArea(),
                ])));
  }

  void onTaskDelete(SubTask task) {
    setState(() {
      _taskData.deleteSubTask(task);
    });
  }

  void onTaskUpdate(SubTask task) {
    setState(() {
      _taskData.updateSubTask(task);
    });
  }

  void onTaskAdd(BuildContext context) {
    String title = _textEditingController.text;
    _textEditingController.clear();
    _taskData
        .addSubTask(SubTask(title: title, parentID: widget.parentID))
        .then((value) {
      setState(() {
        Navigator.of(context).pop();
      });
    });
  }

  void updateSort(List<SubTask> tasks) {
    Map<String, int> rst = {};
    for (var task in tasks) {
      rst[task.id] = task.sort;
    }

    setState(() {
      _taskData.updateSubTaskSort(rst);
    });
  }

  // 任务列表主体
  Widget mainArea() {
    return Expanded(
        child: Container(
            decoration: BoxDecoration(
              color: widget.taskListColor,
            ),
            child: FutureBuilder<List<SubTask>>(
                future: _taskData.fetchSubTasks(widget.parentID),
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
                  List<SubTask> tasks = snapshot.data!;
                  if (tasks.isEmpty) {
                    return const Center(child: Text("尚未设置子任务"));
                  }

                  return ValueListenableBuilder(
                    valueListenable: _notifier,
                    builder: (context, value, child) {
                      return reorder.ReorderableList(
                        child: CustomScrollView(
                          slivers: <Widget>[
                            SliverPadding(
                                padding: EdgeInsets.only(
                                    bottom:
                                        MediaQuery.of(context).padding.bottom),
                                sliver: SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    (BuildContext context, int index) {
                                      return SubTaskItem(
                                          key: ValueKey(tasks[index].id),
                                          task: tasks[index],
                                          onTaskUpdated: onTaskUpdate,
                                          onTaskDeleted: onTaskDelete,
                                          isFirst: index == 0,
                                          isLast: index == tasks.length - 1);
                                    },
                                    childCount: tasks.length,
                                  ),
                                )),
                          ],
                        ),
                        onReorder: (draggedItem, newPosition) {
                          List<SubTask> tasks = snapshot.data!;
                          int oldIndex = tasks.indexWhere(
                              (task) => task.getKey() == draggedItem);
                          int newIndex = tasks.indexWhere(
                              (task) => task.getKey() == newPosition);
                          final task1 = tasks[oldIndex];
                          final task2 = tasks[newIndex];
                          final sort1 = task1.sort;
                          task1.sort = task2.sort;
                          task2.sort = sort1;

                          snapshot.data![oldIndex] = task2;
                          snapshot.data![newIndex] = task1;
                          _notifier.value += 1; // 通知刷新

                          return true;
                        },
                        onReorderDone: (draggedItem) {
                          List<SubTask> tasks = snapshot.data!;
                          updateSort(tasks);
                        },
                      );
                    },
                  );
                })));
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
                title: const Text('添加子任务',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    )),
                backgroundColor: widget.backgroundColor?.withOpacity(0.9),
                content: SingleChildScrollView(
                    child: TextField(
                  autofocus: true,
                  controller: _textEditingController,
                  decoration: const InputDecoration(
                    // fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    hintText: '请描述子任务...',
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
        });
  }
}
