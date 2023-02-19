import 'package:flutter/material.dart';
import 'focus_matrix.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Focus Matrix Demo',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Focus Matrix'),
        ),
        body: FocusMatrix(
          importantUrgent: ['Task 1', 'Task 2', 'Task 3'],
          importantNotUrgent: ['Task 4', 'Task 5'],
          notImportantUrgent: ['Task 6'],
          notImportantNotUrgent: ['Task 7', 'Task 8', 'Task 9', 'Task 10'],
          onPressed: (item) => print('You clicked $item'),
        ),
      ),
    );
  }
}