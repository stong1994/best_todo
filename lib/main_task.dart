import 'package:best_todo/utils/utils.dart';
import 'package:flutter/material.dart';

import 'best_todo.dart';
import 'event/event_bus.dart';
import 'model/task.dart';
import 'sub_task.dart';

class TaskAction extends StatefulWidget {
  final Task task;
  final FocusNode? focusNode;
  final Function(Task) onTaskUpdated;
  final Function(Task) onTaskDeleted;

  const TaskAction({
    Key? key,
    required this.task,
    required this.onTaskUpdated,
    required this.onTaskDeleted,
    this.focusNode,
  }) : super(key: key);

  @override
  _TaskActionState createState() => _TaskActionState();
}

class _TaskActionState extends State<TaskAction> {
  late Color? bgColor;
  late Color? secondColor;
  late TextEditingController _titleEditingController;
  late TextEditingController _detailEditingController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _titleEditingController = TextEditingController(text: widget.task.title);
    _detailEditingController = TextEditingController(text: widget.task.detail);
    bgColor =
        context.findAncestorWidgetOfExactType<TaskList>()?.backgroundColor;
    secondColor =
        context.findAncestorWidgetOfExactType<TaskList>()?.taskListColor;
    eventBus.on<int>().listen((hashCode) {
      onOtherTaskEditing(hashCode);
    });
  }

  @override
  void dispose() {
    _titleEditingController.dispose();
    _detailEditingController.dispose();
    super.dispose();
  }

  onOtherTaskEditing(int hashCode) {
    if (widget.hashCode != hashCode && _isEditing) {
      _toggleEditing();
    }
  }

  void _toggleEditing() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _updateTask(String newTitle) {
    widget.onTaskUpdated(widget.task.copyWith(title: newTitle));
    _toggleEditing();
  }

  void _updateDetail(String newDetail) {
    widget.onTaskUpdated(widget.task.copyWith(detail: newDetail));
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
          return AlertDialog(
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
                  String title = _titleEditingController.text;
                  _updateTask(title);
                  _titleEditingController.clear();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  void _showDetail() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
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
                  _updateDetail(_detailEditingController.text);
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
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
      onTap: () {
        _toggleEditing();
        eventBus.fire(widget.hashCode);
      },
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
