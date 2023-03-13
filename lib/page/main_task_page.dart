import 'package:best_todo/db/scene_data.dart';
import 'package:best_todo/db/task_data.dart';
import 'package:best_todo/model/task.dart';
import 'package:best_todo/model/scene.dart';
import 'package:flutter/services.dart';
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
    return FutureBuilder<List<Scene>>(
        future: getSceneData().fetchScenes(),
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
          final scenes = snapshot.data!;
          final _tabController =
              TabController(vsync: this, length: scenes.length);

          return Scaffold(
              appBar: AppBar(
                  bottom: PreferredSize(
                      preferredSize: Size.fromHeight(kToolbarHeight), // todo
                      child: Row(
                        children: [
                          Expanded(
                            child: TabBar(
                              isScrollable: true,
                              padding:
                                  EdgeInsets.symmetric(horizontal: 10), // todo
                              controller: _tabController,
                              tabs: List.generate(scenes.length, (index) {
                                return NavigatorItem(
                                  scene: scenes[index],
                                  onCloseScene: () {
                                    closeNavigator(scenes[index]);
                                  },
                                );
                              }),
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
                  children: List.generate(scenes.length, (index) {
                    var parent = rootParent.copyWith(sceneID: scenes[index].id);
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
    getSceneData().addScene(Scene(title: title)).then((_) {
      Navigator.of(context).pop();
      setState(() {});
    });
  }

  void closeNavigator(Scene scene) {
    getSceneData().deleteScene(scene).then((_) {
      setState(() {});
    });
  }
}

class NavigatorItem extends StatefulWidget {
  final Scene scene;
  final Function() onCloseScene;

  NavigatorItem({required this.scene, required this.onCloseScene});

  @override
  State<StatefulWidget> createState() => NavigatorItemState();
}

class NavigatorItemState extends State<NavigatorItem> {
  bool _hovering = false;

  Widget hoverWidget() {
    return IconButton(
      icon: Icon(Icons.close),
      onPressed: () {
        widget.onCloseScene();
      },
    );
  }

  Widget unHoverWidget() {
    return Container(
      width: 30,
      height: 30,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      // padding: EdgeInsets.symmetric(horizontal: 12, vertical: 18),
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Stack(
        children: [
          Text(
            widget.scene.title,
          ),
          Align(
              alignment: Alignment.topRight,
              child: MouseRegion(
                  onEnter: (PointerEnterEvent event) {
                    setState(() {
                      _hovering = true;
                    });
                  },
                  onExit: (PointerExitEvent event) {
                    setState(() {
                      _hovering = false;
                    });
                  },
                  child: _hovering ? hoverWidget() : unHoverWidget())),
        ],
      ),
    );
    //  return Container(
    //         width: 100,

    //         child: ListTile(
    //           title: Text(widget.scene.title),
    //           trailing: _hovering
    //               ? Icon(Icons.close)
    //               : Container(
    //                   width: 0,
    //                   height: 0,
    //                 ),
    //         ),
    //       )
    //   return MouseRegion(
    //       onEnter: (PointerEnterEvent event) {
    //         setState(() {
    //           _hovering = true;
    //         });
    //       },
    //       onExit: (PointerExitEvent event) {
    //         setState(() {
    //           _hovering = false;
    //         });
    //       },
    //       child: Container(
    //         width: 100,
    //         child: ListTile(
    //           title: Text(widget.scene.title),
    //           trailing: _hovering
    //               ? Icon(Icons.close)
    //               : Container(
    //                   width: 0,
    //                   height: 0,
    //                 ),
    //         ),
    //       ));

    // return Container(
    //     width: 100,
    //     child: ListTile(
    //       title: Text(widget.scene.title),
    //       trailing: _hovering
    //           ? IconButton(
    //               icon: Icon(Icons.close),
    //               onPressed: () {
    //                 widget.onCloseScene(widget.scene);
    //               },
    //             )
    //           : Container(),
    //     ));
    // return Container(
    //     padding: const EdgeInsets.all(8.0),
    //     child: Stack(
    //       alignment: Alignment.topRight,
    //       children: [
    //         Text(widget.scene.title),
    //         Positioned(
    //             top: 0,
    //             right: 0,
    //             child: GestureDetector(
    //               onTap: () {
    //                 widget.onCloseScene(widget.scene);
    //               },
    //               child: _hovering
    //                   ? Positioned(
    //                       right: 10,
    //                       top: 10,
    //                       child: Icon(Icons.close, color: Colors.red))
    //                   : Container(),
    //             ))
    //       ],
    //     ),
    //   )

    //   return MouseRegion(
    //     onEnter: (PointerEnterEvent event) {
    //       setState(() {
    //         _hovering = true;
    //       });
    //     },
    //     onExit: (PointerExitEvent event) {
    //       setState(() {
    //         _hovering = false;
    //       });
    //     },
    //     child:
    //   );
  }
}
