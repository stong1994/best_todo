import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'task.dart';
import 'task_data.dart';
import 'task_screen.dart';

class CustomTaskCard extends StatefulWidget {
  final Task task;
  final Function(bool?) onCheckboxChanged;
  // final Function() onTap;
  final Function() onLongPress;

  CustomTaskCard({required this.task, required this.onCheckboxChanged, required this.onLongPress});

  @override
  _CustomTaskCardState createState() => _CustomTaskCardState();
}

class _CustomTaskCardState extends State<CustomTaskCard> {
  void _editTask(BuildContext context, Task task) {
    showModalBottomSheet(
      context: context,
      builder: (context) => TaskScreen(
        task: task,
        isEditing: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        widget.task.title,
        style: TextStyle(
          decoration: widget.task.isDone
              ? TextDecoration.lineThrough
              : TextDecoration.none,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () => _editTask(context, widget.task),
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => Provider.of<TaskData>(context, listen: false).deleteTask(widget.task),
          ),
        ],
      ),
      leading: Checkbox(
        value: widget.task.isDone,
        onChanged: (value) {
          widget.onCheckboxChanged(value);
        },
      ),
      onTap: () {
        // widget.onTap();
      },
      onLongPress: () {
        // todo
      },
    );
  }
}
