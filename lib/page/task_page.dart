import 'package:best_todo/db/navigator_data.dart';
import 'package:best_todo/db/task_data.dart';
import 'package:best_todo/model/task.dart';
import 'package:best_todo/model/navigator.dart' as ng;
import 'task_block.dart';
import 'package:flutter/material.dart';

import 'task_four_quadrant.dart';

class TaskPage extends StatefulWidget {
  final Task parent;

  TaskPage({super.key, required this.parent});

  @override
  _TaskPageState createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage>
    with SingleTickerProviderStateMixin {
  void onClean() {
    getTaskData().clean(widget.parent.id).then((value) {
      setState(() {});
    });
  }

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 3);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ng.Navigator>>(
        future: getNavigatorData().fetchNavigators(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}}"),
            );
          }
          return NavigatorWidget(navigators: snapshot.data!);
        });
  }
}

class NavigatorWidget extends StatefulWidget {
  List<ng.Navigator> navigators;

  NavigatorWidget({required this.navigators});

  @override
  NavigatorWidgetState createState() => NavigatorWidgetState();
}

class NavigatorWidgetState extends State<NavigatorWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(vsync: this, length: widget.navigators.length);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            bottom: PreferredSize(
          preferredSize: Size.fromHeight(48.0),
          child: TabBar(
            controller: _tabController,
            tabs: List.generate(widget.navigators.length,
                (index) => Text(widget.navigators[index].title)),
          ),
        )),
        body: TabBarView(
            controller: _tabController,
            children: List.generate(widget.navigators.length, (index) {
              var parent = rootParent;
              parent.navigatorID = widget.navigators[index].id;
              return FourQuadrant(parent: parent);
            })));
  }
}
