import 'package:flutter/material.dart';
import 'task.dart';

class AddTaskDialog extends StatefulWidget {
  final Function(String, String?, DateTime?, TaskPriority) onAdd;
  const AddTaskDialog({super.key, required this.onAdd});
  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final _title = TextEditingController();
  final _desc = TextEditingController();
  DateTime? _d;
  TaskPriority _p = TaskPriority.medium;

  Future<void> _pick() async {
    final date = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)), locale: const Locale('ru'));
    if (date == null || !mounted) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.now(), builder: (c, child) => MediaQuery(data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true), child: child!));
    if (time != null) setState(() => _d = DateTime(date.year, date.month, date.day, time.hour, time.minute));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Новая задача'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(controller: _title, decoration: const InputDecoration(labelText: 'Название'), autofocus: true),
            const SizedBox(height: 12),
            TextField(controller: _desc, decoration: const InputDecoration(labelText: 'Описание'), maxLines: 2),
            const SizedBox(height: 16),
            const Text('Приоритет:', style: TextStyle(fontSize: 12)),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              _Chip('MAX', TaskPriority.high, _p == TaskPriority.high, () => setState(() => _p = TaskPriority.high)),
              _Chip('MED', TaskPriority.medium, _p == TaskPriority.medium, () => setState(() => _p = TaskPriority.medium)),
              _Chip('MIN', TaskPriority.low, _p == TaskPriority.low, () => setState(() => _p = TaskPriority.low)),
            ]),
            const SizedBox(height: 12),
            SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: _pick, icon: const Icon(Icons.calendar_today, size: 16), label: Text(_d == null ? 'Установить дедлайн' : '${_d!.day.toString().padLeft(2, '0')}.${_d!.month.toString().padLeft(2, '0')}.${_d!.year} ${_d!.hour.toString().padLeft(2, '0')}:${_d!.minute.toString().padLeft(2, '0')}', style: const TextStyle(fontSize: 12)))),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
        TextButton(onPressed: () {if (_title.text.isNotEmpty) widget.onAdd(_title.text, _desc.text.isEmpty ? null : _desc.text, _d, _p); Navigator.pop(context);}, child: const Text('Добавить')),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final TaskPriority p;
  final bool sel;
  final VoidCallback onTap;
  const _Chip(this.label, this.p, this.sel, this.onTap);

  @override
  Widget build(BuildContext context) {
    final c = p == TaskPriority.high ? Colors.red : p == TaskPriority.medium ? Colors.orange : Colors.green;
    return GestureDetector(onTap: onTap, child: Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), decoration: BoxDecoration(color: sel ? c.withValues(alpha: 0.2) : Colors.transparent, border: Border.all(color: c, width: sel ? 2 : 1), borderRadius: BorderRadius.circular(20)), child: Text(label, style: TextStyle(fontSize: 12, fontWeight: sel ? FontWeight.bold : FontWeight.normal, color: c))));
  }
}
