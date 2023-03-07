import 'package:flutter/material.dart';

import 'package:best_todo/model/sub_task.dart';
import 'package:flutter_reorderable_list/flutter_reorderable_list.dart';

class SubTaskItem extends StatefulWidget {
  SubTask task;
  final Function(SubTask) onTaskUpdated;
  final Function(SubTask) onTaskDeleted;

  SubTaskItem({
    super.key,
    required this.task,
    required this.onTaskDeleted,
    required this.onTaskUpdated,
  });

  @override
  SubTaskItemState createState() => SubTaskItemState();
}

class SubTaskItemState extends State<SubTaskItem> {
  late TextEditingController _textEditingController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController(text: widget.task.title);
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

  Widget _buildChild(BuildContext context, ReorderableItemState state) {
    Widget content = Container(
      child: SafeArea(
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
                    padding: const EdgeInsets.symmetric(
                        vertical: 14.0, horizontal: 14.0),
                    child: Text(
                      widget.task.title,
                      style: TextStyle(
                        decoration: widget.task.isDone
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                  )),
                  ReorderableListener(
                    child: Container(
                      // padding: const EdgeInsets.only(right: 18.0, left: 18.0),
                      // color: const Color(0x08000000),
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
          )),
    );

    // For android dragging mode, wrap the entire content in DelayedReorderableListener
    // if (draggingMode == DraggingMode.android) {
    //   content = DelayedReorderableListener(
    //     child: content,
    //   );
    // }

    return content;
  }

  @override
  Widget build(BuildContext context) {
    return ReorderableItem(
        key: ValueKey(widget.task.id), //
        childBuilder: _buildChild);
  }
}
