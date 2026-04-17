import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/stats_service.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  Map<String, int> stats = {"total": 0, "done": 0, "overdue": 0};
  List<Map<String, dynamic>> categoryStats = [];
  List<Map<String, dynamic>> weeklyProgress = [];
  List<Map<String, dynamic>> tasks = [];
  bool showCompletedOnly = false;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  void _loadStats() async {
    stats = await StatsService.getOverviewStats();
    categoryStats = await StatsService.getCategoryStats();
    weeklyProgress = await StatsService.getWeeklyProgress();
    tasks = await StatsService.getTasks(completedOnly: showCompletedOnly);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final completionRate = stats["total"] == 0 ? 0 : (stats["done"]! / stats["total"]! * 100).round();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: const [
            Icon(Icons.bar_chart, color: Colors.white),
            SizedBox(width: 8),
            Text("Thống kê", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00C9FF), Color(0xFF92FE9D)], // xanh ngọc → xanh lá
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Thẻ thống kê
            Row(
              children: [
                Expanded(child: _buildStatCard("Hoàn thành", stats["done"].toString(), [Colors.green, Colors.teal], "Công việc đã xong")),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard("Tổng", stats["total"].toString(), [Colors.blue, Colors.indigo], "Tất cả công việc")),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard("Quá hạn", stats["overdue"].toString(), [Colors.red, Colors.deepOrange], "Chưa hoàn thành")),
              ],
            ),

            const SizedBox(height: 20),

            // Tỷ lệ hoàn thành
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Colors.blue, Colors.indigo]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Tỷ lệ hoàn thành", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: completionRate / 100,
                    backgroundColor: Colors.white24,
                    color: Colors.white,
                    minHeight: 10,
                  ),
                  const SizedBox(height: 8),
                  Text("$completionRate%", style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  Text("${stats["done"]} / ${stats["total"]}", style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Biểu đồ tròn theo danh mục
            const Text("Công việc theo danh mục", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: categoryStats.map((cat) {
                    return PieChartSectionData(
                      color: Colors.primaries[categoryStats.indexOf(cat) % Colors.primaries.length],
                      value: (cat["count"] as int).toDouble(),
                      title: "${cat["categoryName"]}\n${cat["count"]}",
                      radius: 60,
                      titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 28),

            // Biểu đồ cột tiến độ tuần
            const Text("Tiến độ theo ngày", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            SizedBox(
              height: 220,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 10,
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const days = ["CN", "T2", "T3", "T4", "T5", "T6", "T7"];
                          return Text(days[value.toInt()], style: const TextStyle(fontSize: 12));
                        },
                      ),
                    ),
                  ),
                  barGroups: weeklyProgress.map((wp) {
                    final weekday = int.parse(wp["weekday"]);
                    final count = wp["count"];
                    return BarChartGroupData(
                      x: weekday,
                      barRods: [
                        BarChartRodData(
                          toY: count.toDouble(),
                          gradient: const LinearGradient(colors: [Colors.purple, Colors.deepPurple]),
                          width: 18,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 28),

            // Danh sách công việc
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(showCompletedOnly ? "Công việc đã hoàn thành" : "Tất cả công việc", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                Switch(
                  value: showCompletedOnly,
                  onChanged: (v) {
                    showCompletedOnly = v;
                    _loadStats();
                  },
                ),
              ],
            ),
            ...tasks.map((t) => Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: ListTile(
                leading: Icon(t["status"] == 1 ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: t["status"] == 1 ? Colors.green : Colors.grey),
                title: Text(t["title"], style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text("${t["categoryName"] ?? ""} • Deadline: ${t["deadline"] ?? ""}"),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, List<Color> colors, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: colors.last.withOpacity(0.3), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
          Text(subtitle, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}
