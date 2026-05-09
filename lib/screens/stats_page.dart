// lib/screens/stats_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/custom_icons.dart';
import '../services/stats_service.dart';
import '../models/task_model.dart';
import '../models/subtask_model.dart';
import 'task_detail_page.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  // Data
  Map<String, int> stats = {"total": 0, "done": 0, "overdue": 0, "doing": 0};
  List<Map<String, dynamic>> categoryStats = [];
  List<Map<String, dynamic>> weeklyProgress = [];
  List<Task> tasks = [];
  List<SubTask> subtasks = [];

  // UI state / filters
  bool loading = true;
  bool showCompletedOnly = false;
  String selectedCategory = "Tất cả";
  String selectedPriority = "Tất cả";
  String selectedSort = "Deadline"; // "Deadline", "Priority", "Status"
  int? selectedStatus; // null = all, 0 = todo, 1 = done, 2 = doing
  String searchQuery = "";
  DateTimeRange? selectedRange;

  // Pie interaction
  int? touchedPieIndex;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => loading = true);

    try {
      final overview = await StatsService.getOverviewStats(range: selectedRange);
// Thay các dòng cũ bằng:
      stats["total"] = (overview['total'] as int?) ?? 0;
      stats["done"] = (overview['done'] as int?) ?? 0;
      stats["overdue"] = (overview['overdue'] as int?) ?? 0;
      stats["doing"] = (overview['doing'] as int?) ?? 0;


      categoryStats = await StatsService.getCategoryStats(range: selectedRange);
      weeklyProgress = await StatsService.getWeeklyProgress(range: selectedRange);

      final rawTasks = await StatsService.getTasks(completedOnly: showCompletedOnly, range: selectedRange);
      final rawSubtasks = await StatsService.getSubtasks(completedOnly: showCompletedOnly, range: selectedRange);

      tasks = (rawTasks as List).map<Task>((m) => Task.fromMap(m as Map<String, dynamic>)).toList();
      subtasks = (rawSubtasks as List).map<SubTask>((m) => SubTask.fromMap(m as Map<String, dynamic>)).toList();

      // Defensive recalculation if overview missing values
      // Note: SubTask uses isDone (0/1). We treat isDone==1 as done.
      if (stats["doing"] == 0) {
        stats["doing"] = tasks.where((t) => t.status == 2).length;
        // Subtasks in your model don't have "doing" state; if you add it later include here.
      }
      if (stats["total"] == 0) {
        stats["total"] = tasks.length + subtasks.length;
      }
      if (stats["done"] == 0) {
        stats["done"] = tasks.where((t) => t.status == 1).length + subtasks.where((s) => s.isDone == 1).length;
      }
      if (stats["overdue"] == 0) {
        final now = DateTime.now();
        int overdueCount = 0;
        for (final t in tasks) {
          final dt = _parseDate(t.deadline);
          if (dt != null && dt.isBefore(now) && t.status != 1) overdueCount++;
        }
        for (final s in subtasks) {
          final dt = _parseDate(s.deadline);
          if (dt != null && dt.isBefore(now) && s.isDone != 1) overdueCount++;
        }
        stats["overdue"] = overdueCount;
      }
    } catch (e) {
      debugPrint("Error loading stats: $e");
      stats = {"total": 0, "done": 0, "overdue": 0, "doing": 0};
      categoryStats = [];
      weeklyProgress = [];
      tasks = [];
      subtasks = [];
    }

    setState(() => loading = false);
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

  String _formatDate(String? raw) {
    final dt = _parseDate(raw);
    if (dt == null) return "";
    return DateFormat('dd/MM/yyyy HH:mm').format(dt);
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

  // Combined list of tasks + subtasks for listing/filtering
  List<dynamic> get _allItems => [...tasks, ...subtasks];

  // Helper to get category name for a subtask (fallback to parent task)
  String _categoryNameFor(dynamic item) {
    if (item is Task) return item.categoryName ?? "Không có danh mục";
    if (item is SubTask) {
      // try to find parent task's categoryName
      final parent = tasks.firstWhere((t) => t.id == item.taskId, orElse: () => Task(id: null, title: '', priority: 2));
      return parent.categoryName ?? "Không có danh mục";
    }
    return "Không có danh mục";
  }

  // Helper to get priority for an item (subtask fallback to parent task)
  int _priorityFor(dynamic item) {
    if (item is Task) return item.priority;
    if (item is SubTask) {
      final parent = tasks.firstWhere((t) => t.id == item.taskId, orElse: () => Task(id: null, title: '', priority: 2));
      return parent.priority;
    }
    return 2;
  }

  // Helper to get status normalized to 0/1/2
  int _statusFor(dynamic item) {
    if (item is Task) return item.status ?? 0;
    if (item is SubTask) {
      // SubTask uses isDone (0/1). Treat as 1 = done, 0 = todo.
      return (item.isDone == 1) ? 1 : 0;
    }
    return 0;
  }

  List<dynamic> get _filteredItems {
    var list = _allItems.where((item) {
      final title = (item.title ?? "").toString().toLowerCase();
      final cat = _categoryNameFor(item);
      final priority = _priorityFor(item);
      final status = _statusFor(item);

      if (showCompletedOnly && status != 1) return false;
      if (selectedStatus != null && status != selectedStatus) return false;
      if (selectedCategory != "Tất cả" && cat != selectedCategory) return false;
      if (selectedPriority != "Tất cả" && _priorityText(priority) != selectedPriority) return false;
      if (searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        if (!title.contains(q) && !cat.toLowerCase().contains(q)) return false;
      }
      // date range filter (deadline)
      if (selectedRange != null) {
        final dt = _parseDate(item.deadline);
        if (dt == null) return false;
        if (dt.isBefore(selectedRange!.start) || dt.isAfter(selectedRange!.end)) return false;
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
      list.sort((a, b) => _priorityFor(b).compareTo(_priorityFor(a)));
    } else if (selectedSort == "Status") {
      final order = {2: 0, 0: 1, 1: 2};
      list.sort((a, b) {
        final oa = order[_statusFor(a)] ?? 3;
        final ob = order[_statusFor(b)] ?? 3;
        return oa.compareTo(ob);
      });
    }

    return list;
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 3),
      lastDate: DateTime(now.year + 1),
      initialDateRange: selectedRange,
    );
    if (picked != null) {
      setState(() => selectedRange = picked);
      await _loadStats();
    }
  }

  void _clearRange() {
    setState(() => selectedRange = null);
    _loadStats();
  }

  Widget _buildStatCard(String title, String value, List<Color> colors, String subtitle, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: colors.last.withOpacity(0.18), blurRadius: 6)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(subtitle, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  // Show subtask details in a bottom sheet (fallback when no SubtaskDetailPage)
  void _showSubtaskDetailModal(SubTask s) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        final parent = tasks.firstWhere((t) => t.id == s.taskId, orElse: () => Task(id: null, title: '', priority: 2));
        final customIcon = getCustomIcon(parent.categoryName);
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Chi tiết Subtask", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                  ],
                ),
                const SizedBox(height: 8),
                ListTile(
                  leading: Icon(Icons.subdirectory_arrow_right, color: _statusColor(_statusFor(s))),
                  title: Text(s.title),
                  subtitle: Text("Danh mục: ${parent.categoryName ?? "Không có"}"),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16),
                    const SizedBox(width: 8),
                    Text("Deadline: ${_formatDate(s.deadline)}"),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.flag, size: 16),
                    const SizedBox(width: 8),
                    Text("Ưu tiên: ${_priorityText(_priorityFor(s))}"),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.info, size: 16),
                    const SizedBox(width: 8),
                    Text("Trạng thái: ${_statusText(_statusFor(s))}"),
                  ],
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TaskDetailPage(task: parent, categoryId: parent.categoryId ?? 0, categoryName: parent.categoryName ?? "",categoryIcon: customIcon.icon,),
                      ),
                    );
                  },
                  icon: const Icon(Icons.open_in_new),
                  label: const Text("Mở Task cha"),
                ),
                const SizedBox(height: 8),
                TextButton(onPressed: () => Navigator.pop(context), child: const Text("Đóng")),
              ],
            ),
          ),
        );
      },
    );
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
            Icon(Icons.bar_chart),
            SizedBox(width: 8),
            Text("Thống kê", style: TextStyle(fontWeight: FontWeight.bold))]),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFF00C9FF), Color(0xFF92FE9D)]),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadStats,
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (selectedRange != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    "Khoảng: ${DateFormat('dd/MM/yyyy').format(selectedRange!.start)} - ${DateFormat('dd/MM/yyyy').format(selectedRange!.end)}",
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ),

              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _buildStatCard("Tổng", total.toString(), [Colors.indigo, Colors.blue], "Tất cả công việc", onTap: () {
                        setState(() {
                          selectedCategory = "Tất cả";
                          selectedStatus = null;
                          showCompletedOnly = false;
                        });
                      }),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard("Hoàn thành", done.toString(), [Colors.green, Colors.teal], "Công việc đã xong", onTap: () {
                        setState(() {
                          selectedStatus = 1;
                          showCompletedOnly = true;
                        });
                      }),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard("Đang làm", doing.toString(), [Colors.blue, Colors.lightBlue], "Công việc đang tiến hành", onTap: () {
                        setState(() {
                          selectedStatus = 2;
                          showCompletedOnly = false;
                        });
                      }),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard("Quá hạn", overdue.toString(), [Colors.red, Colors.deepOrange], "Công việc quá hạn", onTap: () {
                        setState(() {
                          selectedStatus = null;
                        });
                      }),
                    ),
                  ],
                ),
              ),


              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)]),
                child: Row(
                  children: [
                    SizedBox(
                      width: 110,
                      height: 110,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          PieChart(
                            PieChartData(
                              centerSpaceRadius: 30,
                              sectionsSpace: 2,
                              sections: [
                                PieChartSectionData(color: Colors.green, value: done.toDouble(), title: '', radius: 40),
                                PieChartSectionData(color: Colors.blue, value: doing.toDouble(), title: '', radius: 40),
                                PieChartSectionData(color: Colors.grey.shade300, value: (todoCount > 0 ? todoCount.toDouble() : 0.0), title: '', radius: 40),
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
                            final idx = response.touchedSection!.touchedSectionIndex;
                            setState(() {
                              touchedPieIndex = idx;
                              selectedCategory = categoryStats[idx]["categoryName"] ?? "Tất cả";
                            });
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
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(categoryStats.length, (i) {
                        final cat = categoryStats[i];
                        final color = Colors.primaries[i % Colors.primaries.length];
                        final name = cat["categoryName"] ?? "Không có danh mục";
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedCategory = name;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: selectedCategory == name ? color.withOpacity(0.12) : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: color.withOpacity(0.12)),
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
                  ),
                ],
              ),

              const SizedBox(height: 20),

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

              const SizedBox(height: 12),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _filterChip("Tất cả", selectedCategory == "Tất cả", () => setState(() => selectedCategory = "Tất cả")),
                  ...categoryStats.map((c) => _filterChip(c["categoryName"] ?? "Không có danh mục", selectedCategory == (c["categoryName"] ?? ""), () {
                    setState(() => selectedCategory = c["categoryName"] ?? "Không có danh mục");
                  })),
                  _filterChip("Tất cả ưu tiên", selectedPriority == "Tất cả", () => setState(() => selectedPriority = "Tất cả")),
                  _filterChip("Cao", selectedPriority == "Cao", () => setState(() => selectedPriority = "Cao")),
                  _filterChip("Trung bình", selectedPriority == "Trung bình", () => setState(() => selectedPriority = "Trung bình")),
                  _filterChip("Thấp", selectedPriority == "Thấp", () => setState(() => selectedPriority = "Thấp")),
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

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_filteredItems.isEmpty ? "Không có công việc" : "Danh sách (${_filteredItems.length})", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  TextButton.icon(onPressed: _loadStats, icon: const Icon(Icons.refresh), label: const Text("Làm mới")),
                ],
              ),

              const SizedBox(height: 8),

              ..._filteredItems.map((item) {
                final isTask = item is Task;
                final title = item.title ?? "";
                final catName = _categoryNameFor(item);
                final deadline = _formatDate(item.deadline);
                final priority = _priorityFor(item);
                final status = _statusFor(item);
                final customIcon = getCustomIcon(catName);

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _statusColor(status).withOpacity(0.12),
                      child: Icon(isTask ? (status == 1 ? Icons.check : (status == 2 ? Icons.play_arrow : Icons.task)) : Icons.subdirectory_arrow_right, color: _statusColor(status)),
                    ),
                    title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text("$catName • Deadline: $deadline", style: const TextStyle(color: Colors.black54)),
                    trailing: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: _priorityColor(priority).withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
                          child: Text(_priorityText(priority), style: TextStyle(color: _priorityColor(priority), fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: _statusColor(status).withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
                          child: Text(_statusText(status), style: TextStyle(color: _statusColor(status), fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    onTap: () async {
                      if (isTask) {

                        final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => TaskDetailPage(task: item as Task, categoryId: item.categoryId ?? 0, categoryName: item.categoryName ?? "",categoryIcon: customIcon.icon,)));
                        if (result == true) await _loadStats();
                      } else {
                        _showSubtaskDetailModal(item as SubTask);
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
