class AppNotification {
  int? id;
  int? taskId;
  int? subtaskId;
  String notifyTime;
  int type;
  int isSent;

  AppNotification({
    this.id,
    this.taskId,
    this.subtaskId,
    required this.notifyTime,
    required this.type,
    this.isSent = 0,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'task_id': taskId,
    'subtask_id': subtaskId,
    'notify_time': notifyTime,
    'type': type,
    'is_sent': isSent,
  };

  factory AppNotification.fromMap(Map<String, dynamic> map) {
    return AppNotification(
      id: map['id'],
      taskId: map['task_id'],
      subtaskId: map['subtask_id'],
      notifyTime: map['notify_time'],
      type: map['type'],
      isSent: map['is_sent'],
    );
  }
}