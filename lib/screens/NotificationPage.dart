import 'package:flutter/material.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = [
      {"title": "Bạn có 1 công việc quá hạn", "time": "10:00", "icon": Icons.warning, "color": Colors.red},
      {"title": "Nhắc nhở: Đi siêu thị", "time": "16:30", "icon": Icons.shopping_cart, "color": Colors.orange},
      {"title": "Báo cáo dự án đã gửi thành công", "time": "20:15", "icon": Icons.work, "color": Colors.green},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Thông báo")),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final n = notifications[index];
          return ListTile(
            leading: Icon(n["icon"] as IconData, color: n["color"] as Color),
            title: Text(n["title"] as String),
            subtitle: Text("Thời gian: ${n["time"]}"),
            onTap: () {
              // TODO: xử lý khi nhấn vào thông báo (ví dụ mở chi tiết task)
            },
          );
        },
      ),
    );
  }
}
