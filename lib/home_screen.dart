import 'package:flutter/material.dart';
import 'models.dart';
import 'widgets.dart';
import 'task_dialog.dart';
import 'calendar_screen.dart';

// TaskManager.add теперь принимает Task-объект целиком.
// При редактировании — удаляем старую запись и добавляем обновлённую.
void _dialog(BuildContext ctx, TaskManager tm, {Task? task}) => showDialog(
  context: ctx,
  builder: (_) => TaskDialog(
    task: task,
    onSave: (t) { if (task != null) tm.delete(task.id); tm.add(t); }));

class HomeScreen extends StatelessWidget {
  final TaskManager tm;
  const HomeScreen({super.key, required this.tm});

  @override
  Widget build(BuildContext ctx) => Scaffold(
    appBar: AppBar(
      title: const Text('Менеджер задач'),
      actions: [
        IconButton(icon: const Icon(Icons.calendar_month),
          onPressed: () => Navigator.push(ctx,
            MaterialPageRoute(builder: (_) => CalendarScreen(tm: tm)))),
        ListenableBuilder(listenable: tm, builder: (_, __) => IconButton(
          icon: Icon(tm.isDark ? Icons.light_mode : Icons.dark_mode),
          onPressed: tm.toggleTheme)),
      ],
    ),
    body: ListenableBuilder(
      listenable: tm,
      builder: (_, __) => Column(children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ['Все', 'Активные', 'Выполненные'].map((f) => ChoiceChip(
              label: Text(f, style: const TextStyle(fontSize: 11)),
              selected: tm.filter == f,
              onSelected: (_) => tm.setFilter(f))).toList())),
        Expanded(child: tm.tasks.isEmpty
          ? const Center(child: Text('Нет задач 🎉',
              style: TextStyle(color: Colors.grey, fontSize: 16)))
          : ListView.builder(itemCount: tm.tasks.length,
              itemBuilder: (c, i) => _Tile(t: tm.tasks[i], tm: tm,
                onEdit: () => _dialog(c, tm, task: tm.tasks[i])))),
      ]),
    ),
    floatingActionButton: Builder(builder: (c) => FloatingActionButton(
      onPressed: () => _dialog(c, tm), child: const Icon(Icons.add))),
  );
}

class _Tile extends StatelessWidget {
  final Task t;
  final TaskManager tm;
  final VoidCallback onEdit;
  const _Tile({required this.t, required this.tm, required this.onEdit});

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    color: t.isOverdue ? Colors.red.withValues(alpha: 0.08) : null,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
      side: t.isOverdue ? const BorderSide(color: Colors.red, width: 0.8) : BorderSide.none),
    child: ListTile(
      leading: Checkbox(value: t.isDone, onChanged: (_) => tm.toggle(t.id)),
      title: Text(t.title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500,
        decoration: t.isDone ? TextDecoration.lineThrough : null,
        color: t.isOverdue ? Colors.red : t.isDone ? Colors.grey : null)),
      subtitle: t.deadline != null
        ? Text(t.isOverdue ? '⚠ ${t.deadlineText}' : t.deadlineText,
            style: TextStyle(fontSize: 11, color: t.isOverdue ? Colors.red : Colors.grey))
        : null,
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        PriorityBadge(t),
        IconButton(icon: const Icon(Icons.edit_outlined, size: 18), onPressed: onEdit),
        IconButton(icon: const Icon(Icons.delete_outline, size: 20),
          onPressed: () => tm.delete(t.id)),
      ])));
}
