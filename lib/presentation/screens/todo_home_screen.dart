import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/todo_task.dart';
import '../controllers/todo_controller.dart';
import '../widgets/task_card.dart';
import '../widgets/task_empty_state.dart';
import 'task_editor_screen.dart';

class TodoHomeScreen extends StatefulWidget {
  const TodoHomeScreen({super.key});

  @override
  State<TodoHomeScreen> createState() => _TodoHomeScreenState();
}

class _TodoHomeScreenState extends State<TodoHomeScreen> {
  Future<void> _openTaskEditor({TodoTask? task}) async {
    final result = await Navigator.of(context).push<TaskEditorResult>(
      MaterialPageRoute<TaskEditorResult>(
        builder: (_) => TaskEditorScreen(task: task),
      ),
    );

    if (!mounted || result == null) {
      return;
    }

    final controller = context.read<TodoController>();
    try {
      if (task == null) {
        await controller.addTask(
          title: result.title,
          description: result.description,
        );
        _showMessage('Task created.');
      } else {
        await controller.updateTask(
          id: task.id,
          title: result.title,
          description: result.description,
        );
        _showMessage('Task updated.');
      }
    } catch (_) {
      _showMessage('Could not save task. Try again.');
    }
  }

  Future<void> _deleteTask(TodoTask task) async {
    try {
      await context.read<TodoController>().deleteTask(task.id);
      _showMessage('Task deleted.');
    } catch (_) {
      _showMessage('Could not delete task.');
    }
  }

  Future<void> _toggleTaskCompletion(TodoTask task) async {
    final nextValue = !task.isCompleted;
    try {
      await context.read<TodoController>().setTaskCompletion(
            id: task.id,
            isCompleted: nextValue,
          );
      _showMessage(nextValue ? 'Task completed.' : 'Task marked pending.');
    } catch (_) {
      _showMessage('Could not update task status.');
    }
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo Flow'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openTaskEditor,
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ),
      body: SafeArea(
        child: Consumer<TodoController>(
          builder: (context, controller, _) {
            if (controller.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final tasks = controller.visibleTasks;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _TaskSummary(controller: controller),
                      const SizedBox(height: 12),
                      _FilterAndSortBar(controller: controller),
                      const SizedBox(height: 12),
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          switchInCurve: Curves.easeOutCubic,
                          switchOutCurve: Curves.easeInCubic,
                          child: tasks.isEmpty
                              ? TaskEmptyState(
                                  key: const ValueKey<String>('empty_state'),
                                  onCreateTask: _openTaskEditor,
                                )
                              : ListView.separated(
                                  key: const ValueKey<String>('task_list'),
                                  itemCount: tasks.length,
                                  padding: const EdgeInsets.only(bottom: 100),
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 10),
                                  itemBuilder: (context, index) {
                                    final task = tasks[index];
                                    return Dismissible(
                                      key: ValueKey<String>(task.id),
                                      direction: DismissDirection.endToStart,
                                      background: const _DeleteBackground(),
                                      onDismissed: (_) => _deleteTask(task),
                                      child: TaskCard(
                                        task: task,
                                        onToggleCompletion: () =>
                                            _toggleTaskCompletion(task),
                                        onEdit: () => _openTaskEditor(task: task),
                                        onDelete: () => _deleteTask(task),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TaskSummary extends StatelessWidget {
  const _TaskSummary({
    required this.controller,
  });

  final TodoController controller;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final useColumn = constraints.maxWidth < 420;
            if (useColumn) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SummaryTile(
                    label: 'Total',
                    value: controller.totalCount.toString(),
                  ),
                  const Divider(height: 18),
                  _SummaryTile(
                    label: 'Pending',
                    value: controller.pendingCount.toString(),
                  ),
                  const Divider(height: 18),
                  _SummaryTile(
                    label: 'Completed',
                    value: controller.completedCount.toString(),
                  ),
                ],
              );
            }

            return Row(
              children: [
                Expanded(
                  child: _SummaryTile(
                    label: 'Total',
                    value: controller.totalCount.toString(),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _SummaryTile(
                    label: 'Pending',
                    value: controller.pendingCount.toString(),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _SummaryTile(
                    label: 'Completed',
                    value: controller.completedCount.toString(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _FilterAndSortBar extends StatelessWidget {
  const _FilterAndSortBar({
    required this.controller,
  });

  final TodoController controller;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useColumn = constraints.maxWidth < 700;
        final sortField = SizedBox(
          width: useColumn ? double.infinity : 250,
          child: DropdownButtonFormField<TaskSort>(
            value: controller.activeSort,
            decoration: const InputDecoration(
              labelText: 'Sort by',
              prefixIcon: Icon(Icons.sort),
            ),
            items: TaskSort.values
                .map(
                  (sort) => DropdownMenuItem<TaskSort>(
                    value: sort,
                    child: Text(_sortLabel(sort)),
                  ),
                )
                .toList(growable: false),
            onChanged: (value) {
              if (value != null) {
                controller.setSort(value);
              }
            },
          ),
        );

        final filters = Wrap(
          spacing: 8,
          runSpacing: 8,
          children: TaskFilter.values
              .map(
                (filter) => ChoiceChip(
                  label: Text(_filterLabel(filter)),
                  selected: controller.activeFilter == filter,
                  onSelected: (_) => controller.setFilter(filter),
                ),
              )
              .toList(growable: false),
        );

        if (useColumn) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              filters,
              const SizedBox(height: 10),
              sortField,
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: filters),
            const SizedBox(width: 12),
            sortField,
          ],
        );
      },
    );
  }

  String _filterLabel(TaskFilter filter) {
    switch (filter) {
      case TaskFilter.all:
        return 'All';
      case TaskFilter.completed:
        return 'Completed';
      case TaskFilter.pending:
        return 'Pending';
    }
  }

  String _sortLabel(TaskSort sort) {
    switch (sort) {
      case TaskSort.createdDate:
        return 'Created Date';
      case TaskSort.completionStatus:
        return 'Completion Status';
    }
  }
}

class _DeleteBackground extends StatelessWidget {
  const _DeleteBackground();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        Icons.delete_outline_rounded,
        color: colorScheme.onErrorContainer,
      ),
    );
  }
}
