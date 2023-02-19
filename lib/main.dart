import 'package:flutter/material.dart';
import 'focus_matrix.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final List<CustomTask> importantUrgent = [
    CustomTask(title: 'Task 1'),
    CustomTask(title: 'Task 2'),
    CustomTask(title: 'Task 3')
  ];

  final List<CustomTask> importantNotUrgent = [
    CustomTask(title: 'Task 4'),
    CustomTask(title: 'Task 5')
  ];

  final List<CustomTask> notImportantUrgent = [
    CustomTask(title: 'Task 6')
  ];

  final List<CustomTask> notImportantNotUrgent = [
    CustomTask(title: 'Task 7'),
    CustomTask(title: 'Task 8'),
    CustomTask(title: 'Task 9'),
    CustomTask(title: 'Task 10')
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Focus Matrix Demo',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Focus Matrix'),
        ),
        body: FocusMatrix(
          importantUrgent: importantUrgent,
          importantNotUrgent: importantNotUrgent,
          notImportantUrgent: notImportantUrgent,
          notImportantNotUrgent: notImportantNotUrgent,
          onPressed: (item) => print('You clicked $item'),
        ),
      ),
    );
  }
}
