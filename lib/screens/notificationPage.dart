import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/custom_icons.dart';
import '../services/notification_service.dart';
import 'task_detail_page.dart';
import '../models/task_model.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<Map<String, dynamic>> systemNotifications = [];
  List<Map<String, dynamic>> taskNotifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  void _loadNotifications() async {
    systemNotifications = await NotificationService.getSystemNotifications();
    taskNotifications = await NotificationService.getTaskNotifications();
    setState(() {});
  }

  Future<void> _deleteNotification(int id) async {
    await NotificationService.deleteNotification(id);
    _loadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Thông báo",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
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
          elevation: 0,
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.notifications_active), text: "Nhắc nhở"),
              Tab(icon: Icon(Icons.notifications), text: "Thông báo"),
            ],
          ),
        ),
        body: Container(
          color: Colors.white,
          child: TabBarView(
            children: [
              // Panel công việc
              taskNotifications.isEmpty
                  ? const Center(child: Text("Không có thông báo nhắc nhở"))
                  : ListView.builder(
                itemCount: taskNotifications.length,
                itemBuilder: (_, i) {
                  final n = taskNotifications[i];
                  final dt = DateTime.tryParse(n['notify_time'] ?? "");
                  final timeStr = dt != null
                      ? DateFormat("dd/MM/yyyy HH:mm").format(dt)
                      : "";

                  return Card(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    child: ListTile(
                      leading: const Icon(Icons.notifications_active,
                          color: Colors.blue),
                      title: Text(
                        n['title'] ?? "Nhắc nhở",
                        style:
                        const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                          "Danh mục: ${n['categoryName'] ?? ""}\nThời gian: $timeStr"),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete,
                            color: Colors.redAccent),
                        onPressed: () async {
                          if (n['id'] != null) {
                            await _deleteNotification(n['id']);
                          }
                        },
                      ),
                      onTap: () async {
                        // convert Map -> Task để điều hướng
                        final taskObj = Task.fromMap(n as Map<String, dynamic>);
                        final customIcon = getCustomIcon(taskObj.categoryName);

                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TaskDetailPage(
                              task: taskObj,
                              categoryId: taskObj.categoryId ?? 0,
                              categoryName: taskObj.categoryName ?? "Không có danh mục",
                              categoryIcon: customIcon.icon,
                            ),
                          ),
                        );
                        if (result == true) {
                          _loadNotifications();
                        }
                      },

                    ),
                  );
                },
              ),

              // Panel hệ thống
              systemNotifications.isEmpty
                  ? const Center(child: Text("Không có thông báo hệ thống"))
                  : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: systemNotifications.length,
                itemBuilder: (_, i) {
                  final n = systemNotifications[i];
                  final dt = DateTime.tryParse(n['notify_time'] ?? "");
                  final timeStr = dt != null
                      ? DateFormat("dd/MM/yyyy HH:mm").format(dt)
                      : "";

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.orange, Colors.redAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 6)
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.white.withOpacity(0.2),
                          child: const Icon(Icons.notifications,
                              color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(n['title'] ?? "Thông báo",
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                              const SizedBox(height: 4),
                              Text(
                                  "${n['content'] ?? "Đã nhắc hoặc quá hạn"}\n$timeStr",
                                  style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13)),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete,
                              color: Colors.white),
                          onPressed: () async {
                            if (n['id'] != null) {
                              await _deleteNotification(n['id']);
                            }
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
