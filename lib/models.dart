import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Priority { high, medium, low }

class Task {
  final String id;
  String title, description;
  bool isDone;
  DateTime? deadline;
  Priority priority;

  Task({
    String? id, required this.title, this.description = '',
    this.isDone = false, this.deadline, this.priority = Priority.medium,
  }) : id = id ?? '${DateTime.now().millisecondsSinceEpoch}';
  bool get isOverdue => !isDone && deadline != null && deadline!.isBefore(DateTime.now());
  Color get color => const [Colors.red, Colors.orange, Colors.green][priority.index];
  String get label => const ['MAX', 'MED', 'MIN'][priority.index];
  String get deadlineText {
    if (deadline == null) return '';
    const mo = ['янв','фев','мар','апр','май','июн','июл','авг','сен','окт','ноя','дек'];
    final h = deadline!.hour.toString().padLeft(2, '0');
    final m = deadline!.minute.toString().padLeft(2, '0');
    return '${deadline!.day} ${mo[deadline!.month - 1]}, $h:$m';
  }
  Map<String, dynamic> toJson() => {
    'id': id, 'title': title, 'desc': description,
    'done': isDone, 'dl': deadline?.toIso8601String(), 'p': priority.index,
  };

  factory Task.fromJson(Map<String, dynamic> j) => Task(
    id: j['id'], title: j['title'], description: j['desc'] ?? '',
    isDone: j['done'] ?? false,
    deadline: j['dl'] != null ? DateTime.parse(j['dl']) : null,
    priority: Priority.values[j['p'] ?? 1],
  );
}

class TaskManager extends ChangeNotifier {
  List<Task> _tasks = [];
  String filter = 'Все';
  bool isDark = false;

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  List<Task> get tasks {
    final list = filter == 'Активные'    ? _tasks.where((t) => !t.isDone).toList()
               : filter == 'Выполненные' ? _tasks.where((t) =>  t.isDone).toList()
               : List.of(_tasks);
    list.sort((a, b) {
      if (a.isDone != b.isDone)       return a.isDone ? 1 : -1;
      if (a.isOverdue != b.isOverdue) return a.isOverdue ? -1 : 1;
      final pc = a.priority.index.compareTo(b.priority.index);
      if (pc != 0) return pc;
      if (a.deadline == b.deadline) return 0;
      if (a.deadline == null)       return 1;
      if (b.deadline == null)       return -1;
      return a.deadline!.compareTo(b.deadline!);
    });
    return list;
  }

  List<Task> tasksForDay(DateTime d) => _tasks.where((t) =>
    t.deadline != null && t.deadline!.year == d.year &&
    t.deadline!.month == d.month && t.deadline!.day == d.day).toList();

  Future<void> load() async {
    final p = await _prefs;
    final raw = p.getString('tasks');
    if (raw != null) _tasks = (jsonDecode(raw) as List).map((e) => Task.fromJson(e)).toList();
    isDark = p.getBool('isDark') ?? false;
    notifyListeners();
  }

  Future<void> _save() async =>
    (await _prefs).setString('tasks', jsonEncode(_tasks.map((t) => t.toJson()).toList()));

  void add(Task t)         { _tasks.add(t);                                        _save(); notifyListeners(); }
  void delete(String id)   { _tasks.removeWhere((t) => t.id == id);                _save(); notifyListeners(); }
  void toggle(String id)   { _tasks.firstWhere((t) => t.id == id).isDone ^= true;  _save(); notifyListeners(); }
  void setFilter(String f) { filter = f; notifyListeners(); }

  Future<void> toggleTheme() async {
    isDark = !isDark;
    (await _prefs).setBool('isDark', isDark);
    notifyListeners();
  }
}
