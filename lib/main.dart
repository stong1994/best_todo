import 'package:best_todo/db/task_data.dart';
import 'package:best_todo/page/main_task_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // debugPrint(RendererBinding.instance.renderView.toStringDeep());
    return MaterialApp(
      title: 'Best Todo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: TaskPage(parent: rootParent),
    );
  }
}
