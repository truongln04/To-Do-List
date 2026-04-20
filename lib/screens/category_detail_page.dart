import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../models/subtask_model.dart';
import '../services/task_service.dart';
import '../services/subtask_service.dart';
import 'add_task_page.dart';
import 'task_detail_page.dart';

class CategoryDetailPage extends StatefulWidget {
  final int categoryId;
  final String categoryName;

  const CategoryDetailPage({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<CategoryDetailPage> createState() => _CategoryDetailPageState();
}

class _CategoryDetailPageState extends State<CategoryDetailPage> {
  int tabIndex = 0;
  List<Task> tasks = [];
  Map<int, List<SubTask>> subtaskMap = {};

  void loadData() async {
    final all = await TaskService.getAll();
    tasks = all.where((t) => t.categoryId == widget.categoryId).toList();

    subtaskMap.clear();
    for (var t in tasks) {
      final subs = await SubTaskService.getByTask(t.id!);
      subtaskMap[t.id!] = subs;

      if (subs.isNotEmpty) {
        final hasDone = subs.any((s) => s.isDone == true);
        final hasNotDone = subs.any((s) => s.isDone == false);

        if (hasDone && hasNotDone) {
          t.status = 2; // Đang thực hiện
        } else if (hasNotDone && !hasDone) {
          t.status = 0; // Chưa xong
        } else if (hasDone && !hasNotDone) {
          t.status = 1; // Đã xong
        }
      } else {
        // Nếu không có subtask thì giữ nguyên status gốc
        t.status = t.status;
      }
  }


    setState(() {});
  }


  @override
  void initState() {
    super.initState();
    loadData();
  }

  List<Task> get filteredTasks {
    if (tabIndex == 1) return tasks.where((t) => t.status == 0).toList();
    if (tabIndex == 2) return tasks.where((t) => t.status == 1).toList();
    if (tabIndex == 3) return tasks.where((t) => t.status == 2).toList();
    return tasks;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      appBar: AppBar(
        title: Text("Danh mục: ${widget.categoryName}",
            style: const TextStyle(fontWeight: FontWeight.bold)),
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
      ),
      body: Column(
        children: [
          _categoryHeader(),
          _buildTabs(),
          _addTaskButton(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredTasks.length,
              itemBuilder: (_, i) => _taskItem(filteredTasks[i]),
            ),
          ),
        ],
      ),
    );
  }

  /// HEADER DANH MỤC
  Widget _categoryHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.folder, color: Colors.white, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.categoryName,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                Text("${tasks.length} công việc",
                    style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// TABS
  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _tab("Tất cả", 0),
          _tab("Chưa xong", 1),
          _tab("Đang thực hiện", 3),
          _tab("Đã xong", 2),
        ],
      ),
    );
  }

  Widget _tab(String text, int i) {
    final active = tabIndex == i;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => tabIndex = i),
        child: Container(
          padding: const EdgeInsets.only(bottom: 8),
          child: Column(
            children: [
              Text(text,
                  style: TextStyle(
                      color: active ? Colors.deepPurple : Colors.grey,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Container(
                height: 2,
                color: active ? Colors.deepPurple : Colors.transparent,
              )
            ],
          ),
        ),
      ),
    );
  }

  /// NÚT THÊM TASK
  Widget _addTaskButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: GestureDetector(
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddTaskPage()),
          );
          if (result == true) loadData();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text("+  Thêm công việc",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  /// TASK ITEM
  Widget _taskItem(Task task) {
    return InkWell(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TaskDetailPage(
              task: task,
              categoryId: widget.categoryId,
              categoryName: widget.categoryName,
            ),
          ),
        );
        if (result == true) loadData();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Row(
          children: [
            Checkbox(
              value: task.status == 1,
              activeColor: Colors.deepPurple,
              onChanged: (v) async {
                task.status = v! ? 1 : 0;
                await TaskService.update(task);
                loadData();
              },
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(task.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        decoration: task.status == 1
                            ? TextDecoration.lineThrough
                            : null,
                      )),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          size: 14, color: Colors.blue),
                      const SizedBox(width: 4),
                      Text(task.deadline ?? "",
                          style: const TextStyle(
                              fontSize: 12, color: Colors.black54)),
                    ],
                  ),
                ],
              ),
            ),
            _priorityBadge(task.priority),
          ],
        ),
      ),
    );
  }

  /// BADGE ƯU TIÊN
  Widget _priorityBadge(int p) {
    String text;
    Color color;
    IconData icon;
    switch (p) {
      case 3:
        text = "Cao";
        color = Colors.red;
        icon = Icons.flash_on;
        break;
      case 2:
        text = "TB";
        color = Colors.orange;
        icon = Icons.hourglass_bottom;
        break;
      case 1:
        text = "Thấp";
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      default:
        text = "Không";
        color = Colors.grey;
        icon = Icons.help_outline;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(text,
              style: TextStyle(
                  color: color, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
