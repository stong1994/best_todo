import 'package:best_todo/model/sub_task.dart';

class Task {
  String title;
  bool isDone;
  String id;
  bool isImportant;
  bool isUrgent;
  List<SubTask> subTasks;

  Task({
    this.title = "",
    this.isDone = false,
    this.id = "",
    this.isImportant = false,
    this.isUrgent = false,
    this.subTasks = const [],
  });

  void toggleDone() {
    isDone = !isDone;
  }

  Task copyWith({
    String? title,
    bool? isDone,
    String? id,
    bool? isImportant,
    bool? isUrgent,
    List<SubTask>? subTasks,
  }) {
    return Task(
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
      id: id ?? this.id,
      isImportant: isImportant ?? this.isImportant,
      isUrgent: isUrgent ?? this.isUrgent,
      subTasks: subTasks ?? this.subTasks,
    );
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      isDone: json['is_done'],
      isImportant: json['is_important'],
      isUrgent: json['is_urgent'],
      subTasks: json['sub_tasks'],
    );
  }

  factory Task.fromSqlite(Map<String, dynamic> json) {
    return Task(
        id: json['id'],
        title: json['title'],
        isDone: json['is_done'] == 1 ? true : false,
        isImportant: json['is_important'] == 1 ? true : false,
        isUrgent: json['is_urgent'] == 1 ? true : false);
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'is_done': isDone,
        'is_important': isImportant,
        'is_urgent': isUrgent,
        'id': id,
      };

  Map<String, dynamic> toSqlite() => {
        'title': title,
        'is_done': isDone ? 1 : 0,
        'is_important': isImportant ? 1 : 0,
        'is_urgent': isUrgent ? 1 : 0,
        'id': id,
      };
}
