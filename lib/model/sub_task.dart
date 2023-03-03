import 'package:flutter/material.dart';

import '../event/event_bus.dart';

class SubTask {
  String id;
  String parentID;
  String title;
  bool isDone;

  SubTask({
    this.id = "",
    this.title = "",
    this.isDone = false,
    this.parentID = "",
  });

  void toggleDone() {
    isDone = !isDone;
  }

  SubTask copyWith({
    String? title,
    bool? isDone,
    String? id,
    String? parentID,
  }) {
    return SubTask(
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
      id: id ?? this.id,
      parentID: parentID ?? this.parentID,
    );
  }

  factory SubTask.fromJson(Map<String, dynamic> json) {
    return SubTask(
      id: json['id'],
      title: json['title'],
      isDone: json['is_done'],
      parentID: json['parent_id'],
    );
  }

  factory SubTask.fromSqlite(Map<String, dynamic> json) {
    return SubTask(
      id: json['id'],
      title: json['title'],
      isDone: json['is_done'] == 1 ? true : false,
      parentID: json['parent_id'],
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'is_done': isDone,
        'id': id,
        'parent_id': parentID,
      };

  Map<String, dynamic> toSqlite() => {
        'title': title,
        'is_done': isDone ? 1 : 0,
        'id': id,
        'parent_id': parentID,
      };
}

class SubTaskAction extends StatefulWidget {
  final SubTask task;
  final FocusNode? focusNode;
  final Function(SubTask) onTaskUpdated;
  final Function(SubTask) onTaskDeleted;

  const SubTaskAction({
    Key? key,
    required this.task,
    required this.onTaskUpdated,
    required this.onTaskDeleted,
    this.focusNode,
  }) : super(key: key);

  @override
  _SubTaskActionState createState() => _SubTaskActionState();
}

class _SubTaskActionState extends State<SubTaskAction> {
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

  Widget _showTask() {
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
    return _isEditing ? _editTask() : _showTask();
  }
}
