import 'dart:convert';

class TodoTask {
  const TodoTask({
    required this.id,
    required this.title,
    required this.description,
    required this.createdDate,
    this.completedDate,
    required this.isCompleted,
  });

  final String id;
  final String title;
  final String description;
  final DateTime createdDate;
  final DateTime? completedDate;
  final bool isCompleted;

  TodoTask copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? createdDate,
    DateTime? completedDate,
    bool? isCompleted,
    bool clearCompletedDate = false,
  }) {
    return TodoTask(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdDate: createdDate ?? this.createdDate,
      completedDate: clearCompletedDate
          ? null
          : completedDate ?? this.completedDate,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdDate': createdDate.toIso8601String(),
      'completedDate': completedDate?.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }

  factory TodoTask.fromMap(Map<String, dynamic> map) {
    final completedRaw = map['isCompleted'];
    final completed = completedRaw is bool
        ? completedRaw
        : completedRaw.toString().toLowerCase() == 'true';

    return TodoTask(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      createdDate:
          DateTime.tryParse(map['createdDate']?.toString() ?? '') ??
              DateTime.now(),
      completedDate: map['completedDate'] == null
          ? null
          : DateTime.tryParse(map['completedDate'].toString()),
      isCompleted: completed,
    );
  }

  String toJson() => jsonEncode(toMap());

  factory TodoTask.fromJson(String source) {
    return TodoTask.fromMap(jsonDecode(source) as Map<String, dynamic>);
  }
}
