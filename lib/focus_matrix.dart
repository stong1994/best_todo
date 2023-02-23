import 'dart:async';

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
                  TaskList(
                      backgroundColor: Color.fromARGB(255, 246, 148, 129),
                      taskListColor: Color.fromARGB(255, 187, 152, 145),
                      important: true,
                      urgent: true),
                  TaskList(
                      backgroundColor: Color.fromARGB(211, 139, 207, 93),
                      taskListColor: Color.fromARGB(211, 192, 237, 162),
                      important: true,
                      urgent: false),
                ],
              ),
            ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TaskList(
                      backgroundColor: Color.fromARGB(255, 92, 199, 249),
                      taskListColor: Color.fromARGB(255, 161, 205, 226),
                      important: false,
                      urgent: true),
                  TaskList(
                      backgroundColor: Color.fromARGB(255, 158, 160, 158),
                      taskListColor: Color.fromARGB(255, 191, 193, 191),
                      important: false,
                      urgent: false),
                ],
              ),
            ),
          ],
        ));
  }
}

// class TaskBlock extends StatelessWidget {
//   final Color backgroundColor;
//   final Color taskListColor;
//   final bool important;
//   final bool urgent;

//   TaskBlock({
//     required this.backgroundColor,
//     required this.taskListColor,
//     required this.important,
//     required this.urgent,
//   });

//   @override
//   Widget build(BuildContext context) {
//     List<Task> tasks = TaskData().getTask(important, urgent);

//     return Expanded(
//       child: Container(
//         margin: EdgeInsets.all(16),
//         color: backgroundColor,
//         child: TaskList(
//           tasks:tasks,
//         ),
//       ),
//     );
//   }
// }

class TaskList extends StatefulWidget {
  final Color backgroundColor;
  final Color taskListColor;
  final bool important;
  final bool urgent;
  // late List<Task> tasks;

  TaskList({
    required this.backgroundColor,
    required this.taskListColor,
    required this.important,
    required this.urgent,
  });

  @override
  _TaskListState createState() => _TaskListState();

  // void onTaskDelete(Task task) {
  //   tasks.remove(task);
  // }

  // void onTaskToggle(Task task) {
  //   task.toggleDone();
  // }

  // void onTaskUpdate(Task task) {
  //   int idx = tasks.indexOf(task);
  //   if (idx >= 0) {
  //     tasks[idx] = task;
  //   }
  // }
}

class _TaskListState extends State<TaskList> {
  late String title;

  late final FocusNode _focusNode;
  final _scrollController = ScrollController();
  List<Widget> taskActions = [];

  late Future<List<Task>> _tasks;

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _addTask() {
    final newTask = Task(title: '', id: '');
    setState(() {
      // widget.tasks.insert(0, newTask);
    });
    final newTaskFocusNode = FocusNode();
    taskActions.add(TaskAction(
        task: newTask,
        onTaskUpdated: onTaskUpdate,
        onTaskDeleted: onTaskDelete,
        focusNode: newTaskFocusNode));
    newTaskFocusNode.requestFocus();
  }
  // Timer(Duration(milliseconds: 50), () {
  //   _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  //   FocusScope.of(context).requestFocus(_focusNode);

  // });

  // Future.delayed(Duration(milliseconds: 300), () {
  //   final index = widget.tasks.length - 1;
  //   // final itemScrollController = ScrollController();
  //   final scrollPosition = _scrollController.position;

  //   _scrollController.animateTo(
  //     scrollPosition.maxScrollExtent,
  //     duration: Duration(milliseconds: 300),
  //     curve: Curves.easeOut,
  //   );

  //   final focusNode = FocusNode();
  //   FocusScope.of(context).requestFocus(focusNode);
  //   WidgetsBinding.instance!.addPostFrameCallback((_) {
  //     focusNode.requestFocus();
  //   });
  // });
  // }

  @override
  void initState() {
    super.initState();
    title = getTitle();
    _focusNode = FocusNode();
  }

  String getTitle() {
    if (widget.important && widget.urgent) {
      return "重要&紧急";
    } else if (widget.important && !widget.urgent) {
      return "重要&不紧急";
    } else if (!widget.important && widget.urgent) {
      return "不重要&紧急";
    } else {
      return "不重要&不紧急";
    }
  }

  void onTaskDelete(Task task) {
    // widget.onTaskDelete(task);
    setState(() {
      // widget.tasks = List.from(widget.tasks);
    });
  }

  void onTaskToggle(Task task) {
    // widget.onTaskToggle(task);
    setState(() {
      // widget.tasks = List.from(widget.tasks);
    });
  }

  void onTaskUpdate(Task task) {
    // widget.onTaskUpdate(task);
    setState(() {
      // widget.tasks = List.from(widget.tasks);
      TaskData().updateTask(task);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Container(
            margin: EdgeInsets.all(16),
            color: widget.backgroundColor,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        IconButton(icon: Icon(Icons.add), onPressed: _addTask),
                      ]),
                  const SizedBox(height: 16),
                  Expanded(child:
                    Consumer<TaskData>(builder: (context, taskData, child) {
                    _tasks = TaskData().getTask(widget.important, widget.urgent);
                    return Container(
                        decoration: BoxDecoration(
                          color: widget.taskListColor,
                        ),
                        child: FutureBuilder<List<Task>>(
                            future: _tasks,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                if (snapshot.hasError) {
                                  return Center(
                                    child: Text("Error: ${snapshot.error}}"),
                                  );
                                } else {
                                  List<Task> tasks = snapshot.data!;
                                  return ListView.builder(
                                      controller: _scrollController,
                                      itemCount: tasks.length,
                                      itemBuilder: (context, index) {
                                        return TaskAction(
                                            task: tasks[index],
                                            onTaskUpdated: onTaskUpdate,
                                            onTaskDeleted: onTaskDelete);
                                      });
                                }
                              } else {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                            }));

                    // return Container(
                    //     decoration: BoxDecoration(
                    //       color: widget.taskListColor,
                    //     ),
                    //     child: ListView(
                    //       controller: _scrollController,
                    //       children: _buildTask(),
                    //     ),
                    //     // child: ListView.builder(
                    //     //   controller: _scrollController,
                    //     //   itemCount: widget.tasks.length,
                    //     //   itemBuilder: (context, index) {
                    //     //     final task = widget.tasks[index];
                    //     //     return TaskAction(
                    //     //         task: task,
                    //     //         onTaskUpdated: onTaskUpdate,
                    //     //         onTaskDeleted: onTaskDelete);
                    //     //   },
                    //     // )
                    //   );
                  }))
                ])));
  }
}

// class TaskList extends StatefulWidget {
//   final bool important;
//   final bool urgent;
//   final Color color;
//   final Function(String) onSubmit;

//   TaskList(
//       {required this.important, required this.urgent, required this.color, required this.onSubmit});

//   @override
//   _TaskListState createState() =>
//       _TaskListState(title: getTitle(), color: color);

//   String getTitle() {
//     if (important && urgent) {
//       return "重要&紧急";
//     } else if (important && !urgent) {
//       return "重要&不紧急";
//     } else if (!important && urgent) {
//       return "不重要&紧急";
//     } else {
//       return "不重要&不紧急";
//     }
//   }
// }

// class _TaskListState extends State<TaskList> {
//   final String title;
//   final Color color;
//   late List<Task> tasks;
//   final _focusNode = FocusNode();
//   final _scrollController = ScrollController();
//   final TextEditingController _textEditingController = TextEditingController();

//   void addTask() {
//     setState(() {
//       tasks.add(Task(title: '', isDone: false));
//     });
//     // 将焦点设置到新任务上
//     _focusNode.requestFocus();
//     // 滚动ListView以将新任务显示在屏幕上
//     _scrollController.animateTo(
//       _scrollController.position.maxScrollExtent,
//       duration: Duration(milliseconds: 500),
//       curve: Curves.easeInOut,
//     );
//   }

//   _TaskListState({required this.title, required this.color});

//   @override
//   void initState() {
//     super.initState();
//     tasks = context.read<TaskData>().getTask(widget.important, widget.urgent);
//     // tasks =  context.read<TaskData>().tasks;
//   }

//   @override
//   void dispose() {
//     _textEditingController.dispose();
//     _focusNode.dispose();
//     super.dispose();
//   }

//   void _addTask() {
//     setState(() {
//       tasks.add(Task(title: ""));
//     });

//     Future.delayed(Duration(milliseconds: 300), () {
//       final index = tasks.length - 1;
//       // final itemScrollController = ScrollController();
//       final scrollPosition = _scrollController.position;

//       _scrollController.animateTo(
//         scrollPosition.maxScrollExtent,
//         duration: Duration(milliseconds: 300),
//         curve: Curves.easeOut,
//       );

//       final focusNode = FocusNode();
//       FocusScope.of(context).requestFocus(focusNode);
//       WidgetsBinding.instance!.addPostFrameCallback((_) {
//         focusNode.requestFocus();
//       });
//     });
//   }

//   void _deleteTask(int index) {
//     setState(() {
//       tasks.removeAt(index);
//     });
//   }

//   void _updateTask(int index, String title) {
//     setState(() {
//       tasks[index].title = title;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: <Widget>[
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: <Widget>[
//               Container(
//                 padding: EdgeInsets.all(16),
//                 child: Text(
//                   title,
//                   style: const TextStyle(
//                     fontSize: 30.0,
//                     fontWeight: FontWeight.w700,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//               // Expanded(child: Container()),
//               // const Spacer(),
//               IconButton(
//                 icon: Icon(Icons.add),
//                 onPressed: _addTask,
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           Expanded(
//               child: Consumer<TaskData>(builder: (context, taskData, child) {

//             return Container(
//               decoration: BoxDecoration(
//                 color: this.color,
//               ),
//               child: ListView.builder(
//                 controller: _scrollController,
//                 itemCount: taskData.taskCount,
//                 itemBuilder: (context, index) {
//                   final task = taskData.tasks[index];
//                   return CustomTaskCard(
//                     // key: Key(task.id),
//                     task: task,
//                     onCheckboxChanged: (bool? checkboxState) {
//                       setState(() {
//                         task.toggleDone();
//                       });
//                     },
//                     onLongPress: () {

//                     },
//                   );
//                 },
//               ),
//             );
//           })),

//           SizedBox(height: 16)
//           // TextField(
//           //   controller: _textEditingController,
//           //   focusNode: _focusNode,
//           //   decoration: InputDecoration(
//           //     hintText: 'Add a new task',
//           //     border: OutlineInputBorder(
//           //       borderSide: BorderSide(color: Colors.black),
//           //     ),
//           //   ),
//           //   onSubmitted: (value) {
//           //     widget.onSubmit(value);
//           //     _textEditingController.clear();
//           //   },
//           // )
//         ]);
//   }
// }
