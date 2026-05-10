// task_tile.dart - Карточка задачи с раскрывающимся описанием
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../services/task_manager.dart';
import 'task_dialog.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  const TaskTile({super.key, required this.task});

  void _showSnack(BuildContext ctx, String msg) {
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: Colors.green,
      duration: const Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ExpansionTile(
        // Чекбокс отмечает задачу выполненной
        leading: Checkbox(
          value: task.isDone,
          onChanged: (_) {
            final q = context.read<TaskManager>().toggle(task.id);
            if (q.isNotEmpty) _showSnack(context, q);
          },
        ),
        // Строка заголовка: название + метка приоритета
        title: Row(children: [
          Expanded(child: Text(task.title, style: TextStyle(
            decoration: task.isDone ? TextDecoration.lineThrough : null,
          ))), //Стиль текста
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: task.priorityColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(task.priorityLabel, style: TextStyle(
              color: task.priorityColor, fontWeight: FontWeight.bold, fontSize: 12,
            )),
          ),
        ]),
        // Дедлайн (красный если просрочен)
        subtitle: task.deadline == null ? null : Text(
          DateFormat('dd.MM.yy HH:mm').format(task.deadline!),
          style: TextStyle(
            color: task.isOverdue ? Colors.red : Colors.grey, fontSize: 12),
        ),
        // Раскрытая секция: описание + кнопки редактировать / удалить
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 8, 8),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: task.description != null
                ? Text(task.description!, style: const TextStyle(fontSize: 14))
                : const Text('Описание не указано',
                    style: TextStyle(color: Colors.grey, fontSize: 14))),
              IconButton(
                icon: const Icon(Icons.edit, size: 20),
                tooltip: 'Редактировать',
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => TaskDialog(task: task)),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                tooltip: 'Удалить',
                onPressed: () => context.read<TaskManager>().delete(task.id),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
