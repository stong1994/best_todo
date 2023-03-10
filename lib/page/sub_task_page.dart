import 'package:best_todo/model/task.dart';
import 'package:flutter/material.dart';

import 'task_four_quadrant.dart';

class SubTaskPage extends StatefulWidget {
  final Task parent;

  SubTaskPage({super.key, required this.parent});

  @override
  _SubTaskPageState createState() => _SubTaskPageState();
}

class _SubTaskPageState extends State<SubTaskPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.parent.title),
          centerTitle: true,
        ),
        body: FourQuadrant(parent: widget.parent));
  }
}
