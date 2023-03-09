import 'package:best_todo/db/task_data.dart';
import 'package:best_todo/model/task.dart';
import 'package:best_todo/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_reorderable_list/flutter_reorderable_list.dart';

import 'task_page.dart';
import 'task_block.dart';

class MainTaskItem extends StatefulWidget {
  Task task;
  final Function(Task) onTaskDeleted;

  MainTaskItem({
    Key? key,
    required this.task,
    required this.onTaskDeleted,
  }) : super(key: key);

  @override
  _MainTaskItemState createState() => _MainTaskItemState();
}

class _MainTaskItemState extends State<MainTaskItem> {
  late Color? bgColor;
  late Color? secondColor;
  late TextEditingController _titleEditingController;
  late TextEditingController _detailEditingController;
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _titleEditingController = TextEditingController(text: widget.task.title);
    _detailEditingController = TextEditingController(text: widget.task.detail);
    bgColor =
        context.findAncestorWidgetOfExactType<TaskBlock>()?.backgroundColor;
    secondColor =
        context.findAncestorWidgetOfExactType<TaskBlock>()?.taskListColor;
  }

  @override
  void dispose() {
    _titleEditingController.dispose();
    _detailEditingController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  void _updateTask(BuildContext context) {
    getTaskData()
        .updateTask(widget.task.copyWith(title: _titleEditingController.text))
        .then((task) {
      Navigator.of(context).pop();
      setState(() {
        widget.task = task;
      });
    });
  }

  void _updateDetail(BuildContext context) {
    getTaskData()
        .updateTask(widget.task.copyWith(detail: _detailEditingController.text))
        .then((task) {
      Navigator.of(context).pop();
      setState(() {
        widget.task = task;
      });
    });
  }

  void _toggleDone(bool isDone) {
    getTaskData().updateTask(widget.task.copyWith(isDone: isDone)).then((task) {
      setState(() {
        widget.task = task;
      });
    });
  }

  void _deleteTask() {
    getTaskData().deleteTask(widget.task).then((task) {
      widget.onTaskDeleted(widget.task);
    });
  }

  void _showUpdate() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return RawKeyboardListener(
              focusNode: focusNode,
              onKey: (event) {
                if (event.logicalKey == LogicalKeyboardKey.enter) {
                  _updateTask(context);
                }
              },
              child: AlertDialog(
                  title: const Text('修改任务',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      )),
                  backgroundColor: bgColor?.withOpacity(0.9),
                  content: SingleChildScrollView(
                    child: TextField(
                      autofocus: true,
                      controller: _titleEditingController,
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
                        _updateTask(context);
                      },
                    ),
                  ]));
        });
  }

  void _showDetail() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return RawKeyboardListener(
              focusNode: focusNode,
              onKey: (event) {
                if (event.logicalKey == LogicalKeyboardKey.enter) {
                  _updateDetail(context);
                }
              },
              child: AlertDialog(
                title: const Text("详细信息"),
                backgroundColor: bgColor?.withOpacity(0.9),
                content: SingleChildScrollView(
                    child: TextField(
                  autofocus: true,
                  controller: _detailEditingController,
                )),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () {
                      onCopy(context, widget.task.detail);
                    },
                    tooltip: '复制内容',
                  ),
                  IconButton(
                    icon: const Icon(Icons.cancel),
                    tooltip: "取消",
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.check_circle),
                    tooltip: "确认",
                    onPressed: () {
                      _updateDetail(context);
                    },
                  ),
                ],
              ));
        });
  }

  void _showSubTasks(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskPage(
          parent: widget.task,
        ),
      ),
    );
  }

  Widget _buildChild(BuildContext context, ReorderableItemState state) {
    Widget content = SafeArea(
        top: false,
        bottom: false,
        child: Opacity(
          // hide content for placeholder
          opacity: state == ReorderableItemState.placeholder ? 0.0 : 1.0,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Checkbox(
                  value: widget.task.isDone,
                  onChanged: (value) {
                    _toggleDone(value!);
                  },
                ),
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14.0),
                  child: Text(
                    widget.task.title,
                    style: TextStyle(
                      decoration: widget.task.isDone
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                )),
                IconButton(
                    onPressed: _showUpdate, icon: const Icon(Icons.edit)),
                IconButton(
                    onPressed: _showDetail, icon: const Icon(Icons.info)),
                IconButton(
                    onPressed: () {
                      _showSubTasks(context);
                    },
                    icon: const Icon(Icons.expand)),
                ReorderableListener(
                  child: Container(
                    child: const Center(
                      child: Icon(Icons.reorder),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: _deleteTask,
                ),
              ],
            ),
          ),
        ));

    return content;
  }

  @override
  Widget build(BuildContext context) {
    return ReorderableItem(
        key: ValueKey(widget.task.id), //
        childBuilder: _buildChild);
  }
}

class MainTaskItemShadow extends StatelessWidget {
  Task task;

  MainTaskItemShadow({
    Key? key,
    required this.task,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Checkbox(
            value: task.isDone,
            onChanged: (value) {},
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14.0),
              child: Text(
                task.title,
                style: TextStyle(
                  decoration: task.isDone ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
          ),
          Icon(Icons.edit),
          Icon(Icons.info),
          Icon(Icons.expand),
          Icon(Icons.reorder),
          Icon(Icons.delete),
        ],
      ),
    );
  }
}
