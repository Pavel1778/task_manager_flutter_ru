import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'models.dart';
import 'widgets.dart';

class CalendarScreen extends StatefulWidget {
  final TaskManager tm;
  const CalendarScreen({super.key, required this.tm});
  @override State<CalendarScreen> createState() => _State();
}

class _State extends State<CalendarScreen> {
  DateTime _focused = DateTime.now();
  DateTime? _selected;

  String _fmt(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Календарь задач')),
      body: ListenableBuilder(listenable: widget.tm, builder: (_, __) {
        final tasks = _selected != null ? widget.tm.tasksForDay(_selected!) : <Task>[];
        return Column(children: [
          TableCalendar<Task>(
            locale: 'ru_RU',
            firstDay: DateTime.utc(2020),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focused,
            startingDayOfWeek: StartingDayOfWeek.monday,
            selectedDayPredicate: (d) => _selected != null && isSameDay(d, _selected!),
            eventLoader: widget.tm.tasksForDay,
            onDaySelected: (s, f) => setState(() { _selected = s; _focused = f; }),
            onPageChanged: (f) => setState(() => _focused = f),
            headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.35), shape: BoxShape.circle),
              selectedDecoration: BoxDecoration(color: cs.primary, shape: BoxShape.circle),
              outsideTextStyle: TextStyle(color: Theme.of(context).hintColor.withValues(alpha: 0.35)),
              outsideDecoration: const BoxDecoration(shape: BoxShape.circle)),
            calendarBuilders: CalendarBuilders(
              markerBuilder: (_, __, ev) => ev.isEmpty ? null :
                Positioned(bottom: 4, child: Container(
                  width: 18, height: 18,
                  decoration: BoxDecoration(color: cs.primary, shape: BoxShape.circle),
                  child: Center(child: Text('${ev.length}',
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)))))),
          ),
          if (_selected != null) Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
            child: Align(alignment: Alignment.centerLeft,
              child: Text('${_fmt(_selected!.day)}.${_fmt(_selected!.month)}.${_selected!.year}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)))),
          Expanded(child: _selected == null
            ? const Center(child: Text('Выберите день', style: TextStyle(color: Colors.grey)))
            : tasks.isEmpty
              ? const Center(child: Text('Нет задач на этот день'))
              : ListView.builder(itemCount: tasks.length,
                  itemBuilder: (_, i) => _tile(tasks[i]))),
        ]);
      }),
    );
  }

  Widget _tile(Task t) => ListTile(
    leading: Icon(Icons.circle, size: 12, color: t.color),
    title: Text(t.title, style: TextStyle(
      decoration: t.isDone ? TextDecoration.lineThrough : null,
      color: t.isOverdue ? Colors.red : t.isDone ? Colors.grey : null)),
    subtitle: Text(t.deadlineText,
      style: TextStyle(fontSize: 11, color: t.isOverdue ? Colors.red : Colors.grey)),
    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
      PriorityBadge(t),
      if (t.isOverdue) const Padding(padding: EdgeInsets.only(left: 4),
        child: Icon(Icons.warning_amber_rounded, color: Colors.red, size: 16)),
    ]));
}
