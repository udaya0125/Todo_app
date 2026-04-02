import 'package:flutter/material.dart';

import '../../data/models/todo_task.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.onToggleCompletion,
    required this.onEdit,
    required this.onDelete,
  });

  final TodoTask task;
  final VoidCallback onToggleCompletion;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final titleStyle = theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w700,
      decoration:
          task.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
      color: task.isCompleted
          ? colorScheme.onSurfaceVariant
          : colorScheme.onSurface,
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(task.isCompleted ? 0.02 : 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Card(
        color: task.isCompleted
            ? colorScheme.surfaceContainerHighest.withOpacity(0.65)
            : colorScheme.surface,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton.filledTonal(
                onPressed: onToggleCompletion,
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) =>
                      ScaleTransition(scale: animation, child: child),
                  child: Icon(
                    task.isCompleted
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    key: ValueKey<bool>(task.isCompleted),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: titleStyle ?? const TextStyle(),
                      child: Text(task.title),
                    ),
                    if (task.description.trim().isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        task.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _MetaChip(
                          icon: Icons.schedule_outlined,
                          label: 'Created ${_formatDateTime(context, task.createdDate)}',
                          color: colorScheme.surfaceContainerHighest,
                          iconColor: colorScheme.onSurfaceVariant,
                        ),
                        if (task.completedDate != null)
                          _MetaChip(
                            icon: Icons.verified_outlined,
                            label: 'Done ${_formatDateTime(context, task.completedDate!)}',
                            color: colorScheme.primaryContainer,
                            iconColor: colorScheme.primary,
                          )
                        else
                          _MetaChip(
                            icon: Icons.hourglass_bottom_rounded,
                            label: 'Pending',
                            color: colorScheme.secondaryContainer,
                            iconColor: colorScheme.secondary,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Column(
                children: [
                  IconButton(
                    tooltip: 'Edit',
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined),
                  ),
                  IconButton(
                    tooltip: 'Delete',
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline_rounded),
                    color: colorScheme.error,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(BuildContext context, DateTime value) {
    final localizations = MaterialLocalizations.of(context);
    final datePart = localizations.formatMediumDate(value);
    final timePart = localizations.formatTimeOfDay(
      TimeOfDay.fromDateTime(value),
    );
    return '$datePart, $timePart';
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.iconColor,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: iconColor,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
