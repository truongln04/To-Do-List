class SubTask {
  int? id;
  int taskId;
  String title;
  String? description;
  String? deadline;

  int isDone;

  int isReminder; // 👈 thêm
  String? reminderTime;

  SubTask({
    this.id,
    required this.taskId,
    required this.title,
    this.description,
    this.deadline,
    this.isDone = 0,
    this.isReminder = 0,
    this.reminderTime,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'task_id': taskId,
    'title': title,
    'description': description,
    'deadline': deadline,
    'is_done': isDone,
    'is_reminder': isReminder,
    'reminder_time': reminderTime,
  };

  factory SubTask.fromMap(Map<String, dynamic> m) => SubTask(
    id: m['id'],
    taskId: m['task_id'],
    title: m['title'],
    description: m['description'],
    deadline: m['deadline'],
    isDone: m['is_done'],
    isReminder: m['is_reminder'],
    reminderTime: m['reminder_time'],
  );
}