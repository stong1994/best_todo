import 'package:flutter/material.dart';

class Task {
  String title;
  String detail;
  bool isDone;
  String id;
  String parentID;
  String sceneID;
  int createDt;
  int updateDt;
  int sort;

  bool isImportant;
  bool isUrgent;
  List<Task> subTasks;

  Task({
    this.title = "",
    this.detail = "",
    this.isDone = false,
    this.id = "",
    this.sceneID = "",
    this.parentID = "",
    this.createDt = 0,
    this.updateDt = 0,
    this.isImportant = false,
    this.isUrgent = false,
    this.subTasks = const [],
    this.sort = 0,
  });

  Key getKey() {
    return ValueKey(id);
  }

  void toggleDone() {
    isDone = !isDone;
  }

  Task copyWith({
    String? title,
    String? detail,
    bool? isDone,
    String? id,
    String? sceneID,
    String? parentID,
    int? createDt,
    int? updateDt,
    bool? isImportant,
    bool? isUrgent,
    List<Task>? subTasks,
    int? sort,
  }) {
    return Task(
      title: title ?? this.title,
      detail: detail ?? this.detail,
      isDone: isDone ?? this.isDone,
      id: id ?? this.id,
      parentID: parentID ?? this.parentID,
      sceneID: sceneID ?? this.sceneID,
      createDt: createDt ?? this.createDt,
      updateDt: updateDt ?? this.updateDt,
      isImportant: isImportant ?? this.isImportant,
      isUrgent: isUrgent ?? this.isUrgent,
      subTasks: subTasks ?? this.subTasks,
      sort: sort ?? this.sort,
    );
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      parentID: json['parent_id'],
      sceneID: json['scene_id'] ?? '',
      title: json['title'],
      detail: json['detail'],
      isDone: json['is_done'],
      createDt: json['create_dt'],
      updateDt: json['update_dt'] ?? 0,
      isImportant: json['is_important'],
      isUrgent: json['is_urgent'],
      subTasks: json['sub_tasks'],
      sort: json['sort'],
    );
  }

  factory Task.fromSqlite(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      parentID: json['parent_id'],
      sceneID: json['scene_id'] ?? '',
      title: json['title'],
      detail: json['detail'] ?? '',
      isDone: json['is_done'] == 1 ? true : false,
      isImportant: json['is_important'] == 1 ? true : false,
      isUrgent: json['is_urgent'] == 1 ? true : false,
      createDt: json['create_dt'] ?? 0,
      updateDt: json['update_dt'] ?? 0,
      sort: json['sort'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'detail': detail,
        'is_done': isDone,
        'is_important': isImportant,
        'is_urgent': isUrgent,
        'id': id,
        'parent_id': parentID,
        'scene_id': sceneID,
        'create_dt': createDt,
        'update_dt': updateDt,
        'sort': sort,
      };

  Map<String, dynamic> toSqlite() => {
        'title': title,
        'detail': detail,
        'is_done': isDone ? 1 : 0,
        'is_important': isImportant ? 1 : 0,
        'is_urgent': isUrgent ? 1 : 0,
        'id': id,
        'parent_id': parentID,
        'scene_id': sceneID,
        'create_dt': createDt,
        'update_dt': updateDt,
        'sort': sort,
      };

  int compareTo(Task other) {
    if (sort != 0 && other.sort != 0) {
      return sort - other.sort;
    }
    final int selfTime = updateDt != 0 ? updateDt : createDt;
    final int otherTime = other.updateDt != 0 ? other.updateDt : other.createDt;
    return selfTime - otherTime;
  }
}
