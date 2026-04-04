import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  String selectedPeriod = "Tuần này";
  bool? showCompletedOnly; // null = chưa chọn, true = Hoàn thành, false = Tất cả

  // Dữ liệu công việc
  final List<Map<String, dynamic>> allTasks = [
    {"title": "Học React nâng cao", "time": "10:00", "category": "Học tập", "date": "Hôm nay", "isCompleted": true},
    {"title": "Mua đồ dùng văn phòng", "time": "14:30", "category": "Công việc", "date": "Hôm qua", "isCompleted": true},
    {"title": "Chạy bộ 5km", "time": "06:00", "category": "Sức khỏe", "date": "Hôm qua", "isCompleted": true},
    {"title": "Gửi báo cáo dự án", "time": "20:00", "category": "Công việc", "date": "22/04", "isCompleted": true},
    {"title": "Hoàn thành bài tập Flutter", "time": "09:00", "category": "Học tập", "date": "Hôm nay", "isCompleted": false},
    {"title": "Đi siêu thị mua thực phẩm", "time": "17:00", "category": "Cá nhân", "date": "Hôm nay", "isCompleted": false},
    {"title": "Lên kế hoạch tuần sau", "time": "", "category": "Công việc", "date": "23/04", "isCompleted": false},
    {"title": "Kiểm tra sức khỏe định kỳ", "time": "08:00", "category": "Sức khỏe", "date": "25/04", "isCompleted": false},
  ];

  List<Map<String, dynamic>> get displayedTasks {
    if (showCompletedOnly == null) return [];
    if (showCompletedOnly == true) {
      return allTasks.where((t) => t["isCompleted"] == true).toList();
    }
    return allTasks; // Tất cả
  }

  final List<Map<String, dynamic>> categoryStats = [
    {"name": "Công việc", "value": 7, "color": const Color(0xFF6B4EFF)},
    {"name": "Học tập", "value": 5, "color": const Color(0xFF2196F3)},
    {"name": "Cá nhân", "value": 3, "color": const Color(0xFF4CAF50)},
    {"name": "Mua sắm", "value": 2, "color": const Color(0xFFFF9800)},
    {"name": "Sức khỏe", "value": 1, "color": const Color(0xFFE91E63)},
  ];

  final List<int> weeklyProgress = [2, 3, 4, 5, 7, 6, 5];

  int? touchedIndex;

  @override
  Widget build(BuildContext context) {
    final totalTasks = allTasks.length;
    final completedCount = allTasks.where((t) => t["isCompleted"] == true).length;
    final completionRate = totalTasks > 0 ? (completedCount / totalTasks * 100).round() : 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Thống kê", style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dropdown thời gian
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedPeriod,
                  isExpanded: true,
                  items: ["Tuần này", "Tháng này", "Năm nay"]
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (value) => setState(() => selectedPeriod = value!),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 2 thẻ thống kê
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => showCompletedOnly = true),
                    child: _buildStatCard(
                      "Hoàn thành",
                      completedCount.toString(),
                      Colors.green,
                      "Công việc đã xong",
                      isSelected: showCompletedOnly == true,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => showCompletedOnly = false),
                    child: _buildStatCard(
                      "Tổng công việc",
                      totalTasks.toString(),
                      Colors.blue,
                      "Tất cả công việc",
                      isSelected: showCompletedOnly == false,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Tỷ lệ hoàn thành
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 10)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Tỷ lệ hoàn thành", style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: completionRate / 100,
                    backgroundColor: Colors.grey[200],
                    color: Colors.blue,
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("$completionRate%", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      Text("$completedCount / $totalTasks", style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Danh sách công việc (chỉ hiện khi đã chọn thẻ)
            if (showCompletedOnly != null) ...[
              Text(
                showCompletedOnly == true ? "Công việc đã hoàn thành" : "Tất cả công việc",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              _buildTaskList(displayedTasks),
            ] else
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Text(
                    "Chọn một thẻ để xem chi tiết công việc",
                    style: TextStyle(color: Colors.grey, fontSize: 15),
                  ),
                ),
              ),

            const SizedBox(height: 32),

            // Biểu đồ tròn với chú thích bên phải + click hiệu ứng
            const Text("Công việc theo danh mục", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            _buildInteractivePieChart(),

            const SizedBox(height: 32),

            // Biểu đồ cột
            const Text("Tiến độ theo ngày", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 8,
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const days = ["T2", "T3", "T4", "T5", "T6", "T7", "CN"];
                          return Text(days[value.toInt()], style: const TextStyle(fontSize: 12));
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30)),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(7, (index) {
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: weeklyProgress[index].toDouble(),
                          color: Colors.blue,
                          width: 18,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskList(List<Map<String, dynamic>> tasks) {
    if (tasks.isEmpty) {
      return const Center(child: Text("Không có công việc nào", style: TextStyle(color: Colors.grey)));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        final isCompleted = task["isCompleted"] as bool;

        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: ListTile(
            leading: Icon(
              isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isCompleted ? Colors.green : Colors.grey,
            ),
            title: Text(
              task["title"],
              style: TextStyle(
                fontWeight: FontWeight.w500,
                decoration: isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
            subtitle: Text("${task["category"]} • ${task["date"]}"),
            trailing: Text(task["time"] ?? "", style: const TextStyle(color: Colors.grey)),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Chi tiết: ${task["title"]}")),
              );
            },
          ),
        );
      },
    );
  }

  // Biểu đồ tròn có click hiệu ứng + chú thích bên phải
  Widget _buildInteractivePieChart() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Biểu đồ
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null) {
                        touchedIndex = -1;
                        return;
                      }
                      touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
                sectionsSpace: 6,
                centerSpaceRadius: 45,
                sections: List.generate(categoryStats.length, (i) {
                  final isTouched = i == touchedIndex;
                  final cat = categoryStats[i];
                  final value = (cat["value"] as int).toDouble();

                  return PieChartSectionData(
                    color: cat["color"],
                    value: value,
                    title: isTouched ? "$value" : "",
                    radius: isTouched ? 68 : 58,
                    titleStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }),
              ),
            ),
          ),
        ),

        // Chú thích (legend)
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: categoryStats.map((cat) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 7),
                child: Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: cat["color"],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(cat["name"], style: const TextStyle(fontSize: 14))),
                    Text("${cat["value"]}", style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, Color color, String subtitle, {bool isSelected = false}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isSelected ? color.withOpacity(0.08) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isSelected ? Border.all(color: color, width: 2.5) : null,
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 12)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        ],
      ),
    );
  }
}