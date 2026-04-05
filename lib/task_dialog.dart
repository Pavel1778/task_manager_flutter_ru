import 'package:flutter/material.dart';
import 'models.dart';
import 'widgets.dart';

class TaskDialog extends StatefulWidget {
  final Task? task;
  final void Function(Task) onSave;
  const TaskDialog({super.key, this.task, required this.onSave});
  @override State<TaskDialog> createState() => _State();
}

class _State extends State<TaskDialog> {
  late final _title = TextEditingController(text: widget.task?.title ?? '');
  late final _desc  = TextEditingController(text: widget.task?.description ?? '');
  late DateTime? _dl = widget.task?.deadline;
  late Priority  _p  = widget.task?.priority ?? Priority.medium;
  bool _tErr = false, _dErr = false;

  @override void dispose() { _title.dispose(); _desc.dispose(); super.dispose(); }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = await showDatePicker(
      context: context, locale: const Locale('ru'),
      initialDate: (_dl?.isAfter(today) ?? false) ? _dl! : today,
      firstDate: today, lastDate: now.add(const Duration(days: 730)));
    if (d == null || !mounted) return;
    final t = await showTimePicker(
      context: context,
      initialTime: _dl != null ? TimeOfDay.fromDateTime(_dl!) : TimeOfDay.now(),
      builder: (c, w) => MediaQuery(
        data: MediaQuery.of(c).copyWith(alwaysUse24HourFormat: true), child: w!));
    if (t != null) setState(() { _dl = DateTime(d.year, d.month, d.day, t.hour, t.minute); _dErr = false; });
  }

  void _submit() {
    final title = _title.text.trim();
    final badDl = _dl != null && _dl!.isBefore(DateTime.now());
    if (title.isEmpty || badDl) { setState(() { _tErr = title.isEmpty; _dErr = badDl; }); return; }
    widget.onSave(Task(id: widget.task?.id, title: title,
      description: _desc.text.trim(), isDone: widget.task?.isDone ?? false, deadline: _dl, priority: _p));
    Navigator.pop(context);
  }

  static String _p2(int n) => n.toString().padLeft(2, '0');
  String get _dlLabel => _dl == null ? 'Установить дедлайн'
    : '${_p2(_dl!.day)}.${_p2(_dl!.month)}.${_dl!.year} ${_p2(_dl!.hour)}:${_p2(_dl!.minute)}';

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.task == null ? 'Новая задача' : 'Редактировать'),
    content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
      TextField(controller: _title, autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        onChanged: (_) { if (_tErr) setState(() => _tErr = false); },
        decoration: InputDecoration(labelText: 'Название',
          errorText: _tErr ? 'Введите название' : null)),
      const SizedBox(height: 10),
      TextField(controller: _desc, maxLines: 2,
        textCapitalization: TextCapitalization.sentences,
        decoration: const InputDecoration(labelText: 'Описание (необязательно)')),
      const SizedBox(height: 12),
      Align(alignment: Alignment.centerLeft,
        child: Text('Приоритет:', style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor))),
      const SizedBox(height: 8),
      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: Priority.values.map((p) =>
          PriorityChip(p, selected: _p, onTap: (v) => setState(() => _p = v))).toList()),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: OutlinedButton.icon(
          onPressed: _pickDate,
          icon: Icon(Icons.calendar_today, size: 16, color: _dErr ? Colors.red : null),
          label: Text(_dlLabel, style: TextStyle(fontSize: 12, color: _dErr ? Colors.red : null)),
          style: _dErr ? OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)) : null)),
        if (_dl != null) IconButton(icon: const Icon(Icons.clear, size: 18),
          onPressed: () => setState(() { _dl = null; _dErr = false; })),
      ]),
      if (_dErr) const Align(alignment: Alignment.centerLeft,
        child: Padding(padding: EdgeInsets.only(top: 4),
          child: Text('Дедлайн не может быть в прошлом',
            style: TextStyle(color: Colors.red, fontSize: 12)))),
    ])),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
      FilledButton(onPressed: _submit,
        child: Text(widget.task == null ? 'Добавить' : 'Сохранить')),
    ]);
}
