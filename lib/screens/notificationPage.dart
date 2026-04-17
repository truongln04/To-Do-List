import 'package:flutter/material.dart';
import '../services/notification_service.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Thông báo"),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle("Thông báo hệ thống", Icons.notifications_active, Colors.orange),
          const SizedBox(height: 10),
          ...systemNotifications.map((n) => _buildNotificationCard(
            n['title'] ?? "Thông báo",
            n['content'] ?? "",
            Icons.notifications,
            [Colors.orange, Colors.deepOrange],
          )),

          const SizedBox(height: 30),

          _buildSectionTitle("Thông báo công việc", Icons.task_alt, Colors.blue),
          const SizedBox(height: 10),
          ...taskNotifications.map((t) => _buildNotificationCard(
            t['title'] ?? "Công việc",
            "Danh mục: ${t['categoryName'] ?? ""} • Deadline: ${t['deadline'] ?? ""}",
            Icons.work,
            [Colors.blue, Colors.indigo],
          )),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 26),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildNotificationCard(String title, String subtitle, IconData icon, List<Color> gradientColors) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradientColors, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
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
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
