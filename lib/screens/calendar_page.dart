import 'package:flutter/material.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime currentMonth = DateTime(2024, 4);
  DateTime selectedDate = DateTime(2024, 4, 24);
  String currentView = "Ngày";

  final List<Map<String, dynamic>> sampleTasks = [
    {
      "time": "10:00",
      "title": "Học React nâng cao",
      "subtitle": "Học tập",
      "category": "Học tập",
      "priority": "Cao",
      "categoryColor": Colors.blue,
      "priorityColor": Colors.red,
    },
    {
      "time": "17:00",
      "title": "Đi siêu thị",
      "subtitle": "Cá nhân",
      "category": "Cá nhân",
      "priority": "TB",
      "categoryColor": Colors.green,
      "priorityColor": Colors.orange,
    },
    {
      "time": "20:00",
      "title": "Gửi báo cáo dự án",
      "subtitle": "Công việc",
      "category": "Công việc",
      "priority": "Cao",
      "categoryColor": Colors.purple,
      "priorityColor": Colors.red,
    },
  ];

  final List<String> weekdaysShort = ["T2", "T3", "T4", "T5", "T6", "T7", "CN"];
  final List<String> fullWeekdays = ["Chủ Nhật", "Thứ Hai", "Thứ Ba", "Thứ Tư", "Thứ Năm", "Thứ Sáu", "Thứ Bảy"];

  String getDayOfWeek(DateTime date) => fullWeekdays[date.weekday % 7];

  void changeMonth(int months) {
    setState(() {
      currentMonth = DateTime(currentMonth.year, currentMonth.month + months, 1);
      if (selectedDate.month != currentMonth.month || selectedDate.year != currentMonth.year) {
        selectedDate = DateTime(currentMonth.year, currentMonth.month, 1);
      }
    });
  }

  // Mở lịch tháng đầy đủ khi click icon lịch hoặc tab "Tháng"
  void _showMonthCalendar() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.75,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left, size: 32),
                      onPressed: () => setState(() {
                        currentMonth = DateTime(currentMonth.year, currentMonth.month - 1, 1);
                      }),
                    ),
                    Text(
                      "${currentMonth.month == 4 ? 'Tháng 4' : currentMonth.month}, ${currentMonth.year}",
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right, size: 32),
                      onPressed: () => setState(() {
                        currentMonth = DateTime(currentMonth.year, currentMonth.month + 1, 1);
                      }),
                    ),
                  ],
                ),
              ),
              // Lịch tháng đầy đủ (Grid)
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    childAspectRatio: 1.1,
                  ),
                  itemCount: 42, // 6 tuần x 7 ngày
                  itemBuilder: (context, index) {
                    final firstDayOfMonth = DateTime(currentMonth.year, currentMonth.month, 1);
                    final weekdayOffset = firstDayOfMonth.weekday % 7; // T2=1 → offset
                    final day = index - weekdayOffset + 1;

                    if (day < 1 || day > DateTime(currentMonth.year, currentMonth.month + 1, 0).day) {
                      return const SizedBox();
                    }

                    final date = DateTime(currentMonth.year, currentMonth.month, day);
                    final isSelected = date.day == selectedDate.day &&
                        date.month == selectedDate.month &&
                        date.year == selectedDate.year;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedDate = date;
                        });
                        Navigator.pop(context); // Đóng bottom sheet sau khi chọn
                      },
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blue : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            day.toString(),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final String monthTitle = "Tháng ${currentMonth.month}, ${currentMonth.year}";
    final String selectedDayTitle = "${getDayOfWeek(selectedDate)}, ${selectedDate.day} Tháng ${selectedDate.month}";

    return Scaffold(
      appBar: AppBar(
        // leading: const Icon(Icons.arrow_back_ios, color: Colors.blue),
        title: const Text("Lịch", style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          // Icon lịch → mở lịch tháng đầy đủ
          IconButton(
            icon: const Icon(Icons.calendar_today, color: Colors.blue),
            onPressed: _showMonthCalendar,
          ),
        ],
      ),
      body: Column(
        children: [
          // Header tháng + nút chuyển
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(icon: const Icon(Icons.chevron_left, size: 30), onPressed: () => changeMonth(-1)),
                Text(monthTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                IconButton(icon: const Icon(Icons.chevron_right, size: 30), onPressed: () => changeMonth(1)),
              ],
            ),
          ),

          // Header ngày trong tuần
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: weekdaysShort.map((d) => Text(d, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))).toList(),
            ),
          ),

          // Thanh ngày ngang (vuốt được)
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: 31,
              itemBuilder: (context, index) {
                final day = index + 1;
                final date = DateTime(currentMonth.year, currentMonth.month, day);
                final isSelected = date.day == selectedDate.day && date.month == selectedDate.month;

                return GestureDetector(
                  onTap: () => setState(() => selectedDate = date),
                  child: Container(
                    width: 52,
                    margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          day.toString(),
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                        ),
                        if (isSelected)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Tab Ngày - Tuần - Tháng
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              children: [
                _buildTab("Ngày", currentView == "Ngày", () => setState(() => currentView = "Ngày")),
                const SizedBox(width: 8),
                _buildTab("Tuần", currentView == "Tuần", () => setState(() => currentView = "Tuần")),
                const SizedBox(width: 8),
                _buildTab("Tháng", currentView == "Tháng", () {
                  setState(() => currentView = "Tháng");
                  _showMonthCalendar(); // Mở lịch tháng ngay
                }),
              ],
            ),
          ),

          // Nội dung theo view
          Expanded(
            child: currentView == "Ngày"
                ? _buildDayView(selectedDayTitle)
                : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.calendar_month, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text("Chế độ $currentView đang phát triển", style: const TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String text, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue : Colors.grey[200],
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDayView(String dayTitle) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        Text("$dayTitle   ${sampleTasks.length} công việc", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        ...sampleTasks.map((task) => _buildTaskCard(task)).toList(),
        const SizedBox(height: 30),
        const Text("Quá hạn", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(14)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.check_box_outline_blank, color: Colors.grey, size: 28),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Hoàn thành bài tập cũ", style: TextStyle(fontSize: 15)),
                    SizedBox(height: 4),
                    Text("Trễ 1 ngày", style: TextStyle(color: Colors.red, fontSize: 13)),
                  ],
                ),
              ),
              FloatingActionButton.small(
                onPressed: () {},
                backgroundColor: Colors.blue,
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTaskCard(Map<String, dynamic> task) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(task["time"], style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: (task["categoryColor"] as Color).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(task["category"], style: TextStyle(color: task["categoryColor"], fontSize: 13)),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: (task["priorityColor"] as Color).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.flag, size: 16, color: task["priorityColor"]),
                      const SizedBox(width: 4),
                      Text(task["priority"], style: TextStyle(color: task["priorityColor"], fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(task["title"], style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Text(task["subtitle"], style: const TextStyle(color: Colors.grey, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}