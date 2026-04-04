class SubTask {
  String title;
  bool done;
  DateTime? dueDate; // 👈 thêm

  SubTask({
    required this.title,
    this.done = false,
    this.dueDate,
  });
}

class Task {
  String title;
  DateTime? dueDate; // 👈 đổi sang DateTime
  String priority;
  bool done;
  List<SubTask> subTasks;

  Task({
    required this.title,
    this.dueDate,
    required this.priority,
    this.done = false,
    this.subTasks = const [],
  });
}