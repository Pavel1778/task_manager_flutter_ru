// task_screen.dart - Главный экран приложения
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/task_manager.dart';
import '../services/theme_provider.dart';
import '../widgets/task_tile.dart';
import '../widgets/task_dialog.dart';

class TaskScreen extends StatelessWidget {
  const TaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Менеджер Задач',
          style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          // Фильтр задач
          Consumer<TaskManager>(
            builder: (context, mgr, _) => PopupMenuButton<String>(
              icon: const Icon(Icons.filter_list),
              onSelected: mgr.setFilter,
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'Все', child: Text('Все')),
                PopupMenuItem(value: 'Активные', child: Text('Активные')),
                PopupMenuItem(value: 'Завершённые', child: Text('Завершённые')),
              ],
            ),
          ),
          // Переключатель темы
          Consumer<ThemeProvider>(
            builder: (context, theme, _) => IconButton(
              icon: Icon(theme.isDark ? Icons.light_mode : Icons.dark_mode),
              onPressed: theme.toggle,
            ),
          ),
        ],
      ),
      body: Consumer<TaskManager>(
        builder: (context, mgr, _) {
          final tasks = mgr.tasks;
          // Пустое состояние
          if (tasks.isEmpty) {
            return Center(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.task_alt, size: 80,
                  color: Colors.grey.withValues(alpha: 0.4)),
                const SizedBox(height: 16),
                Text(
                  mgr.filter == 'Все'
                    ? 'Задач пока нет.\nНажмите + чтобы добавить'
                    : 'Нет задач в этой категории',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.grey)),
              ],
            ));
          }
          // Список задач, отсортированный по приоритету и дедлайну
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: tasks.length,
            itemBuilder: (context, i) => TaskTile(task: tasks[i]),
          );
        },
      ),
      // Открытие диалога добавления задачи
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
          context: context,
          builder: (_) => const TaskDialog()),
        child: const Icon(Icons.add),
      ),
    );
  }
}
