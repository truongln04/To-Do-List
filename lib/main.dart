import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'services/notification_service.dart';

// IMPORT PAGE
import 'screens/home_page.dart';
import 'screens/task_page.dart';
import 'screens/category_page.dart';
import 'screens/stats_page.dart';
import 'screens/add_task_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// 🔥 INIT NOTIFICATION
  await NotificationService.init();

  /// 🔥 XIN QUYỀN ANDROID 13+
  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const MainApp(),
    );
  }
}

/// ================= MAIN APP =================
class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int index = 0;

  final pages = const [
    HomePage(),
    TaskPage(),
    CategoryPage(),
    StatsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[index],

      /// ===== NÚT +
      floatingActionButton: Container(
        width: 60,
        height: 60,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [Color(0xFF5B8CFF), Color(0xFF9B59B6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: FloatingActionButton(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddTaskPage()),
            );
            if (result != null) {
              setState(() {}); // reload

            }
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add, size: 32, color: Colors.white),
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      /// ===== BOTTOM BAR
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: SizedBox(
          height: 65,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _item(Icons.home, "Trang chủ", 0),
              _item(Icons.task, "Task", 1),

              const SizedBox(width: 40),

              _item(Icons.folder, "Danh mục", 2),
              _item(Icons.bar_chart, "Thống kê", 3),
            ],
          ),
        ),
      ),
    );
  }

  /// ITEM NAV
  Widget _item(IconData icon, String label, int i) {
    final isSelected = index == i;

    return GestureDetector(
      onTap: () => setState(() => index = i),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? const Color(0xff4A6CF7) : Colors.grey,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? const Color(0xff4A6CF7) : Colors.grey,
            ),
          )
        ],
      ),
    );
  }
}