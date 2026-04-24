import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/task_model.dart';
import '../services/stats_service.dart';
import 'task_detail_page.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  // now includes "doing"
  Map<String, int> stats = {"total": 0, "done": 0, "overdue": 0, "doing": 0};
  List<Map<String, dynamic>> categoryStats = [];
  List<Map<String, dynamic>> weeklyProgress = [];
  List<Task> tasks = [];

  // UI state
  bool showCompletedOnly = false;
  String searchQuery = "";
  String selectedCategory = "Tất cả";
  String selectedPriority = "Tất cả";
  String selectedSort = "Deadline"; // "Deadline", "Priority", "Status"
  bool loading = true;

  // For pie interaction
  int? touchedPieIndex;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => loading = true);

    try {
      // Try to get overview including "doing"; if service doesn't provide "doing", compute later
      final overview = await StatsService.getOverviewStats();
      // defensive: ensure keys exist
      stats["total"] = overview["total"] ?? 0;
      stats["done"] = overview["done"] ?? 0;
      stats["overdue"] = overview["overdue"] ?? 0;
      stats["doing"] = overview["doing"] ?? 0;

      categoryStats = await StatsService.getCategoryStats();
      weeklyProgress = await StatsService.getWeeklyProgress();

      final raw = await StatsService.getTasks(completedOnly: showCompletedOnly);
      if (raw.isNotEmpty && raw.first is Map<String, dynamic>) {
        tasks = (raw as List).map<Task>((m) => Task.fromMap(m as Map<String, dynamic>)).toList();
      } else {
        tasks = List<Task>.from(raw);
      }

      // If service didn't return "doing", compute from tasks
      if ((overview["doing"] == null) || overview["doing"] is! int) {
        stats["doing"] = tasks.where((t) => t.status == 2).length;
      }
      // Also ensure total/done/overdue consistent if missing
      if ((overview["total"] == null) || overview["total"] is! int) {
        stats["total"] = tasks.length;
      }
      if ((overview["done"] == null) || overview["done"] is! int) {
        stats["done"] = tasks.where((t) => t.status == 1).length;
      }
      if ((overview["overdue"] == null) || overview["overdue"] is! int) {
        final now = DateTime.now();
        stats["overdue"] = tasks.where((t) {
          final dt = _parseDate(t.deadline);
          return dt != null && dt.isBefore(now) && (t.status != 1);
        }).length;
      }
    } catch (e) {
      debugPrint("Error loading stats: $e");
      stats = {"total": 0, "done": 0, "overdue": 0, "doing": 0};
      categoryStats = [];
      weeklyProgress = [];
      tasks = [];
    }

    setState(() => loading = false);
  }

  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return "";
    try {
      final dt = DateTime.parse(raw);
      return DateFormat('dd/MM/yyyy HH:mm').format(dt);
    } catch (_) {
      final cleaned = raw.split('.').first;
      try {
        final dt = DateTime.parse(cleaned);
        return DateFormat('dd/MM/yyyy HH:mm').format(dt);
      } catch (_) {
        return raw.replaceAll('.000', '');
      }
    }
  }

  Color _priorityColor(int? p) {
    switch (p) {
      case 3:
        return Colors.redAccent;
      case 2:
        return Colors.orangeAccent;
      case 1:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

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

  String _statusText(int? s) {
    switch (s) {
      case 0:
        return "Chưa xong";
      case 1:
        return "Đã xong";
      case 2:
        return "Đang làm";
      default:
        return "Không rõ";
    }
  }

  Color _statusColor(int? s) {
    switch (s) {
      case 0:
        return Colors.orange;
      case 1:
        return Colors.green;
      case 2:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  List<Task> get _filteredTasks {
    var list = tasks.where((t) {
      if (showCompletedOnly && (t.status ?? 0) != 1) return false;
      if (selectedCategory != "Tất cả" && (t.categoryName ?? "Không có danh mục") != selectedCategory) return false;
      if (selectedPriority != "Tất cả") {
        final pText = _priorityText(t.priority);
        if (pText != selectedPriority) return false;
      }
      if (searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        final title = (t.title ?? "").toLowerCase();
        final cat = (t.categoryName ?? "").toLowerCase();
        if (!title.contains(q) && !cat.contains(q)) return false;
      }
      return true;
    }).toList();

    if (selectedSort == "Deadline") {
      list.sort((a, b) {
        final da = _parseDate(a.deadline);
        final db = _parseDate(b.deadline);
        if (da == null && db == null) return 0;
        if (da == null) return 1;
        if (db == null) return -1;
        return da.compareTo(db);
      });
    } else if (selectedSort == "Priority") {
      list.sort((a, b) => (b.priority ?? 0).compareTo(a.priority ?? 0));
    } else if (selectedSort == "Status") {
      final order = {2: 0, 0: 1, 1: 2};
      list.sort((a, b) {
        final oa = order[a.status] ?? 3;
        final ob = order[b.status] ?? 3;
        return oa.compareTo(ob);
      });
    }

    return list;
  }

  DateTime? _parseDate(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      return DateTime.parse(raw);
    } catch (_) {
      try {
        return DateTime.parse(raw.split('.').first);
      } catch (_) {
        return null;
      }
    }
  }

  void _onSelectCategoryFromPie(String categoryName) {
    setState(() {
      selectedCategory = categoryName;
    });
  }

  Future<void> _onRefresh() async {
    await _loadStats();
  }

  @override
  Widget build(BuildContext context) {
    final total = stats["total"] ?? 0;
    final done = stats["done"] ?? 0;
    final doing = stats["doing"] ?? 0;
    final overdue = stats["overdue"] ?? 0;

    final completionRate = total == 0 ? 0 : ((done / total) * 100).round();
    final doingRate = total == 0 ? 0 : ((doing / total) * 100).round();
    final todoCount = total - done - doing;

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
              colors: [Color(0xFF00C9FF), Color(0xFF92FE9D)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top stat cards: now includes "Đang làm"
              Row(
                children: [
                  Expanded(child: _buildStatCard("Hoàn thành", done.toString(), [Colors.green, Colors.teal], "Công việc đã xong")),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard("Đang làm", doing.toString(), [Colors.blue, Colors.lightBlue], "Công việc đang tiến hành")),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStatCard("Quá hạn", overdue.toString(), [Colors.red, Colors.deepOrange], "Công việc quá hạn")),
                ],
              ),

              const SizedBox(height: 12),

              // Tổng + tiến độ (donut-like summary)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
                ),
                child: Row(
                  children: [
                    // small pie showing Done/Doing/Todo
                    SizedBox(
                      width: 110,
                      height: 110,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          PieChart(
                            PieChartData(
                              sectionsSpace: 2,
                              centerSpaceRadius: 30,
                              sections: [
                                PieChartSectionData(
                                  color: Colors.green,
                                  value: done.toDouble(),
                                  title: '',
                                  radius: 40,
                                ),
                                PieChartSectionData(
                                  color: Colors.blue,
                                  value: doing.toDouble(),
                                  title: '',
                                  radius: 40,
                                ),
                                PieChartSectionData(
                                  color: Colors.grey.shade300,
                                  value: (todoCount > 0 ? todoCount.toDouble() : 0.0),
                                  title: '',
                                  radius: 40,
                                ),
                              ],
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text("$completionRate%", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                              const Text("Hoàn thành", style: TextStyle(fontSize: 12, color: Colors.black54)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Summary text
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Tổng: $total công việc", style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Text("Hoàn thành: $done ($completionRate%)", style: const TextStyle(color: Colors.black87)),
                          const SizedBox(height: 4),
                          Text("Đang làm: $doing ($doingRate%)", style: const TextStyle(color: Colors.black87)),
                          const SizedBox(height: 4),
                          Text("Còn lại (Todo): $todoCount", style: const TextStyle(color: Colors.black87)),
                          const SizedBox(height: 6),
                          Text("Quá hạn: $overdue", style: const TextStyle(color: Colors.redAccent)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Pie chart + legend (interactive)
              const Text("Công việc theo danh mục", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 200,
                      child: categoryStats.isEmpty
                          ? Center(child: Text("Không có dữ liệu", style: TextStyle(color: Colors.black54)))
                          : PieChart(
                        PieChartData(
                          sectionsSpace: 4,
                          centerSpaceRadius: 28,
                          pieTouchData: PieTouchData(touchCallback: (event, response) {
                            if (response == null || response.touchedSection == null) {
                              setState(() => touchedPieIndex = null);
                              return;
                            }
                            setState(() => touchedPieIndex = response.touchedSection!.touchedSectionIndex);
                          }),
                          sections: List.generate(categoryStats.length, (i) {
                            final cat = categoryStats[i];
                            final value = (cat["count"] as int).toDouble();
                            final isTouched = i == touchedPieIndex;
                            final color = Colors.primaries[i % Colors.primaries.length];
                            return PieChartSectionData(
                              color: color,
                              value: value,
                              title: "${cat["count"]}",
                              radius: isTouched ? 70 : 60,
                              titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                            );
                          }),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: List.generate(categoryStats.length, (i) {
                            final cat = categoryStats[i];
                            final color = Colors.primaries[i % Colors.primaries.length];
                            final name = cat["categoryName"] ?? "Không có danh mục";
                            return GestureDetector(
                              onTap: () {
                                _onSelectCategoryFromPie(name);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                decoration: BoxDecoration(
                                  color: selectedCategory == name ? color.withOpacity(0.12) : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: color.withOpacity(0.15)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(width: 10, height: 10, color: color),
                                    const SizedBox(width: 8),
                                    Text("$name (${cat["count"]})", style: const TextStyle(fontSize: 13)),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 12),
                        if (selectedCategory != "Tất cả")
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                selectedCategory = "Tất cả";
                              });
                            },
                            icon: const Icon(Icons.clear),
                            label: const Text("Bỏ lọc danh mục"),
                          ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Weekly bar chart
              const Text("Tiến độ theo ngày (tuần)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              SizedBox(
                height: 220,
                child: weeklyProgress.isEmpty
                    ? Center(child: Text("Không có dữ liệu tuần", style: TextStyle(color: Colors.black54)))
                    : BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: (weeklyProgress.map((e) => e["count"] as int).fold<int>(0, (p, n) => p > n ? p : n) + 2).toDouble(),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            const days = ["CN", "T2", "T3", "T4", "T5", "T6", "T7"];
                            final idx = value.toInt();
                            final label = (idx >= 0 && idx < days.length) ? days[idx] : "";
                            return SideTitleWidget(axisSide: meta.axisSide, child: Text(label, style: const TextStyle(fontSize: 12)));
                          },
                        ),
                      ),
                    ),
                    gridData: FlGridData(show: true),
                    barGroups: weeklyProgress.map((wp) {
                      final weekday = int.parse(wp["weekday"].toString());
                      final count = (wp["count"] as int).toDouble();
                      return BarChartGroupData(
                        x: weekday,
                        barRods: [
                          BarChartRodData(
                            toY: count,
                            gradient: const LinearGradient(colors: [Color(0xFF6A11CB), Color(0xFF2575FC)]),
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

              // Filters + search + sort
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: "Tìm công việc theo tiêu đề hoặc danh mục...",
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                      onChanged: (v) {
                        setState(() {
                          searchQuery = v;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  DropdownButton<String>(
                    value: selectedSort,
                    items: ["Deadline", "Priority", "Status"].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                    onChanged: (v) {
                      setState(() {
                        selectedSort = v ?? "Deadline";
                      });
                    },
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Filters row
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _filterChip("Tất cả", selectedCategory == "Tất cả", () {
                    setState(() => selectedCategory = "Tất cả");
                  }),
                  ...categoryStats.map((c) => _filterChip(c["categoryName"] ?? "Không có danh mục", selectedCategory == (c["categoryName"] ?? ""), () {
                    setState(() => selectedCategory = c["categoryName"] ?? "Không có danh mục");
                  })),
                  _filterChip("Tất cả ưu tiên", selectedPriority == "Tất cả", () {
                    setState(() => selectedPriority = "Tất cả");
                  }),
                  _filterChip("Cao", selectedPriority == "Cao", () {
                    setState(() => selectedPriority = "Cao");
                  }),
                  _filterChip("Trung bình", selectedPriority == "Trung bình", () {
                    setState(() => selectedPriority = "Trung bình");
                  }),
                  _filterChip("Thấp", selectedPriority == "Thấp", () {
                    setState(() => selectedPriority = "Thấp");
                  }),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("Chỉ hiển thị đã hoàn thành"),
                      Switch(
                        value: showCompletedOnly,
                        onChanged: (v) async {
                          setState(() => showCompletedOnly = v);
                          await _loadStats();
                        },
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Task list header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_filteredTasks.isEmpty ? "Không có công việc" : "Danh sách công việc (${_filteredTasks.length})",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  TextButton.icon(
                    onPressed: () async {
                      await _loadStats();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text("Làm mới"),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Task list
              ..._filteredTasks.map((t) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: _statusColor(t.status).withOpacity(0.12),
                      child: Icon(
                        t.status == 1 ? Icons.check : (t.status == 2 ? Icons.play_arrow : Icons.radio_button_unchecked),
                        color: _statusColor(t.status),
                      ),
                    ),
                    title: Text(t.title ?? "", style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text("${t.categoryName ?? ""} • Deadline: ${_formatDate(t.deadline)}",
                            style: const TextStyle(color: Colors.black54, fontSize: 13)),
                      ],
                    ),
                    trailing: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _priorityColor(t.priority).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(_priorityText(t.priority), style: TextStyle(color: _priorityColor(t.priority), fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _statusColor(t.status).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(_statusText(t.status), style: TextStyle(color: _statusColor(t.status), fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TaskDetailPage(
                            task: t,
                            categoryId: t.categoryId ?? 0,
                            categoryName: t.categoryName ?? "Không có danh mục",
                          ),
                        ),
                      );
                      if (result == true) {
                        await _loadStats();
                      }
                    },
                  ),
                );
              }).toList(),
            ],
          ),
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
        boxShadow: [BoxShadow(color: colors.last.withOpacity(0.18), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _filterChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.blue.withOpacity(0.12) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? Colors.blue.withOpacity(0.2) : Colors.transparent),
        ),
        child: Text(label, style: TextStyle(color: selected ? Colors.blue : Colors.black87)),
      ),
    );
  }
}
