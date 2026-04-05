import 'package:flutter/material.dart';

enum TaskPriority { max, med, min }

class Task {
  final String id;
  final String title;
  final String? description;
  bool isDone;
  final DateTime? deadline;
  final TaskPriority priority;
  final bool isOverdue;
  int health; // Боевая способность (HP)

  Task({
    required this.id,
    required this.title,
    this.description,
    this.isDone = false,
    this.deadline,
    this.priority = TaskPriority.min,
    this.health = 100,
  }) : isOverdue = deadline != null && 
                    DateTime.now().isAfter(deadline) && 
                    !isDone;

  Color get priorityColor {
    switch (priority) {
      case TaskPriority.max: return Colors.red;
      case TaskPriority.med: return Colors.orange;
      case TaskPriority.min: return Colors.green;
    }
  }

  String get priorityLabel {
    switch (priority) {
      case TaskPriority.max: return 'MAX';
      case TaskPriority.med: return 'MED';
      case TaskPriority.min: return 'MIN';
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id, 'title': title, 'description': description,
    'isDone': isDone, 'deadline': deadline?.toIso8601String(),
    'priority': priority.index, 'health': health,
  };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
    id: json['id'], title: json['title'], description: json['description'],
    isDone: json['isDone'] ?? false,
    deadline: json['deadline'] != null ? DateTime.parse(json['deadline']) : null,
    priority: TaskPriority.values[json['priority'] ?? 2],
    health: json['health'] ?? 100,
  );
}
