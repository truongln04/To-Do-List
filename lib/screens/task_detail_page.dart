import 'package:flutter/material.dart';
import '../../models/task_model.dart';
import '../../models/subtask_model.dart';
import 'edit_subtask_page.dart';
import 'edit_task_page.dart';
import 'add_subtask_page.dart';
import '../services/task_service.dart';
import '../services/subtask_service.dart';

class TaskDetailPage extends StatefulWidget {
  final Task task;
  final int categoryId;
  final String categoryName;
  final IconData categoryIcon;

  const TaskDetailPage({
    super.key,
    required this.task,
    required this.categoryId,
    required this.categoryName,
    this.categoryIcon = Icons.work,
  });

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  late Task task;
  List<SubTask> subTasks = [];

  @override
  void initState() {
    super.initState();
    task = widget.task;
    _loadSubTasks();
  }

  Future<void> _loadSubTasks() async {
    subTasks = await SubTaskService.getByTask(task.id!);
    setState(() {});
  }

  Future<void> _updateProgress() async {
    int done = subTasks.where((s) => s.isDone == 1).length;
    int total = subTasks.length;
    task.progress = total == 0 ? 0 : ((done / total) * 100).toInt();
    await TaskService.update(task);
  }

  @override
  Widget build(BuildContext context) {
    final doneCount = subTasks.where((s) => s.isDone == 1).length;
    final totalCount = subTasks.length;

    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      appBar: AppBar(
        title: Text("Chi tiết công việc", style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00C9FF), Color(0xFF92FE9D)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.edit, color: Colors.orange), onPressed: _editTask),
          IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: _deleteTask),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        heroTag: "task_detail_fab",
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: _addSubTask,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// HEADER
            Row(
              children: [
                Checkbox(
                  value: task.status == 1,
                  activeColor: Colors.deepPurple,
                  onChanged: (v) async {
                    task.status = v! ? 1 : 0;
                    await TaskService.update(task);
                    for (var s in subTasks) {
                      s.isDone = task.status;
                      await SubTaskService.update(s);
                    }
                    _loadSubTasks();
                  },
                ),
                Expanded(
                  child: Text(task.title,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                _priorityLabel(task.priority),
              ],
            ),
            const SizedBox(height: 8),

            if (task.description?.isNotEmpty ?? false)
              Text(task.description!, style: const TextStyle(color: Colors.black54)),

            const SizedBox(height: 12),

            if (task.deadline != null)
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: Colors.blue),
                  const SizedBox(width: 4),
                  Text("Hạn: ${_formatDate(task.deadline!)}"),
                ],
              ),

            if (task.reminderTime != null)
              Row(
                children: [
                  const Icon(Icons.alarm, size: 16, color: Colors.orange),
                  const SizedBox(width: 4),
                  Text("Nhắc: ${task.reminderTime}"),
                ],
              ),

            Row(
              children: [
                Icon(widget.categoryIcon, size: 16, color: Colors.purple),
                const SizedBox(width: 4),
                Text("Danh mục: ${widget.categoryName}"),
              ],
            ),

            const SizedBox(height: 16),

            if (totalCount > 0)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Tiến độ $doneCount/$totalCount",
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: doneCount / totalCount,
                    backgroundColor: Colors.grey.shade300,
                    color: Colors.blue,
                  ),
                ],
              ),

            const SizedBox(height: 20),

            if (totalCount > 0)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Công việc con ($totalCount)",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...subTasks.map((sub) => _subTaskItem(sub)).toList(),
                ],
              ),
          ],
        ),
      ),
    );
  }

  /// ====== SUBTASK ITEM ======
  Widget _subTaskItem(SubTask sub) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Checkbox(
          value: sub.isDone == 1,
          activeColor: Colors.deepPurple,
          onChanged: (v) async {
            sub.isDone = v! ? 1 : 0;
            await SubTaskService.update(sub);
            await _updateProgress();
            _loadSubTasks();
          },
        ),
        title: Text(sub.title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (sub.description?.isNotEmpty ?? false)
              Text(sub.description!, style: const TextStyle(color: Colors.black54)),
            if (sub.deadline != null)
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 14, color: Colors.blue),
                  const SizedBox(width: 4),
                  Text("Hạn: ${_formatDate(sub.deadline!)}"),
                ],
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.edit, color: Colors.orange), onPressed: () => _editSubTask(sub)),
            IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteSubTask(sub)),
          ],
        ),
      ),
    );
  }

  /// ====== PRIORITY LABEL ======
  Widget _priorityLabel(int priority) {
    String text;
    Color color;
    IconData icon;
    switch (priority) {
      case 3: text = "Cao"; color = Colors.red; icon = Icons.flash_on; break;
      case 2: text = "Trung bình"; color = Colors.orange; icon = Icons.hourglass_bottom; break;
      case 1: text = "Thấp"; color = Colors.green; icon = Icons.check_circle; break;
      default: text = "Không"; color = Colors.grey; icon = Icons.help_outline;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  String _formatDate(String deadline) {
    final d = DateTime.tryParse(deadline);
    if (d == null) return "";
    return "${d.day}/${d.month}/${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}";
  }

  /// ====== ACTIONS ======
  void _editTask() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditTaskPage(task: task)),
    );
    if (result != null && result is Task) {
      await TaskService.update(result);
      setState(() => task = result);
    }
  }

  void _deleteTask() async {
    await TaskService.delete(task.id!);
    Navigator.pop(context, true);
  }

  void _addSubTask() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddSubTaskPage(parentTask: task)),
    );
    if (result != null && result is SubTask) {
      result.taskId = task.id!;
      await SubTaskService.insert(result);
      _loadSubTasks();
    }
  }

  void _editSubTask(SubTask sub) async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditSubTaskPage(parentTask: task, subTask: sub),
      ),
    );
    if (updated != null && updated is SubTask) {
      await SubTaskService.update(updated);
      await _updateProgress();
      _loadSubTasks();
    }
  }

  void _deleteSubTask(SubTask sub) async {
    await SubTaskService.delete(sub.id!);
    await _updateProgress();
    _loadSubTasks();
  }
}


