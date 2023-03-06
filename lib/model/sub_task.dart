import 'package:flutter/material.dart';

import '../event/event_bus.dart';

class SubTask {
  String id;
  String parentID;
  String title;
  bool isDone;
  int createDt;
  int updateDt;
  int sort;

  SubTask({
    this.id = "",
    this.title = "",
    this.isDone = false,
    this.parentID = "",
    this.createDt = 0,
    this.updateDt = 0,
    this.sort = 0,
  });

  void toggleDone() {
    isDone = !isDone;
  }

  Key getKey() => ValueKey(id) ;

  SubTask copyWith({
    String? title,
    bool? isDone,
    String? id,
    String? parentID,
    int? createDt,
    int? updateDt,
    int? sort,
  }) {
    return SubTask(
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
      id: id ?? this.id,
      parentID: parentID ?? this.parentID,
      createDt: createDt ?? this.createDt,
      updateDt: updateDt ?? this.updateDt,
      sort: sort ?? this.sort,
    );
  }

  factory SubTask.fromJson(Map<String, dynamic> json) {
    return SubTask(
      id: json['id'],
      title: json['title'],
      isDone: json['is_done'],
      parentID: json['parent_id'],
      createDt: json['create_dt'],
      updateDt: json['update_dt'],
      sort: json['sort'],
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
      sort: json['sort'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'is_done': isDone,
        'id': id,
        'parent_id': parentID,
        'create_dt': createDt,
        'update_dt': updateDt,
        'sort': sort,
      };

  Map<String, dynamic> toSqlite() => {
        'title': title,
        'is_done': isDone ? 1 : 0,
        'id': id,
        'parent_id': parentID,
        'create_dt': createDt,
        'update_dt': updateDt,
        'sort': sort,
      };

  int compareTo(SubTask other) {
    if (sort != 0 && other.sort != 0) {
      return sort - other.sort;
    }
    final int selfTime = updateDt != 0 ? updateDt : createDt;
    final int otherTime = other.updateDt != 0 ? other.updateDt : other.createDt;
    return selfTime - otherTime;
  }
}
