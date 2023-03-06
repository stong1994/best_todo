import 'package:flutter/material.dart';

import '../event/event_bus.dart';

class SubTask {
  String id;
  String parentID;
  String title;
  bool isDone;
  int createDt;
  int updateDt;

  SubTask({
    this.id = "",
    this.title = "",
    this.isDone = false,
    this.parentID = "",
    this.createDt = 0,
    this.updateDt = 0,
  });

  void toggleDone() {
    isDone = !isDone;
  }

  SubTask copyWith({
    String? title,
    bool? isDone,
    String? id,
    String? parentID,
    int? createDt,
    int? updateDt,
  }) {
    return SubTask(
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
      id: id ?? this.id,
      parentID: parentID ?? this.parentID,
      createDt: createDt ?? this.createDt,
      updateDt: updateDt ?? this.updateDt,
    );
  }

  factory SubTask.fromJson(Map<String, dynamic> json) {
    return SubTask(
      id: json['id'],
      title: json['title'],
      isDone: json['is_done'],
      parentID: json['parent_id'],
      createDt: json['create_dt'],
      updateDt: json['update_dt'] ?? 0,
    );
  }

  factory SubTask.fromSqlite(Map<String, dynamic> json) {
    return SubTask(
      id: json['id'],
      title: json['title'],
      isDone: json['is_done'] == 1 ? true : false,
      parentID: json['parent_id'],
      createDt: json['create_dt'] ?? 0,
      updateDt: json['update_dt'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'is_done': isDone,
        'id': id,
        'parent_id': parentID,
        'create_dt': createDt,
        'update_dt': updateDt,
      };

  Map<String, dynamic> toSqlite() => {
        'title': title,
        'is_done': isDone ? 1 : 0,
        'id': id,
        'parent_id': parentID,
        'create_dt': createDt,
        'update_dt': updateDt,
      };

  int compareTo(SubTask other) {
    final int selfTime = updateDt != 0 ? updateDt : createDt;
    final int otherTime = other.updateDt != 0 ? other.updateDt : other.createDt;
    return selfTime - otherTime;
  }
}
