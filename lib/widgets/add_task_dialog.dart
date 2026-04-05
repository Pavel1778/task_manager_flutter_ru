import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../services/task_manager.dart';

// Диалог добавления новой задачи
class AddTaskDialog extends StatefulWidget {
  const AddTaskDialog({super.key});

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  DateTime? _deadline;
  TaskPriority _priority = TaskPriority.min;

  // Выбор даты и времени
  Future<void> _pickDateTime() async {
    final date = await showDatePicker(context: context, initialDate: DateTime.now(),
      firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
    if (date != null && mounted) {
      final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
      if (time != null && mounted) {
        setState(() => _deadline = DateTime(date.year, date.month, date.day, time.hour, time.minute));
      }
    }
  }

  // Сохранение задачи
  void _submit() {
    if (_titleCtrl.text.trim().isNotEmpty) {
      context.read<TaskManager>().add(_titleCtrl.text.trim(),
        _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(), _deadline, _priority);
      Navigator.pop(context);
    }
  }

  // Элемент приоритета
  DropdownMenuItem<TaskPriority> _buildPriorityItem(TaskPriority p, String label, Color color) =>
    DropdownMenuItem<TaskPriority>(value: p, child: Row(children: [
      Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 8), Text(label),
    ]));

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(children: [Icon(Icons.add_task, size: 24), SizedBox(width: 12), Text('Новая задача')]),
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: _titleCtrl, decoration: const InputDecoration(
            labelText: 'Название *', border: OutlineInputBorder(), prefixIcon: Icon(Icons.title)), autofocus: true),
          const SizedBox(height: 16),
          TextField(controller: _descCtrl, decoration: const InputDecoration(
            labelText: 'Описание', border: OutlineInputBorder(), prefixIcon: Icon(Icons.notes)), maxLines: 3),
          const SizedBox(height: 16),
          InkWell(onTap: _pickDateTime, child: InputDecorator(
            decoration: const InputDecoration(border: OutlineInputBorder(), prefixIcon: Icon(Icons.calendar_today)),
            child: Text(_deadline == null ? 'Срок не установлен'
              : '${_deadline!.day}.${_deadline!.month}.${_deadline!.year} ${_deadline!.hour}:${_deadline!.minute.toString().padLeft(2, '0')}'))),
          const SizedBox(height: 16),
          DropdownButtonFormField<TaskPriority>(initialValue: _priority, decoration: const InputDecoration(
            labelText: 'Приоритет', border: OutlineInputBorder(), prefixIcon: Icon(Icons.flag)),
            items: [_buildPriorityItem(TaskPriority.max, 'Высокий', Colors.red),
              _buildPriorityItem(TaskPriority.med, 'Средний', Colors.orange),
              _buildPriorityItem(TaskPriority.min, 'Низкий', Colors.green)],
            onChanged: (v) => setState(() => _priority = v!)),
        ]),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
        ElevatedButton.icon(onPressed: _submit, icon: const Icon(Icons.check), label: const Text('Создать')),
      ],
    );
  }
}
