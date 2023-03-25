import 'package:best_todo/db/scene_data.dart';
import 'package:best_todo/db/task_data.dart';
import 'package:best_todo/model/task.dart';
import 'package:best_todo/model/scene.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'dart:math';

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
              appBar: PreferredSize(
                preferredSize: Size.fromHeight(kToolbarHeight + 10),
                child: AppBar(
                    bottom: PreferredSize(
                        preferredSize: Size.fromHeight(kToolbarHeight), // todo
                        child: Row(
                          children: [
                            Expanded(
                              child: TabBar(
                                isScrollable: true,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10), // todo
                                controller: _tabController,
                                tabs: List.generate(scenes.length, (index) {
                                  return NavigatorItem(
                                    scene: scenes[index],
                                    onCloseScene: () {
                                      closeNavigator(scenes[index]);
                                    },
                                    editScene: (title) {
                                      scenes[index].title = title;
                                      updateNavigator(scenes[index]);
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
              ),
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

  void updateNavigator(Scene scene) {
    getSceneData().updateScene(scene).then((_) {
      setState(() {});
    });
  }
}

class NavigatorItem extends StatefulWidget {
  final Scene scene;
  final Function() onCloseScene;
  final Function(String title) editScene;

  NavigatorItem(
      {required this.scene,
      required this.onCloseScene,
      required this.editScene});

  @override
  State<StatefulWidget> createState() => NavigatorItemState();
}

class NavigatorItemState extends State<NavigatorItem> {
  bool _hovering = false;
  final _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _textEditingController.text = widget.scene.title;
  }

  Widget menuList(context) {
    return PopupMenuButton(
      onCanceled: () => _hovering = false,
      itemBuilder: (BuildContext context) {
        return <PopupMenuEntry>[
          PopupMenuItem(
            child: ListTile(
                title: Text('编辑'),
                contentPadding: EdgeInsets.zero, // 取消内边距
                dense: true,
                leading: Container(
                  height: 18.0,
                  child: Icon(Icons.edit, size: 16.0),
                ),
                // title: Text('编辑'),
                onTap: () {
                  onEditScene();
                  // Navigator.of(context).pop(); // todo
                }),
          ),
          PopupMenuItem(
            child: ListTile(
              title: Text('删除'),
              contentPadding: EdgeInsets.zero, // 取消内边距
              dense: true,
              leading: Container(
                height: 18.0,
                child: Icon(Icons.delete_forever, size: 16.0),
              ),
              onTap: () {
                widget.onCloseScene(); // todo pop context
              },
            ),
          ),
        ];
      },
      icon: Transform.rotate(
          angle: 90 * pi / 180, child: Icon(Icons.adaptive.more_outlined)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
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
        child: Container(
          width: 100,
          // height: kToolbarHeight,
          // padding: EdgeInsets.symmetric(horizontal: 12, vertical: 18),
          margin: EdgeInsets.symmetric(vertical: 8),
          child: Stack(
            children: [
              Text(
                widget.scene.title,
              ),
              Align(
                  alignment: Alignment.topRight,
                  child: _hovering
                      ? Container(
                          height: 20,
                          child: menuList(context),
                        )
                      : Container(
                          height: 20,
                        )),
            ],
          ),
        ));
  }

  void onEditScene() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return RawKeyboardListener(
            focusNode: FocusNode(),
            onKey: (event) {
              if (event.logicalKey == LogicalKeyboardKey.enter) {
                widget.editScene(_textEditingController.text);
                Navigator.of(context).pop();
              }
            },
            child: AlertDialog(
              title: const Text('更新场景',
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
                    widget.editScene(_textEditingController.text);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ));
      },
    );
  }
}
