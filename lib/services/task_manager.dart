// task_manager.dart - Управление задачами и хранилищем
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

// Хранение задач в SharedPreferences
class _Storage {
  static const _k = 'tasks';
  static Future<List<Task>> load() async {
    final p = await SharedPreferences.getInstance();
    final d = p.getString(_k);
    if (d == null) return [];
    return (jsonDecode(d) as List)
        .map((e) => Task.fromJson(e as Map<String, dynamic>)).toList();
  }
  static Future<void> save(List<Task> tasks) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_k, jsonEncode(tasks.map((e) => e.toJson()).toList()));
  }
}

class TaskManager extends ChangeNotifier {
  List<Task> _tasks = [];
  String _filter = 'Все';
  final _doneQ = ['Отлично! 🎉','Великолепно! 🌟','На верном пути! 💪',
    'Продолжай! ⭐','Молодец! 🎯','Супер! 👏','Браво! ✨'];

  String get filter => _filter;

  // Список с фильтром и сортировкой:
  // max → med → min, внутри приоритета: ближний дедлайн выше,
  // без дедлайна — в конце своего приоритета
  List<Task> get tasks {
    final list = _tasks.where((t) {
      if (_filter == 'Активные') return !t.isDone;
      if (_filter == 'Завершённые') return t.isDone;
      return true;
    }).toList()
      ..sort((a, b) {
        final pc = a.priority.index.compareTo(b.priority.index);
        if (pc != 0) return pc;
        if (a.deadline == null && b.deadline == null) return 0;
        if (a.deadline == null) return 1;
        if (b.deadline == null) return -1;
        return a.deadline!.compareTo(b.deadline!);
      });
    return list;
  }

  void setFilter(String f) { _filter = f; notifyListeners(); }

  Future<void> load() async {
    _tasks = await _Storage.load();
    notifyListeners();
  }

  String _quote() => _doneQ[Random().nextInt(_doneQ.length)];

  // Добавление задачи
  void add(String title, String? desc, DateTime? dl, TaskPriority p) {
    _tasks.add(Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title, description: desc, deadline: dl, priority: p,
    ));
    _Storage.save(_tasks); notifyListeners();
  }

  // Редактирование задачи по id
  void edit(String id, String title, String? desc, DateTime? dl, TaskPriority p) {
    final t = _tasks.firstWhere((t) => t.id == id);
    t.title = title; t.description = desc; t.deadline = dl; t.priority = p;
    _Storage.save(_tasks); notifyListeners();
  }

  // Переключение выполнения; возвращает цитату при завершении
  String toggle(String id) {
    final t = _tasks.firstWhere((t) => t.id == id);
    t.isDone = !t.isDone;
    _Storage.save(_tasks); notifyListeners();
    return t.isDone ? _quote() : '';
  }

  // Удаление задачи
  void delete(String id) {
    _tasks.removeWhere((t) => t.id == id);
    _Storage.save(_tasks); notifyListeners();
  }
}
