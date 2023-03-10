import 'package:flutter/material.dart';

class Navigator {
  String title;
  String id;
  int createDt;
  int updateDt;
  int sort;

  Navigator({
    this.title = "",
    this.id = "",
    this.createDt = 0,
    this.updateDt = 0,
    this.sort = 0,
  });

  Key getKey() {
    return ValueKey(id);
  }

  Navigator copyWith({
    String? id,
    String? title,
    int? createDt,
    int? updateDt,
    int? sort,
  }) {
    return Navigator(
      title: title ?? this.title,
      id: id ?? this.id,
      createDt: createDt ?? this.createDt,
      updateDt: updateDt ?? this.updateDt,
      sort: sort ?? this.sort,
    );
  }

  factory Navigator.fromJson(Map<String, dynamic> json) {
    return Navigator(
      id: json['id'],
      title: json['title'],
      createDt: json['create_dt'],
      updateDt: json['update_dt'] ?? 0,
      sort: json['sort'],
    );
  }

  factory Navigator.fromSqlite(Map<String, dynamic> json) {
    return Navigator(
      id: json['id'],
      title: json['title'],
      createDt: json['create_dt'] ?? 0,
      updateDt: json['update_dt'] ?? 0,
      sort: json['sort'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'id': id,
        'create_dt': createDt,
        'update_dt': updateDt,
        'sort': sort,
      };

  Map<String, dynamic> toSqlite() => {
        'title': title,
        'id': id,
        'create_dt': createDt,
        'update_dt': updateDt,
        'sort': sort,
      };

  int compareTo(Navigator other) {
    return sort - other.sort;
  }
}
