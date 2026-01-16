class Task {
  final int? id;
  final int userId;
  final String title;
  final String? description;
  final String taskType; // daily, weekly, monthly, yearly
  final bool isCompleted;
  final String? dueDate;
  final String? createdAt;

  Task({
    this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.taskType,
    this.isCompleted = false,
    this.dueDate,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'task_type': taskType,
      'is_completed': isCompleted ? 1 : 0,
      'due_date': dueDate,
      'created_at': createdAt ?? DateTime.now().toIso8601String(),
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      title: map['title'] as String,
      description: map['description'] as String?,
      taskType: map['task_type'] as String,
      isCompleted: (map['is_completed'] as int) == 1,
      dueDate: map['due_date'] as String?,
      createdAt: map['created_at'] as String?,
    );
  }

  Task copyWith({
    int? id,
    int? userId,
    String? title,
    String? description,
    String? taskType,
    bool? isCompleted,
    String? dueDate,
    String? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      taskType: taskType ?? this.taskType,
      isCompleted: isCompleted ?? this.isCompleted,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
