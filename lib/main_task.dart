import 'package:best_todo/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'best_todo.dart';
import 'model/task.dart';
import 'sub_task.dart';

class TaskAction extends StatefulWidget {
  final Task task;
  final Function(Task) onTaskUpdated;
  final Function(Task) onTaskDeleted;

  const TaskAction({
    Key? key,
    required this.task,
    required this.onTaskUpdated,
    required this.onTaskDeleted,
  }) : super(key: key);

  @override
  _TaskActionState createState() => _TaskActionState();
}

class _TaskActionState extends State<TaskAction> {
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
        context.findAncestorWidgetOfExactType<TaskList>()?.backgroundColor;
    secondColor =
        context.findAncestorWidgetOfExactType<TaskList>()?.taskListColor;
  }

  @override
  void dispose() {
    _titleEditingController.dispose();
    _detailEditingController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  void _updateTask(BuildContext context) {
    String title = _titleEditingController.text;
    _titleEditingController.clear();
    widget.onTaskUpdated(widget.task.copyWith(title: title));
    Navigator.of(context).pop();
  }

  void _updateDetail(BuildContext context) {
    String detail = _detailEditingController.text;
    _detailEditingController.clear();
    widget.onTaskUpdated(widget.task.copyWith(detail: detail));
    Navigator.of(context).pop();
  }

  void _toggleDone(bool isDone) {
    widget.onTaskUpdated(widget.task.copyWith(isDone: isDone));
  }

  void _deleteTask() {
    widget.onTaskDeleted(widget.task);
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
        builder: (context) => SubTaskPage(
          parentID: widget.task.id,
          title: widget.task.title,
          backgroundColor: bgColor,
          taskListColor: secondColor,
        ),
      ),
    );
  }

  Widget _showTask(BuildContext context) {
    return GestureDetector(
      child: Row(
        children: [
          Checkbox(
            value: widget.task.isDone,
            onChanged: (value) {
              _toggleDone(value!);
            },
          ),
          Expanded(
            child: Text(
              widget.task.title,
              style: TextStyle(
                decoration:
                    widget.task.isDone ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
          IconButton(onPressed: _showUpdate, icon: const Icon(Icons.edit)),
          IconButton(onPressed: _showDetail, icon: const Icon(Icons.info)),
          IconButton(
              onPressed: () {
                _showSubTasks(context);
              },
              icon: const Icon(Icons.expand)),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteTask,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _showTask(context);
  }
}
