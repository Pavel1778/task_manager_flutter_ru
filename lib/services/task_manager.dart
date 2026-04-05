import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

class TaskManager extends ChangeNotifier {
  List<Task> _tasks = [];
  String _filter = 'Все';
  String _motivationalQuote = '';
  
  final List<String> _quotes = ['Начни день с достижений! 🌟', 'Шаг к успеху! 💪',
    'Маленькие шаги! 🎯', 'День продуктивности! ⚡', 'Ты можешь больше! 🚀'];
  final List<String> _completionQuotes = ['Отлично! 🎉', 'Великолепно! 🌟',
    'На верном пути! 💪', 'Продолжай! ⭐', 'Молодец! 🎯', 'Супер! 👏'];

  TaskManager() { _updateQuote(); }

  List<Task> get tasks {
    final list = _filter == 'Активные' ? _tasks.where((t) => !t.isDone).toList()
      : _filter == 'Завершённые' ? _tasks.where((t) => t.isDone).toList()
      : _tasks.toList();
    list.sort((a, b) {
      if (a.isDone != b.isDone) return a.isDone ? 1 : -1;
      return b.priority.index.compareTo(a.priority.index);
    });
    return list;
  }

  String get filter => _filter;
  String get motivationalQuote => _motivationalQuote;

  void _updateQuote() => _motivationalQuote = _quotes[Random().nextInt(_quotes.length)];
  String getCompletionQuote() => _completionQuotes[Random().nextInt(_completionQuotes.length)];

  void setFilter(String f) { _filter = f; notifyListeners(); }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('tasks');
    if (data != null) {
      _tasks = (jsonDecode(data) as List).map((e) => Task.fromJson(e)).toList();
      _updateQuote(); notifyListeners();
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tasks', jsonEncode(_tasks.map((e) => e.toJson()).toList()));
  }

  void add(String title, String? desc, DateTime? dl, TaskPriority p) {
    _tasks.add(Task(id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title, description: desc, deadline: dl, priority: p));
    _save(); _updateQuote(); notifyListeners();
  }

  String toggle(String id) {
    final t = _tasks.firstWhere((x) => x.id == id);
    t.isDone = !t.isDone; _save(); notifyListeners();
    return t.isDone ? getCompletionQuote() : '';
  }

  void delete(String id) {
    _tasks.removeWhere((t) => t.id == id);
    _save(); _updateQuote(); notifyListeners();
  }
}
