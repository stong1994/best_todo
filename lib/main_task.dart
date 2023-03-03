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
  late TextEditingController _textEditingController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController(text: widget.task.title);
    eventBus.on<int>().listen((hashCode) {
      onOtherTaskEditing(hashCode);
    });
  }

  @override
  void dispose() {
    _textEditingController.dispose();
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

  void _toggleDone(bool isDone) {
    widget.onTaskUpdated(widget.task.copyWith(isDone: isDone));
  }

  void _deleteTask() {
    widget.onTaskDeleted(widget.task);
  }

  void _showSubTasks(BuildContext context) {
    final bgColor =
        context.findAncestorWidgetOfExactType<TaskList>()?.backgroundColor;
    final listColor =
        context.findAncestorWidgetOfExactType<TaskList>()?.taskListColor;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubTaskPage(
          parentID: widget.task.id,
          title: widget.task.title,
          backgroundColor: bgColor,
          taskListColor: listColor,
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

  Widget _editTask() {
    return TextFormField(
      controller: _textEditingController,
      autofocus: true,
      style: TextStyle(fontSize: 18.0, color: Colors.black87),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 15.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(
            width: 0.8,
            color: Colors.grey.shade400,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(
            width: 0.8,
            color: Colors.grey.shade400,
          ),
        ),
      ),
      onFieldSubmitted: (value) {
        _updateTask(value);
        _textEditingController.clear();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _isEditing ? _editTask() : _showTask(context);
  }
}
