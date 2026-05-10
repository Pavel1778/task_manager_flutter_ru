// task.dart - Модель задачи
import 'package:flutter/material.dart';

// Иерархия приоритетов
enum TaskPriority { max, med, min }

class Task {
  final String id;
  String title;
  String? description;
  bool isDone;
  DateTime? deadline;
  TaskPriority priority;

  Task({
    required this.id,
    required this.title,
    this.description,
    this.isDone = false,
    this.deadline,
    this.priority = TaskPriority.min,
  });

  // Просроченность пересчитывается динамически при каждом обращении
  bool get isOverdue =>
      deadline != null && DateTime.now().isAfter(deadline!) && !isDone;

  // Цвет метки приоритета
  Color get priorityColor {
    switch (priority) {
      case TaskPriority.max: return Colors.red;
      case TaskPriority.med: return Colors.orange;
      case TaskPriority.min: return Colors.green;
    }
  }

  // Русская подпись приоритета
  String get priorityLabel {
    switch (priority) {
      case TaskPriority.max: return 'MAX';
      case TaskPriority.med: return 'MED';
      case TaskPriority.min: return 'MIN';
    }
  }

  // Сериализация в JSON для хранения
  Map<String, dynamic> toJson() => {
    'id': id, 'title': title, 'description': description,
    'isDone': isDone, 'deadline': deadline?.toIso8601String(),
    'priority': priority.index,
  };

  // Десериализация из JSON
  factory Task.fromJson(Map<String, dynamic> j) => Task(
    id: j['id'], title: j['title'], description: j['description'],
    isDone: j['isDone'] ?? false,
    deadline: j['deadline'] != null ? DateTime.parse(j['deadline']) : null,
    priority: TaskPriority.values[j['priority'] ?? 2],
  );
}
