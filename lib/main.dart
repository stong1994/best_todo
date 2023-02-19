import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'task_data.dart';
import 'task_screen.dart';
import 'focus_matrix.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TaskData(),
      child: MaterialApp(
        title: 'Focus Matrix',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: FocusMatrix(),
      ),
    );
  }
}
