import 'package:flutter/material.dart';
import 'add_task_page.dart';
import 'NotificationPage.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              /// Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Xin chào, Trường 👋",
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      Text("Hôm nay, 24 Tháng 4"),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_none,
                        size: 40, color: Colors.deepPurpleAccent),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const NotificationPage()),
                      );
                    },
                  ),
                ],
              ),


              const SizedBox(height: 20),

              /// Tổng quan hôm nay (có icon + điều hướng)
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const OverviewPage()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
                  ),
                  child: Row(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 70,
                            height: 70,
                            child: CircularProgressIndicator(
                              value: 0.6,
                              strokeWidth: 6,
                              color: Colors.deepPurple,
                            ),
                          ),
                          const Text("60%")
                        ],
                      ),
                      const SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.green),
                              SizedBox(width: 6),
                              Text("Đã hoàn thành: 3"),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(Icons.access_time, color: Colors.orange),
                              SizedBox(width: 6),
                              Text("Còn lại: 5"),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(Icons.warning, color: Colors.red),
                              SizedBox(width: 6),
                              Text("Quá hạn: 1"),
                            ],
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// Ưu tiên hôm nay
              const Text("Ưu tiên hôm nay",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              task("Học React nâng cao", "10:00", "Học tập", Colors.red,
                  Icons.school),
              task("Đi siêu thị", "17:00", "Cá nhân", Colors.orange,
                  Icons.shopping_cart),
              task("Gửi báo cáo dự án", "20:00", "Công việc", Colors.red,
                  Icons.work),

              const SizedBox(height: 20),

              /// Sắp tới
              const Text("Sắp tới",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              task("Nộp bài tập Toán", "Ngày mai, 9:00", "Học tập", Colors.blue,
                  Icons.book),
              task("Đọc sách 30 phút", "2 ngày nữa", "Cá nhân", Colors.green,
                  Icons.menu_book),
            ],
          ),
        ),
      ),
    );
  }

  Widget task(
      String title, String time, String category, Color color, IconData icon) {
    return Container(
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
              Checkbox(value: false, onChanged: (v) {}),
              Expanded(
                child: Text(title,
                    style: const TextStyle(fontWeight: FontWeight.w500)),
              ),
              Text(time),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(icon, color: color, size: 16),
                    const SizedBox(width: 4),
                    Text(category,
                        style: TextStyle(color: color, fontSize: 12)),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }


}

/// Trang chi tiết tổng quan (giả lập)
class OverviewPage extends StatelessWidget {
  const OverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chi tiết tổng quan")),
      body: const Center(
        child: Text("Nội dung chi tiết tổng quan hôm nay..."),
      ),
    );
  }
}
