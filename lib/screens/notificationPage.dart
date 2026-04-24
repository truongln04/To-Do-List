import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
                colors: [Color(0xFF00C9FF), Color(0xFF92FE9D)], // header gradient
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          elevation: 0,
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.task_alt), text: "Công việc"),
              Tab(icon: Icon(Icons.notifications_active), text: "Hệ thống"),
            ],
          ),
        ),
        body: Container(
          color: Colors.white, // nền trắng cho nội dung
          child: TabBarView(
            children: [
              // Panel công việc
              FutureBuilder(
                future: NotificationService.getFullNotifications(),
                builder: (_, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  final notis = snapshot.data!;
                  if (notis.isEmpty) return const Center(child: Text("Không có thông báo"));
                  return ListView.builder(
                    itemCount: notis.length,
                    itemBuilder: (_, i) {
                      final n = notis[i];
                      final dt = DateTime.tryParse(n['notify_time']);
                      final timeStr = dt != null ? DateFormat("dd/MM/yyyy HH:mm").format(dt) : "";

                      return ListTile(
                        leading: const Icon(Icons.notifications, color: Colors.blue),
                        title: Text(n['taskTitle'] ?? n['subtaskTitle'] ?? "Công việc"),
                        subtitle: Text("Danh mục: ${n['categoryName'] ?? ""}\nThời gian: $timeStr"),
                      );
                    },
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
                  return _buildNotificationCard(
                    n['title'] ?? "Thông báo",
                    n['content'] ?? "Đã nhắc hoặc quá hạn",
                    Icons.notifications,
                    [Colors.orange, Colors.redAccent],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(
      String title, String subtitle, IconData icon, List<Color> gradientColors) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white.withOpacity(0.2),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: const TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
