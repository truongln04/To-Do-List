import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../services/task_service.dart';
import 'task_detail_page.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  List<Task> tasks = [];
  List<String> categories = ["Tất cả"];
  String searchQuery = "";
  String selectedCategory = "Tất cả";
  String selectedPriority = "Tất cả";
  String selectedDateFilter = "Tất cả";

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _searchTasks();
  }

  void _loadCategories() async {
    categories = ["Tất cả"] + await TaskService.getAllCategories();
    setState(() {});
  }

  void _searchTasks() async {
    tasks = await TaskService.searchTasks(
      query: searchQuery,
      category: selectedCategory,
      priority: selectedPriority,
      dateFilter: selectedDateFilter,
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: const [
            Icon(Icons.task_alt, color: Colors.white),
            SizedBox(width: 8),
            Text("Danh sách công việc", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00C9FF), Color(0xFF92FE9D)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Thanh tìm kiếm
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search, color: Colors.deepPurple),
                hintText: "Tìm kiếm công việc...",
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                searchQuery = value;
                _searchTasks();
              },
            ),
          ),

          // Bộ lọc nâng cao
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButton<String>(
                        value: selectedCategory,
                        isExpanded: true,
                        items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                        onChanged: (value) {
                          selectedCategory = value!;
                          _searchTasks();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButton<String>(
                        value: selectedPriority,
                        isExpanded: true,
                        items: ["Tất cả", "Thấp", "Trung bình", "Cao"]
                            .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                            .toList(),
                        onChanged: (value) {
                          selectedPriority = value!;
                          _searchTasks();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButton<String>(
                        value: selectedDateFilter,
                        isExpanded: true,
                        items: ["Tất cả", "Hôm nay", "Tuần này", "Quá hạn"]
                            .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                            .toList(),
                        onChanged: (value) {
                          selectedDateFilter = value!;
                          _searchTasks();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Danh sách công việc
          Expanded(
            child: tasks.isEmpty
                ? const Center(child: Text("Không có công việc nào"))
                : ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final t = tasks[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 3,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.deepPurple.withOpacity(0.2),
                      child: Icon(_getCategoryIcon(t.categoryName), color: Colors.deepPurple),
                    ),
                    title: Text(t.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${t.categoryName ?? "Không có danh mục"}"),
                        Text("Ưu tiên: ${_priorityText(t.priority)} • Deadline: ${t.deadline ?? ""}",
                            style: const TextStyle(color: Colors.black54, fontSize: 13)),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TaskDetailPage(
                            task: t,
                            categoryId: t.categoryId ?? 0,
                            categoryName: t.categoryName ?? "Không có danh mục",
                            categoryIcon: _getCategoryIcon(t.categoryName),
                          ),
                        ),
                      ).then((value) => _searchTasks());
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String? name) {
    switch (name) {
      case "Công việc": return Icons.work;
      case "Học tập": return Icons.school;
      case "Cá nhân": return Icons.person;
      case "Sức khỏe": return Icons.favorite;
      case "Mua sắm": return Icons.shopping_cart;
      default: return Icons.category;
    }
  }

  String _priorityText(int? p) {
    switch (p) {
      case 1: return "Thấp";
      case 2: return "Trung bình";
      case 3: return "Cao";
      default: return "Không rõ";
    }
  }
}
