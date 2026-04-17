import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../services/task_service.dart';
import 'notificationPage.dart';
import 'task_detail_page.dart';
import 'overview_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Task> highPriorityTasks = [];
  List<Task> upcomingTasks = [];
  Map<String, int> stats = {"done": 0, "total": 0, "overdue": 0};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    highPriorityTasks = await TaskService.getHighPriorityTasks();
    upcomingTasks = await TaskService.getUpcomingTasks();
    stats = await TaskService.getOverviewStats();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final percent = stats["total"] == 0
        ? 0.0
        : stats["done"]! / stats["total"]!.toDouble();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            /// Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Xin chào, Trường 👋",
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      Text("Hôm nay, ${DateTime.now().day}/${DateTime.now().month}"),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_none,
                        size: 32, color: Colors.deepPurpleAccent),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const NotificationPage()),
                      );
                    },
                  ),
                ],
              ),
            ),

            /// Tổng quan hôm nay
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OverviewPage(
                      stats: stats,
                      tasks: [...highPriorityTasks, ...upcomingTasks],
                    ),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
                ),
                child: stats["total"] == 0
                    ? const Center(
                  child: Text("Hôm nay không có công việc",
                      style: TextStyle(color: Colors.white70)),
                )
                    : Row(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 70,
                          height: 70,
                          child: CircularProgressIndicator(
                            value: percent,
                            strokeWidth: 6,
                            color: Colors.white,
                            backgroundColor: Colors.white24,
                          ),
                        ),
                        Text("${(percent * 100).toInt()}%",
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.green),
                            const SizedBox(width: 6),
                            Text("Đã hoàn thành: ${stats["done"]}",
                                style: const TextStyle(color: Colors.white)),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.access_time, color: Colors.orange),
                            const SizedBox(width: 6),
                            Text("Còn lại: ${stats["total"]! - stats["done"]!}",
                                style: const TextStyle(color: Colors.white)),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.warning, color: Colors.red),
                            const SizedBox(width: 6),
                            Text("Quá hạn: ${stats["overdue"]}",
                                style: const TextStyle(color: Colors.white)),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),

            /// Danh sách task cuộn
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ListView(
                  children: [
                    const SizedBox(height: 10),
                    const Text("Ưu tiên hôm nay",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 10),
                    highPriorityTasks.isEmpty
                        ? const Text("Hôm nay không có công việc ưu tiên",
                        style: TextStyle(color: Colors.black54))
                        : Column(
                      children: highPriorityTasks.map((t) => taskItem(t)).toList(),
                    ),
                    const SizedBox(height: 20),
                    const Text("Sắp tới",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 10),
                    upcomingTasks.isEmpty
                        ? const Text("Không có công việc sắp tới",
                        style: TextStyle(color: Colors.black54))
                        : Column(
                      children: upcomingTasks.map((t) => taskItem(t)).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

  }

  /// Hiển thị từng task
  Widget taskItem(Task t) {
    final priorityColor = _priorityColor(t.priority);
    final priorityIcon = _priorityIcon(t.priority);
    final categoryIcon = _categoryIcon(t.categoryName);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TaskDetailPage(
              task: t,
              categoryId: t.categoryId ?? 0,
              categoryName: t.categoryName ?? "Không có danh mục",
              categoryIcon: categoryIcon,
            ),
          ),
        ).then((value) => _loadData()); // load lại dữ liệu sau khi quay về
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Checkbox(
                  value: t.status == 1,
                  activeColor: Colors.deepPurple,
                  onChanged: (v) async {
                    t.status = v! ? 1 : 0;
                    await TaskService.update(t);
                    _loadData();
                  },
                ),
                Expanded(
                  child: Text(t.title,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
                Text(t.deadline ?? "",
                    style: const TextStyle(color: Colors.black54)),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(categoryIcon, color: Colors.deepPurple, size: 16),
                      const SizedBox(width: 4),
                      Text(t.categoryName ?? "Không có danh mục",
                          style: const TextStyle(
                              color: Colors.deepPurple, fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: priorityColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(priorityIcon, color: priorityColor, size: 16),
                      const SizedBox(width: 4),
                      Text(_priorityText(t.priority),
                          style: TextStyle(color: priorityColor, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
}
  /// Icon theo danh mục
  IconData _categoryIcon(String? name) {
    switch (name) {
      case "Công việc":
        return Icons.work;
      case "Học tập":
        return Icons.school;
      case "Cá nhân":
        return Icons.person;
      case "Sức khỏe":
        return Icons.favorite;
      case "Mua sắm":
        return Icons.shopping_cart;
      default:
        return Icons.category;
    }
  }

  /// Icon theo ưu tiên
  IconData _priorityIcon(int? p) {
    switch (p) {
      case 3:
        return Icons.flash_on; // Cao
      case 2:
        return Icons.hourglass_bottom; // Trung bình
      case 1:
        return Icons.check_circle; // Thấp
      default:
        return Icons.help_outline;
    }
  }

  /// Màu theo ưu tiên
  Color _priorityColor(int? p) {
    switch (p) {
      case 3:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 1:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  /// Text theo ưu tiên
  String _priorityText(int? p) {
    switch (p) {
      case 3:
        return "Cao";
      case 2:
        return "Trung bình";
      case 1:
        return "Thấp";
      default:
        return "Không rõ";
    }
  }
}