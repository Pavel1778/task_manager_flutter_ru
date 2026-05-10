// task_dialog.dart - Диалог создания / редактирования задачи
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../services/task_manager.dart';

class TaskDialog extends StatefulWidget {
  final Task? task; // null — создание и редактирование
  const TaskDialog({super.key, this.task});
  @override
  State<TaskDialog> createState() => _State();
}

class _State extends State<TaskDialog> {
  late final TextEditingController _title;
  late final TextEditingController _desc;
  DateTime? _dl;
  late TaskPriority _prio;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.task?.title ?? '');
    _desc  = TextEditingController(text: widget.task?.description ?? '');
    _dl    = widget.task?.deadline;
    _prio  = widget.task?.priority ?? TaskPriority.min;
  }

  @override
  void dispose() { _title.dispose(); _desc.dispose(); super.dispose(); }

  // Календарь
  Future<void> _pick() async {
    final d = await showDatePicker(
      context: context, locale: const Locale('ru'),
      initialDate: _dl ?? DateTime.now(), firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)));
    if (d == null || !mounted) return;
    final t = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (t != null && mounted) {
      setState(() => _dl = DateTime(d.year, d.month, d.day, t.hour, t.minute));
    }
  }

  void _submit() {
    if (_title.text.trim().isEmpty) return;
    final m = context.read<TaskManager>();
    final desc = _desc.text.trim().isEmpty ? null : _desc.text.trim();
    widget.task == null
        ? m.add(_title.text.trim(), desc, _dl, _prio)
        : m.edit(widget.task!.id, _title.text.trim(), desc, _dl, _prio);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final dlText = _dl == null ? 'Срок не установлен'
        : '${_dl!.day}.${_dl!.month}.${_dl!.year} '
          '${_dl!.hour.toString().padLeft(2,'0')}:${_dl!.minute.toString().padLeft(2,'0')}';
    return AlertDialog(
      title: Text(widget.task != null ? 'Редактировать' : 'Новая задача'),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: _title,
          decoration: const InputDecoration(labelText: 'Название *')),
        TextField(controller: _desc,
          decoration: const InputDecoration(labelText: 'Описание'), maxLines: 3),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: Text(dlText, style: const TextStyle(fontSize: 13))),
          if (_dl != null) IconButton(icon: const Icon(Icons.clear, size: 18),
            onPressed: () => setState(() => _dl = null)),
          IconButton(icon: const Icon(Icons.calendar_today), onPressed: _pick),
        ]),
        DropdownButtonFormField<TaskPriority>(
          initialValue: _prio,
          decoration: const InputDecoration(labelText: 'Приоритет'),
          items: const [
            DropdownMenuItem(value: TaskPriority.max, child: Text('Высокий')),
            DropdownMenuItem(value: TaskPriority.med, child: Text('Средний')),
            DropdownMenuItem(value: TaskPriority.min, child: Text('Низкий')),
          ],
          onChanged: (v) => setState(() => _prio = v!)),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
        ElevatedButton(onPressed: _submit,
          child: Text(widget.task != null ? 'Сохранить' : 'Создать')),
      ],
    );
  }
}
