import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'task.dart';
import 'task_data.dart';

class TaskScreen extends StatefulWidget {
  final Task? task;
  final bool isEditing;

  TaskScreen({this.task, required this.isEditing});

  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  late TextEditingController _titleController;
  late bool _isCompleted;

  @override
  void initState() {
    super.initState();

    if (widget.isEditing) {
      _titleController = TextEditingController(text: widget.task!.title);
      _isCompleted = widget.task!.isDone;
    } else {
      _titleController = TextEditingController();
      _isCompleted = false;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Add a New Task'),
        ),
        body: Container(
          color: Color(0xFF757575),
          child: Container(
            padding: EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.isEditing ? 'Edit Task' : 'Add Task',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30.0,
                    color: Colors.lightBlueAccent,
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                TextField(
                  autofocus: true,
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: 'Enter task title',
                  ),
                  onChanged: (value) {
                    setState(() {
                      // Update the state whenever the text field changes
                    });
                  },
                ),
                SizedBox(
                  height: 20.0,
                ),
                CheckboxListTile(
                  title: Text('Completed'),
                  value: _isCompleted,
                  onChanged: (value) {
                    setState(() {
                      _isCompleted = value!;
                    });
                  },
                ),
                SizedBox(
                  height: 20.0,
                ),
                ElevatedButton(
                  onPressed: () {
                    if (widget.isEditing) {
                      Task? task = widget.task;
                      task!.title = _titleController.text;
                      task.isDone = _isCompleted;
                      Provider.of<TaskData>(context, listen: false).updateTask(task);
                    } else {
                      Provider.of<TaskData>(context, listen: false)
                          .addTask(_titleController.text);
                    }
                    Navigator.pop(context);
                  },
                  child: Text(widget.isEditing ? 'Save Changes' : 'Add'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.lightBlueAccent,
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}