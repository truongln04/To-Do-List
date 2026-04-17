import 'package:flutter/material.dart';
import '../models/task_model.dart';
import 'task_detail_page.dart';

class OverviewPage extends StatelessWidget {
  final Map<String, int> stats;
  final List<Task> tasks;

  const OverviewPage({super.key, required this.stats, required this.tasks});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      appBar: AppBar(
        title: const Text("Chi tiết tổng quan", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Đã hoàn thành: ${stats["done"]}", style: const TextStyle(fontSize: 16)),
            Text("Còn lại: ${stats["total"]! - stats["done"]!}", style: const TextStyle(fontSize: 16)),
            Text("Quá hạn: ${stats["overdue"]}", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            Expanded(
              child: tasks.isEmpty
                  ? const Center(child: Text("Không có công việc hôm nay"))
                  : ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (_, i) {
                  final t = tasks[i];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: Icon(Icons.task, color: Colors.deepPurple),
                      title: Text(t.title),
                      subtitle: Text(t.deadline ?? ""),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TaskDetailPage(
                              task: t,
                              categoryId: t.categoryId ?? 0,
                              categoryName: t.categoryName ?? "Không có danh mục",
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
