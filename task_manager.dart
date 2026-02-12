import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'task.dart';

class TaskManager extends ChangeNotifier {
  List<Task> _tasks = [];
  String _filter = 'Все';

  List<Task> get tasks {
    var r = _filter == 'Активные' ? _tasks.where((t) => !t.isDone).toList() : _filter == 'Выполненные' ? _tasks.where((t) => t.isDone).toList() : List<Task>.from(_tasks);
    r.sort((a, b) {
      if (a.isDone != b.isDone) return a.isDone ? 1 : -1;
      if (a.deadline == null && b.deadline == null) return 0;
      if (a.deadline == null) return 1;
      if (b.deadline == null) return -1;
      return a.deadline!.compareTo(b.deadline!);
    });
    return r;
  }

  String get filter => _filter;
  int get totalCount => _tasks.length;
  int get completedCount => _tasks.where((t) => t.isDone).length;
  int get activeCount => totalCount - completedCount;
  int get percent => _tasks.isEmpty ? 0 : ((completedCount / totalCount) * 100).round();

  Future<void> load() async {
    final j = (await SharedPreferences.getInstance()).getString('tasks');
    if (j != null) {
      _tasks = (jsonDecode(j) as List).map((e) => Task.fromJson(e)).toList();
      notifyListeners();
    }
  }

  Future<void> _save() async => (await SharedPreferences.getInstance()).setString('tasks', jsonEncode(_tasks.map((t) => t.toJson()).toList()));

  void add(String title, String? desc, DateTime? deadline, TaskPriority priority) {
    _tasks.add(Task(id: DateTime.now().millisecondsSinceEpoch.toString(), title: title, description: desc, deadline: deadline, priority: priority));
    _save();
    notifyListeners();
  }

  void toggle(String id) {
    _tasks.firstWhere((t) => t.id == id).isDone = !_tasks.firstWhere((t) => t.id == id).isDone;
    _save();
    notifyListeners();
  }

  void delete(String id) {_tasks.removeWhere((t) => t.id == id); _save(); notifyListeners();}
  void setFilter(String f) {_filter = f; notifyListeners();}
}
