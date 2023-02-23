import 'package:flutter/material.dart';

class Task {
  String title;
  bool isDone;
  String id;
  bool isImportant;
  bool isUrgent;

  Task({required this.title, this.isDone = false, required this.id, this.isImportant = false, this.isUrgent = false});

  void toggleDone() {
    isDone = !isDone;
  }

  Task copyWith({
    String? title,
    bool? isDone,
    String? id,
    bool? isImportant,
    bool? isUrgent,
  }) {
    return Task(
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
      id: id ?? this.id,
      isImportant: isImportant ?? this.isDone,
    );
  }

  @override
  bool operator ==(Object other) => identical(this, other) ||
  other is Task && 
    runtimeType == other.runtimeType &&
    id == other.id;

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      isDone: json['is_done'],
      isImportant: json['is_important'],
      isUrgent: json['is_urgent'],
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'is_done': isDone,
    'is_important': isImportant,
    'is_urgent': isUrgent,
    'id': id,
  };
}


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
  late FocusNode _focusNode;
  late TextEditingController _textEditingController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController(text: widget.task.title);
    _focusNode = widget.focusNode ?? FocusNode();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  void _toggleEditing() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _updateTask(String newTitle) {
    setState(() {
      widget.onTaskUpdated(widget.task.copyWith(title: newTitle));
    });
    _toggleEditing();
  }

  void _deleteTask() {
    widget.onTaskDeleted(widget.task);
  }

  Widget _buildTaskRow() {
    return GestureDetector(
      onTap: () {
        _toggleEditing();
      },
      child: Row(
        children: [
          Checkbox(
            value: widget.task.isDone,
            onChanged: (value) {
              setState(() {
                widget.task.isDone = value!;
                widget.onTaskUpdated(widget.task);
              });
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
            icon: Icon(Icons.delete),
            onPressed: _deleteTask,
          ),
        ],
      ),
    );
  }

  Widget _buildTaskField() {
    return TextFormField(
      controller: _textEditingController,
      autofocus: true,
      decoration: InputDecoration(
        hintText: 'Add a task',
      ),
      onFieldSubmitted: (value) {
        _updateTask(value);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _isEditing ? _buildTaskField() : _buildTaskRow();
  }
}
