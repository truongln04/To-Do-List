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

  factory Task.fromMap(Map<String, dynamic> m) => Task(
    id: m['id'],
    title: m['title'],
    description: m['description'],
    deadline: m['deadline'],
    priority: m['priority'],
    categoryId: m['category_id'],
    categoryName: m['categoryName'],
    categoryIcon: m['categoryIcon'],
    progress: m['progress'],
    status: m['status'],
    isReminder: m['is_reminder'],
    reminderTime: m['reminder_time'],
  );
}