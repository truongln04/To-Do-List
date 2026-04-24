class Task {
  int? id;
  String title;
  String? description;
  String? deadline;
  int priority;
  int? categoryId;
  String? categoryName;
  String? categoryIcon;
  int progress;
  int status;

  int isReminder; // 👈 quan trọng
  String? reminderTime;

  Task({
    this.id,
    required this.title,
    this.description,
    this.deadline,
    this.priority = 2,
    this.categoryId,
    this.progress = 0,
    this.status = 0,
    this.isReminder = 0,
    this.reminderTime,
    this.categoryName,
    this.categoryIcon,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'description': description,
    'deadline': deadline,
    'priority': priority,
    'category_id': categoryId,
    'progress': progress,
    'status': status,
    'is_reminder': isReminder,
    'reminder_time': reminderTime,
  };

  // factory Task.fromMap(Map<String, dynamic> m) {
  //   return Task(
  //     id: m['id'] is int ? m['id'] : int.tryParse(m['id']?.toString() ?? ''),
  //     title: m['title'] ?? '',
  //     description: m['description'],
  //     deadline: m['deadline'],
  //     priority: m['priority'] is int ? m['priority'] : int.tryParse(m['priority']?.toString() ?? '') ?? 2,
  //     categoryId: m['category_id'] is int ? m['category_id'] : int.tryParse(m['category_id']?.toString() ?? ''),
  //     categoryName: m['categoryName'],
  //     categoryIcon: m['categoryIcon'],
  //     progress: m['progress'] is int ? m['progress'] : int.tryParse(m['progress']?.toString() ?? '') ?? 0,
  //     status: m['status'] is int ? m['status'] : int.tryParse(m['status']?.toString() ?? '') ?? 0,
  //     isReminder: m['is_reminder'] is int ? m['is_reminder'] : int.tryParse(m['is_reminder']?.toString() ?? '') ?? 0,
  //     reminderTime: m['reminder_time'],
  //   );
  // }
  factory Task.fromMap(Map<String, dynamic> m) {
    int? _parseInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      return int.tryParse(v.toString());
    }

    return Task(
      id: _parseInt(m['id'] ?? m['taskId']),
      title: m['title']?.toString() ?? '',
      description: m['description']?.toString(),
      deadline: m['deadline']?.toString(),
      priority: _parseInt(m['priority']) ?? 2,
      categoryId: _parseInt(m['category_id'] ?? m['categoryId']),
      categoryName: m['categoryName']?.toString() ?? m['category_name']?.toString(),
      categoryIcon: m['categoryIcon']?.toString(),
      progress: _parseInt(m['progress']) ?? 0,
      status: _parseInt(m['status']) ?? 0,
      isReminder: _parseInt(m['is_reminder']) ?? 0,
      reminderTime: m['reminder_time']?.toString(),
    );
  }

}