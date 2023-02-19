import 'package:flutter/material.dart';

class FocusMatrix extends StatelessWidget {
  final List<CustomTask> importantUrgent;
  final List<CustomTask> importantNotUrgent;
  final List<CustomTask> notImportantUrgent;
  final List<CustomTask> notImportantNotUrgent;
  final Function(dynamic) onPressed;

  FocusMatrix({
    required this.importantUrgent,
    required this.importantNotUrgent,
    required this.notImportantUrgent,
    required this.notImportantNotUrgent,
    required this.onPressed,
  });

  @override
    Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: TaskList(
                    tasks: importantUrgent,
                    title: 'Important & Urgent',
                    color: Colors.red,
                    onPressed: onPressed,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TaskList(
                    tasks: importantNotUrgent,
                    title: 'Important & Not Urgent',
                    color: Colors.yellow,
                    onPressed: onPressed,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: TaskList(
                    tasks: notImportantUrgent,
                    title: 'Not Important & Urgent',
                    color: Colors.blue,
                    onPressed: onPressed,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TaskList(
                    tasks: notImportantNotUrgent,
                    title: 'Not Important & Not Urgent',
                    color: Colors.green,
                    onPressed: onPressed,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TaskList extends StatelessWidget {
  final List<CustomTask> tasks;
  final String title;
  final Color color;
  final Function(dynamic) onPressed;

  TaskList({
    required this.tasks,
    required this.title,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return CustomTaskCard(
                task: task,
                onSubmitted: (newTitle) => task.save(newTitle),
                onDelete: () {
                  tasks.remove(task);
                  onPressed(task);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}



class CustomTask {
  String title;
  bool isEditing = false;

  CustomTask({required this.title});

  void edit() {
    isEditing = true;
  }

  void save(String newTitle) {
    title = newTitle;
    isEditing = false;
  }

  void delete() {
    // TODO: Implement delete functionality
  }
}


class CustomTaskCard extends StatelessWidget {
  final CustomTask task;
  final Function(String) onSubmitted;
  final Function() onDelete;

  CustomTaskCard({
    required this.task,
    required this.onSubmitted,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: task.isEditing
            ? TextFormField(
                initialValue: task.title,
                onFieldSubmitted: onSubmitted,
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(task.title),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: task.edit,
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: onDelete,
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
