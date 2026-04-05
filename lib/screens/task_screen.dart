import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/task_manager.dart';
import '../services/theme_provider.dart';
import '../widgets/task_tile.dart';
import '../widgets/add_task_dialog.dart';

class TaskScreen extends StatelessWidget {
  const TaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Менеджер Задач', 
          style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          Consumer<TaskManager>(
            builder: (context, manager, _) => PopupMenuButton<String>(
              icon: const Icon(Icons.filter_list),
              onSelected: manager.setFilter,
              itemBuilder: (_) => ['Все', 'Активные', 'Завершённые']
                  .map((f) => PopupMenuItem(value: f, child: Text(f)))
                  .toList(),
            ),
          ),
          Consumer<ThemeProvider>(
            builder: (context, theme, _) => IconButton(
              icon: Icon(theme.isDark ? Icons.light_mode : Icons.dark_mode),
              onPressed: theme.toggle,
            ),
          ),
        ],
      ),
      body: Consumer<TaskManager>(
        builder: (context, manager, _) {
          if (manager.tasks.isEmpty) {
            return const Center(
              child: Text('Нет задач', style: TextStyle(fontSize: 18)),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: manager.tasks.length,
            itemBuilder: (context, i) => TaskTile(task: manager.tasks[i]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
          context: context,
          builder: (_) => const AddTaskDialog(),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
