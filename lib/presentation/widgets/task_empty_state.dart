import 'package:flutter/material.dart';

class TaskEmptyState extends StatelessWidget {
  const TaskEmptyState({
    super.key,
    required this.onCreateTask,
  });

  final VoidCallback onCreateTask;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.task_alt_rounded,
                size: 68,
                color: colorScheme.primary.withOpacity(0.85),
              ),
              const SizedBox(height: 14),
              Text(
                'No tasks yet',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Create your first task and keep your day organized.',
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: onCreateTask,
                icon: const Icon(Icons.add_task_outlined),
                label: const Text('Create Task'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
