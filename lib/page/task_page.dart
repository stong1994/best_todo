import 'package:best_todo/db/navigator_data.dart';
import 'package:best_todo/db/task_data.dart';
import 'package:best_todo/model/task.dart';
import 'package:best_todo/model/navigator.dart' as ng;
import 'package:flutter/services.dart';
import 'task_block.dart';
import 'package:flutter/material.dart';

import 'task_four_quadrant.dart';

class TaskPage extends StatefulWidget {
  final Task parent;

  TaskPage({super.key, required this.parent});

  @override
  _TaskPageState createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> with TickerProviderStateMixin {
  void onClean() {
    getTaskData().clean(widget.parent.id).then((value) {
      setState(() {});
    });
  }

  final _textEditingController = TextEditingController();
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
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
          final navigators = snapshot.data!;
          final _tabController =
              TabController(vsync: this, length: navigators.length);

          return Scaffold(
              appBar: AppBar(
                  bottom: PreferredSize(
                      preferredSize: Size.fromHeight(48.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TabBar(
                              padding: EdgeInsets.all(14),
                              controller: _tabController,
                              tabs: List.generate(navigators.length,
                                  (index) => Text(navigators[index].title)),
                            ),
                          ),
                          IconButton(
                              onPressed: onAddNavigator,
                              icon: const Icon(
                                Icons.add,
                                color: Colors.white,
                              )),
                        ],
                      ))),
              body: TabBarView(
                  controller: _tabController,
                  children: List.generate(navigators.length, (index) {
                    var parent = rootParent.copyWith(navigatorID: navigators[index].id);
                    return FourQuadrant(parent: parent);
                  })));
        });
  }

  void onAddNavigator() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return RawKeyboardListener(
            focusNode: focusNode,
            onKey: (event) {
              if (event.logicalKey == LogicalKeyboardKey.enter) {
                addNavigator(context);
              }
            },
            child: AlertDialog(
              title: const Text('添加场景',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  )),
              content: SingleChildScrollView(
                  child: TextField(
                autofocus: true,
                controller: _textEditingController,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  hintText: '请描述场景...',
                  hintStyle: TextStyle(
                    color: Color.fromARGB(255, 235, 186, 186),
                    fontSize: 16,
                  ),
                  border: UnderlineInputBorder(),
                ),
              )),
              actions: [
                TextButton(
                  child: const Text('取消'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('完成'),
                  onPressed: () {
                    addNavigator(context);
                  },
                ),
              ],
            ));
      },
    );
  }

  void addNavigator(BuildContext context) {
    final title = _textEditingController.text;
    _textEditingController.clear();
    getNavigatorData().addNavigator(ng.Navigator(title: title)).then((_) {
      Navigator.of(context).pop();
      setState(() {});
    });
  }
}
