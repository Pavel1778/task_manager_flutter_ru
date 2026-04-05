import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../services/task_manager.dart';

// Виджет одной задачи в списке
class TaskTile extends StatelessWidget {
  final Task task;
  const TaskTile({super.key, required this.task});

  // Показ мотивации при выполнении задачи
  void _showMotivation(BuildContext ctx, String msg) {
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Row(children: [
      const Icon(Icons.celebration, color: Colors.white), const SizedBox(width: 12),
      Expanded(child: Text(msg, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)))]),
      backgroundColor: Colors.green.shade600, behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      elevation: task.isDone ? 1 : 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Checkbox(value: task.isDone, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          onChanged: (_) { final quote = context.read<TaskManager>().toggle(task.id);
            if (quote.isNotEmpty) _showMotivation(context, quote); }),
        title: Text(task.title, style: TextStyle(decoration: task.isDone ? TextDecoration.lineThrough : null,
          fontWeight: FontWeight.w500, color: task.isDone ? Colors.grey : null)),
        subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (task.description?.isNotEmpty ?? false) Padding(padding: const EdgeInsets.only(top: 4),
            child: Text(task.description!, maxLines: 2, overflow: TextOverflow.ellipsis,
              style: TextStyle(color: task.isDone ? Colors.grey : null))),
          if (task.deadline != null) Padding(padding: const EdgeInsets.only(top: 4), child: Row(children: [
            Icon(Icons.access_time, size: 14, color: task.isOverdue ? Colors.red : Colors.grey), const SizedBox(width: 4),
            Text(DateFormat('dd.MM.yy HH:mm').format(task.deadline!),
              style: TextStyle(color: task.isOverdue ? Colors.red : Colors.grey, fontSize: 12,
                fontWeight: task.isOverdue ? FontWeight.bold : null))])),
        ]),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: task.priorityColor.withValues(alpha: isDark ? 0.3 : 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: task.priorityColor.withValues(alpha: 0.5))),
            child: Text(task.priorityLabel, style: TextStyle(color: task.priorityColor,
              fontWeight: FontWeight.bold, fontSize: 11))),
          IconButton(icon: const Icon(Icons.delete_outline, size: 22), color: Colors.red.shade400,
            onPressed: () => context.read<TaskManager>().delete(task.id)),
        ]),
      ),
    );
  }
}
