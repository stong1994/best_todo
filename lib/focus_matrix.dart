import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'task_data.dart';
import 'task.dart';
import 'custom_task_card.dart';
import 'task_screen.dart';

class FocusMatrix extends StatefulWidget {
  @override
  _FocusMatrixState createState() => _FocusMatrixState();
}

class _FocusMatrixState extends State<FocusMatrix> {
  final TextEditingController _addTaskController = TextEditingController();

  @override
  void dispose() {
    _addTaskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Focus Matrix'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Container(
                    color: Colors.red,
                    child: TaskList(
                      important: true,
                      urgent: true,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    color: Colors.yellow,
                    child: TaskList(
                      important: true,
                      urgent: false,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Container(
                    color: Colors.lightBlueAccent,
                    child: TaskList(
                      important: false,
                      urgent: true,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    color: Colors.green,
                    child: TaskList(
                      important: false,
                      urgent: false,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return Container(
                color: Color(0xff757575),
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Add New Task',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.lightBlueAccent,
                          fontSize: 30,
                        ),
                      ),
                      TextField(
                        autofocus: true,
                        textAlign: TextAlign.center,
                        controller: _addTaskController,
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          Provider.of<TaskData>(context, listen: false)
                              .addTask(_addTaskController.text);
                          Navigator.pop(context);
                        },
                        child: Text('Add'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class TaskList extends StatefulWidget {
  final bool important;
  final bool urgent;

  TaskList({required this.important, required this.urgent});

  @override
  _TaskListState createState() => _TaskListState(title: this.getTitle());

  String getTitle() {
    if (this.important && this.urgent) {
      return "重要&紧急";
    } else if (this.important && !this.urgent) {
      return "重要&不紧急";
    } else if (!this.important && this.urgent) {
      return "不重要&紧急";
    } else {
      return "不重要&不紧急";
    }
  }
}

class _TaskListState extends State<TaskList> {
  final String title;
  late List<Task> tasks;

  _TaskListState({required this.title});

  @override
  void initState() {
    super.initState();
    tasks = context.read<TaskData>().tasks;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
              fontSize: 30.0,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          Expanded(
            child: Consumer<TaskData>(builder: (context, taskData, child) {
            ScrollController _scrollController = ScrollController();
            return ListView.builder(
              controller: _scrollController,
              itemCount: taskData.taskCount,
              itemBuilder: (context, index) {
                final task = taskData.tasks[index];
                return CustomTaskCard(
                  // key: Key(task.id),
                  task: task,
                  toggleCheckbox: (bool? checkboxState) {
                    setState(() {
                      task.toggleDone();
                    });
                  },
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => TaskScreen(
                                task: task,
                                isEditing: false,
                              )),
                    );
                  },
                );
              },
            );
          }))
        ]);
  }
}
