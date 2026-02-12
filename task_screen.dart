import 'package:flutter/material.dart';
import 'task_manager.dart';
import 'theme_provider.dart';
import 'add_task_dialog.dart';
import 'task.dart';

class TaskScreen extends StatefulWidget {
  final ThemeProvider themeProvider;
  const TaskScreen({super.key, required this.themeProvider});
  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final _tm = TaskManager();
  final _q = ['🎉 Отлично!', '✨ Верный путь!', '💪 Продолжайте!', '🌟 Супер!', '🚀 Молодец!'];

  @override
  void initState() {
    super.initState();
    _tm.load();
  }

  void _show(Task t) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(t.title),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (t.description != null) ...[const Text('Описание:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)), const SizedBox(height: 4), Text(t.description!), const SizedBox(height: 12)],
          Row(children: [const Icon(Icons.flag, size: 16), const SizedBox(width: 8), Text('Приоритет: ${t.priorityLabel}', style: TextStyle(color: t.priorityColor, fontWeight: FontWeight.bold))]),
          const SizedBox(height: 8),
          Row(children: [const Icon(Icons.calendar_today, size: 16), const SizedBox(width: 8), Expanded(child: Text('Дедлайн: ${t.formatFull()}'))]),
        ]),
        actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('Закрыть'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.themeProvider.isDark;
    return Scaffold(
      appBar: AppBar(title: const Text('Менеджер задач'), actions: [IconButton(icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode), onPressed: widget.themeProvider.toggleTheme)]),
      body: ListenableBuilder(
        listenable: _tm,
        builder: (c, _) => Column(children: [
          Padding(padding: const EdgeInsets.all(12), child: Column(children: [
            Text('Всего: ${_tm.totalCount} | Выполнено: ${_tm.completedCount} | Активно: ${_tm.activeCount} | ${_tm.percent}%', style: const TextStyle(fontSize: 11)),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: ['Все', 'Активные', 'Выполненные'].map((f) => ChoiceChip(label: Text(f, style: const TextStyle(fontSize: 11)), selected: _tm.filter == f, onSelected: (_) => _tm.setFilter(f))).toList()),
          ])),
          Expanded(child: _tm.tasks.isEmpty ? const Center(child: Text('Нет задач')) : ListView.builder(
            itemCount: _tm.tasks.length,
            itemBuilder: (c, i) {
              final t = _tm.tasks[i];
              return ListTile(
                onTap: () => _show(t),
                leading: Checkbox(value: t.isDone, onChanged: (_) {_tm.toggle(t.id); if (t.isDone) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text((_q..shuffle()).first, style: TextStyle(color: isDark ? Colors.white : Colors.black)), backgroundColor: isDark ? const Color(0xFF1F1F1F) : Colors.white, duration: const Duration(seconds: 2)));}),
                title: Text(t.title, style: TextStyle(decoration: t.isDone ? TextDecoration.lineThrough : null, fontSize: 14, fontWeight: FontWeight.w500)),
                subtitle: t.deadline != null ? Text('📅 ${t.formatDeadline()}', style: const TextStyle(fontSize: 11)) : null,
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: t.priorityColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)), child: Text(t.priorityLabel, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: t.priorityColor))),
                  const SizedBox(width: 8),
                  IconButton(icon: const Icon(Icons.delete, size: 20), onPressed: () => _tm.delete(t.id)),
                ]),
              );
            },
          )),
        ]),
      ),
      floatingActionButton: FloatingActionButton(onPressed: () => showDialog(context: context, builder: (c) => AddTaskDialog(onAdd: _tm.add)), child: const Icon(Icons.add)),
    );
  }
}
