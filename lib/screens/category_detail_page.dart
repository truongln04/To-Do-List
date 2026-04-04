import 'package:flutter/material.dart';
import '../models/task_model.dart';
import 'add_subtask_page.dart';

class CategoryDetailPage extends StatefulWidget {
  final String categoryName;

  const CategoryDetailPage({super.key, required this.categoryName});

  @override
  State<CategoryDetailPage> createState() => _CategoryDetailPageState();
}

class _CategoryDetailPageState extends State<CategoryDetailPage> {
  int tabIndex = 0;

  List<Task> tasks = [
    Task(
      title: "Học React nâng cao",
      priority: "Cao",
      dueDate: DateTime(2024, 4, 24, 10, 0),
      subTasks: [
        SubTask(
          title: "Xem video",
          dueDate: DateTime(2024, 4, 24, 9, 0),
        ),
        SubTask(
          title: "Làm bài tập",
          dueDate: DateTime(2024, 4, 24, 9, 30),
        ),
      ],
    ),
    Task(
      title: "Gửi báo cáo",
      priority: "Trung bình",
      dueDate: DateTime(2024, 4, 25, 16, 0),
    ),
  ];

  /// FILTER TAB
  List<Task> get filteredTasks {
    if (tabIndex == 1) return tasks.where((t) => !t.done).toList();
    if (tabIndex == 2) return tasks.where((t) => t.done).toList();
    return tasks;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(widget.categoryName,
            style: const TextStyle(color: Colors.black)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: Column(
        children: [
          /// ===== TAB =====
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _tab("Tất cả", 0),
                _tab("Chưa xong", 1),
                _tab("Đã xong", 2),
              ],
            ),
          ),

          /// ===== LIST TASK =====
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filteredTasks.length,
              itemBuilder: (context, index) {
                return _taskItem(filteredTasks[index]);
              },
            ),
          ),
        ],
      ),

      /// ===== NÚT + =====
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 👉 sau này mở AddTaskPage
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  /// ===== TAB ITEM =====
  Widget _tab(String text, int i) {
    final isActive = tabIndex == i;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => tabIndex = i),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xff4A6CF7) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// ===== TASK ITEM =====
  Widget _taskItem(Task task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// TASK CHA
          Row(
            children: [
              Checkbox(
                value: task.done,
                onChanged: (v) {
                  setState(() {
                    task.done = v!;
                    for (var sub in task.subTasks) {
                      sub.done = v;
                    }
                  });
                },
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration:
                        task.done ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    Text(
                      _formatDate(task.dueDate),
                      style: const TextStyle(
                          fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),

          /// ===== SUBTASK =====
          ...task.subTasks.map((sub) {
            return Padding(
              padding: const EdgeInsets.only(left: 40, top: 6),
              child: Row(
                children: [
                  Checkbox(
                    value: sub.done,
                    onChanged: (v) {
                      setState(() {
                        sub.done = v!;
                        task.done =
                            task.subTasks.every((s) => s.done == true);
                      });
                    },
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sub.title,
                          style: TextStyle(
                            decoration: sub.done
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        Text(
                          _formatDate(sub.dueDate),
                          style: const TextStyle(
                              fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),

          const SizedBox(height: 8),

          /// ===== ADD SUBTASK =====
          GestureDetector(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddSubTaskPage(parentTask: task),
                ),
              );

              if (result != null) {
                setState(() {
                  task.subTasks.add(result);
                });
              }
            },
            child: const Padding(
              padding: EdgeInsets.only(left: 40),
              child: Text("+ Thêm công việc con",
                  style: TextStyle(color: Colors.blue)),
            ),
          ),
        ],
      ),
    );
  }

  /// ===== FORMAT DATE =====
  String _formatDate(DateTime? d) {
    if (d == null) return "";
    return "${d.day}/${d.month} ${d.hour}:${d.minute.toString().padLeft(2, '0')}";
  }
}