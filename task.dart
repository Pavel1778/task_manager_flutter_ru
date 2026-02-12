import 'package:flutter/material.dart';

enum TaskPriority { high, medium, low }

class Task {
  String id;
  String title;
  String? description;
  bool isDone;
  DateTime? deadline;
  TaskPriority priority;

  Task({required this.id, required this.title, this.description, this.isDone = false, this.deadline, this.priority = TaskPriority.medium});

  Color get priorityColor => priority == TaskPriority.high ? Colors.red : priority == TaskPriority.medium ? Colors.orange : Colors.green;
  String get priorityLabel => priority == TaskPriority.high ? 'MAX' : priority == TaskPriority.medium ? 'MED' : 'MIN';

  String formatDeadline() {
    if (deadline == null) return '';
    const m = ['янв', 'фев', 'мар', 'апр', 'май', 'июн', 'июл', 'авг', 'сен', 'окт', 'ноя', 'дек'];
    return '${deadline!.day} ${m[deadline!.month - 1]} ${deadline!.year}, ${deadline!.hour.toString().padLeft(2, '0')}:${deadline!.minute.toString().padLeft(2, '0')}';
  }

  String formatFull() {
    if (deadline == null) return 'Не установлен';
    const m = ['янв', 'фев', 'мар', 'апр', 'май', 'июн', 'июл', 'авг', 'сен', 'окт', 'ноя', 'дек'];
    return '${deadline!.day} ${m[deadline!.month - 1]} ${deadline!.year}, ${deadline!.hour.toString().padLeft(2, '0')}:${deadline!.minute.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'description': description, 'isDone': isDone, 'deadline': deadline?.toIso8601String(), 'priority': priority.index};
  factory Task.fromJson(Map<String, dynamic> j) => Task(id: j['id'], title: j['title'], description: j['description'], isDone: j['isDone'] ?? false, deadline: j['deadline'] != null ? DateTime.parse(j['deadline']) : null, priority: TaskPriority.values[j['priority'] ?? 1]);
}
