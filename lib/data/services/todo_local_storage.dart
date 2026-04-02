import 'package:shared_preferences/shared_preferences.dart';

import '../models/todo_task.dart';

class TodoLocalStorageService {
  TodoLocalStorageService._(this._preferences);

  static const String _tasksKey = 'todo_tasks';
  final SharedPreferences _preferences;

  static Future<TodoLocalStorageService> create() async {
    final preferences = await SharedPreferences.getInstance();
    return TodoLocalStorageService._(preferences);
  }

  Future<List<TodoTask>> loadTasks() async {
    final encodedTasks = _preferences.getStringList(_tasksKey);
    if (encodedTasks == null || encodedTasks.isEmpty) {
      return <TodoTask>[];
    }

    return encodedTasks
        .map((entry) {
          try {
            return TodoTask.fromJson(entry);
          } catch (_) {
            return null;
          }
        })
        .whereType<TodoTask>()
        .toList(growable: false);
  }

  Future<void> saveTasks(List<TodoTask> tasks) async {
    final encodedTasks = tasks
        .map((task) => task.toJson())
        .toList(growable: false);
    await _preferences.setStringList(_tasksKey, encodedTasks);
  }
}
