import 'package:flutter/material.dart';
import 'models.dart';

// Цветной бейдж приоритета (MAX / MED / MIN)
class PriorityBadge extends StatelessWidget {
  final Task t;
  const PriorityBadge(this.t, {super.key});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: t.color.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(8)),
    child: Text(t.label,
      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: t.color)));
}

// Кнопка-чип выбора приоритета в диалоге
class PriorityChip extends StatelessWidget {
  final Priority value;
  final Priority selected;
  final ValueChanged<Priority> onTap;
  const PriorityChip(this.value, {required this.selected, required this.onTap, super.key});

  static const _labels = ['MAX', 'MED', 'MIN'];
  static const _colors = [Colors.red, Colors.orange, Colors.green];

  @override
  Widget build(BuildContext context) {
    final c = _colors[value.index];
    final sel = value == selected;
    return GestureDetector(
      onTap: () => onTap(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: sel ? c.withValues(alpha: .2) : Colors.transparent,
          border: Border.all(color: c, width: sel ? 2 : 1),
          borderRadius: BorderRadius.circular(20)),
        child: Text(_labels[value.index],
          style: TextStyle(fontSize: 12, color: c,
            fontWeight: sel ? FontWeight.bold : FontWeight.normal))));
  }
}
