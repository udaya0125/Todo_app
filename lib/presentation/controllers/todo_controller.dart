import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../data/models/todo_task.dart';
import '../../data/services/todo_local_storage.dart';

enum TaskFilter { all, completed, pending }

enum TaskSort { createdDate, completionStatus }

class TodoController extends ChangeNotifier {
  TodoController(this._storageService);

  final TodoLocalStorageService _storageService;
  final List<TodoTask> _tasks = <TodoTask>[];

  bool _isLoading = true;
  TaskFilter _activeFilter = TaskFilter.all;
  TaskSort _activeSort = TaskSort.createdDate;

  bool get isLoading => _isLoading;
  TaskFilter get activeFilter => _activeFilter;
  TaskSort get activeSort => _activeSort;
  int get totalCount => _tasks.length;
  int get completedCount => _tasks.where((task) => task.isCompleted).length;
  int get pendingCount => _tasks.where((task) => !task.isCompleted).length;

  List<TodoTask> get visibleTasks {
    final filteredTasks = _applyFilter(_tasks);
    return _applySort(filteredTasks);
  }

  Future<void> initialize() async {
    try {
      final savedTasks = await _storageService.loadTasks();
      _tasks
        ..clear()
        ..addAll(savedTasks);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setFilter(TaskFilter filter) {
    if (_activeFilter == filter) {
      return;
    }
    _activeFilter = filter;
    notifyListeners();
  }

  void setSort(TaskSort sort) {
    if (_activeSort == sort) {
      return;
    }
    _activeSort = sort;
    notifyListeners();
  }

  Future<void> addTask({
    required String title,
    required String description,
  }) async {
    final now = DateTime.now();
    final task = TodoTask(
      id: _generateId(now),
      title: title.trim(),
      description: description.trim(),
      createdDate: now,
      completedDate: null,
      isCompleted: false,
    );
    _tasks.insert(0, task);
    await _persistAndNotify();
  }

  Future<void> updateTask({
    required String id,
    required String title,
    required String description,
  }) async {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index == -1) {
      return;
    }

    final currentTask = _tasks[index];
    _tasks[index] = currentTask.copyWith(
      title: title.trim(),
      description: description.trim(),
    );
    await _persistAndNotify();
  }

  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((task) => task.id == id);
    await _persistAndNotify();
  }

  Future<void> setTaskCompletion({
    required String id,
    required bool isCompleted,
  }) async {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index == -1) {
      return;
    }

    final currentTask = _tasks[index];
    _tasks[index] = currentTask.copyWith(
      isCompleted: isCompleted,
      completedDate: isCompleted ? DateTime.now() : null,
      clearCompletedDate: !isCompleted,
    );
    await _persistAndNotify();
  }

  List<TodoTask> _applyFilter(List<TodoTask> source) {
    switch (_activeFilter) {
      case TaskFilter.all:
        return List<TodoTask>.from(source);
      case TaskFilter.completed:
        return source
            .where((task) => task.isCompleted)
            .toList(growable: false);
      case TaskFilter.pending:
        return source
            .where((task) => !task.isCompleted)
            .toList(growable: false);
    }
  }

  List<TodoTask> _applySort(List<TodoTask> source) {
    final sortedTasks = List<TodoTask>.from(source);
    switch (_activeSort) {
      case TaskSort.createdDate:
        sortedTasks.sort((a, b) => b.createdDate.compareTo(a.createdDate));
        break;
      case TaskSort.completionStatus:
        sortedTasks.sort((a, b) {
          if (a.isCompleted == b.isCompleted) {
            return b.createdDate.compareTo(a.createdDate);
          }
          return a.isCompleted ? 1 : -1;
        });
        break;
    }
    return sortedTasks;
  }

  Future<void> _persistAndNotify() async {
    await _storageService.saveTasks(_tasks);
    notifyListeners();
  }

  String _generateId(DateTime timestamp) {
    final random = Random().nextInt(999999).toString().padLeft(6, '0');
    return '${timestamp.microsecondsSinceEpoch}_$random';
  }
}
