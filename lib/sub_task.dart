import 'package:flutter/material.dart';

import 'db/task_data.dart';
import 'event/event_bus.dart';
import 'model/sub_task.dart';

class SubTaskPage extends StatefulWidget {
  final String parentID;
  final Color? backgroundColor;
  final Color? taskListColor;
  final String title;

  const SubTaskPage(
      {super.key,
      required this.parentID,
      required this.title,
      required this.taskListColor,
      required this.backgroundColor});

  @override
  SubTaskState createState() => SubTaskState();
}

class SubTaskState extends State<SubTaskPage> {
  late String title;
  late final SubTaskData _taskData;

  final _scrollController = ScrollController();
  final _textEditingController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    title = widget.title;
    _taskData = getSubTaskData();
  }

  void onClean() {
    setState(() {
      getSubTaskData().cleanSubTasks(widget.parentID);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          backgroundColor: widget.backgroundColor,
          actions: [
            IconButton(icon: const Icon(Icons.add), onPressed: _addArea),
            IconButton(
              icon: const Icon(Icons.cleaning_services_outlined),
              onPressed: onClean,
            ),
          ],
        ),
        body: Container(
            margin: EdgeInsets.all(16),
            color: widget.backgroundColor,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  mainArea(),
                ])));
  }

  void onTaskDelete(SubTask task) {
    setState(() {
      _taskData.deleteSubTask(task);
    });
  }

  void onTaskUpdate(SubTask task) {
    setState(() {
      _taskData.updateSubTask(task);
    });
  }

  void onTaskAdd(String title) {
    setState(() {
      _taskData.addSubTask(SubTask(title: title, parentID: widget.parentID));
    });
  }

  // 任务列表主体
  Widget mainArea() {
    return Expanded(
        child: Container(
            decoration: BoxDecoration(
              color: widget.taskListColor,
            ),
            child: FutureBuilder<List<SubTask>>(
                future: _taskData.fetchSubTasks(widget.parentID),
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
                  List<SubTask> tasks = snapshot.data!;
                  return ListView.builder(
                      controller: _scrollController,
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        return SubTaskRow(
                            task: tasks[index],
                            onTaskUpdated: onTaskUpdate,
                            onTaskDeleted: onTaskDelete);
                      });
                })));
  }

  // 添加任务弹窗
  void _addArea() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('添加子任务',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              )),
          backgroundColor: widget.backgroundColor?.withOpacity(0.9),
          content: SingleChildScrollView(
              child: TextField(
            autofocus: true,
            controller: _textEditingController,
            decoration: const InputDecoration(
              // fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              hintText: '请描述子任务...',
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
                String title = _textEditingController.text;
                onTaskAdd(title);
                _textEditingController.clear();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class SubTaskRow extends StatefulWidget {
  SubTask task;
  final Function(SubTask) onTaskUpdated;
  final Function(SubTask) onTaskDeleted;

  SubTaskRow(
      {super.key,
      required this.task,
      required this.onTaskDeleted,
      required this.onTaskUpdated});

  @override
  SubTaskRowState createState() => SubTaskRowState();
}

class SubTaskRowState extends State<SubTaskRow> {
  late TextEditingController _textEditingController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController(text: widget.task.title);
    eventBus.on<int>().listen((hashCode) {
      onOtherTaskEditing(hashCode);
    });
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  onOtherTaskEditing(int hashCode) {
    if (widget.hashCode != hashCode && _isEditing) {
      _toggleEditing();
    }
  }

  void _toggleEditing() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _updateTask(String newTitle) {
    widget.onTaskUpdated(widget.task.copyWith(title: newTitle));
    _toggleEditing();
  }

  void _toggleDone(bool isDone) {
    widget.onTaskUpdated(widget.task.copyWith(isDone: isDone));
  }

  void _deleteTask() {
    widget.onTaskDeleted(widget.task);
  }

  Widget _showTask(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _toggleEditing();
        eventBus.fire(widget.hashCode);
      },
      child: Row(
        children: [
          Checkbox(
            value: widget.task.isDone,
            onChanged: (value) {
              _toggleDone(value!);
            },
          ),
          Expanded(
            child: Text(
              widget.task.title,
              style: TextStyle(
                decoration:
                    widget.task.isDone ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteTask,
          ),
        ],
      ),
    );
  }

  Widget _editTask() {
    return TextFormField(
      controller: _textEditingController,
      autofocus: true,
      style: TextStyle(fontSize: 18.0, color: Colors.black87),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 15.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(
            width: 0.8,
            color: Colors.grey.shade400,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(
            width: 0.8,
            color: Colors.grey.shade400,
          ),
        ),
      ),
      onFieldSubmitted: (value) {
        _updateTask(value);
        _textEditingController.clear();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _isEditing ? _editTask() : _showTask(context);
  }
}
