import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/custom_icons.dart';
import '../models/task_model.dart';
import '../services/subtask_service.dart';
import 'task_detail_page.dart';

class OverviewPage extends StatelessWidget {
  final Map<String, int> stats;
  final List<Task> tasks;

  const OverviewPage({super.key, required this.stats, required this.tasks});

  DateTime? _parseDate(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      return DateTime.parse(raw);
    } catch (_) {
      try {
        final cleaned = raw.split('.').first;
        return DateTime.parse(cleaned);
      } catch (_) {
        return null;
      }
    }
  }

  String _formatDateTimeString(String? raw) {
    final dt = _parseDate(raw);
    if (dt == null) return "";
    return DateFormat('dd/MM/yyyy HH:mm').format(dt);
  }

  String _statusText(int? status) {
    switch (status) {
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

  Color _statusColor(int? status) {
    switch (status) {
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

  /// Lọc chỉ lấy task của hôm nay
  List<Task> _onlyToday(List<Task> all) {
    final now = DateTime.now();
    return all.where((t) {
      final dt = _parseDate(t.deadline);
      if (dt == null) return false;
      return dt.year == now.year && dt.month == now.month && dt.day == now.day;
    }).toList();
  }

  /// Sắp xếp theo trạng thái: Đang làm (2) -> Chưa xong (0) -> Đã xong (1)
  List<Task> _sortByStatus(List<Task> list) {
    final order = {2: 0, 0: 1, 1: 2};
    list.sort((a, b) {
      final oa = order[a.status] ?? 3;
      final ob = order[b.status] ?? 3;
      if (oa != ob) return oa.compareTo(ob);
      // nếu cùng trạng thái, sắp theo deadline gần trước
      final da = _parseDate(a.deadline);
      final db = _parseDate(b.deadline);
      if (da == null && db == null) return 0;
      if (da == null) return 1;
      if (db == null) return -1;
      return da.compareTo(db);
    });
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final todayTasks = _sortByStatus(_onlyToday(tasks));

    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      appBar: AppBar(
        title: const Text("Chi tiết tổng quan", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00C9FF), Color(0xFF92FE9D)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Summary cards
            // Row(
            //   children: [
            //     _statCard("Đã hoàn thành", stats["done"] ?? 0, Colors.green),
            //     const SizedBox(width: 12),
            //     _statCard("Còn lại", (stats["total"] ?? 0) - (stats["done"] ?? 0), Colors.orange),
            //     const SizedBox(width: 12),
            //     _statCard("Quá hạn", stats["overdue"] ?? 0, Colors.red),
            //   ],
            // ),
            const SizedBox(height: 18),

            // Section header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Công việc hôm nay",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text("${todayTasks.length} công việc",
                    style: const TextStyle(color: Colors.black54)),
              ],
            ),
            const SizedBox(height: 12),

            // List
            Expanded(
              child: todayTasks.isEmpty
                  ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.calendar_today, size: 48, color: Colors.black26),
                    SizedBox(height: 8),
                    Text("Hôm nay không có công việc", style: TextStyle(color: Colors.black54)),
                  ],
                ),
              )
                  : ListView.separated(
                itemCount: todayTasks.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final t = todayTasks[i];
                  return _taskCard(context, t);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String label, int value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                label == "Đã hoàn thành" ? Icons.check_circle : (label == "Quá hạn" ? Icons.warning : Icons.access_time),
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                const SizedBox(height: 4),
                Text("$value", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _taskCard(BuildContext context, Task t) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          final customIcon = getCustomIcon(t.categoryName);
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TaskDetailPage(
                task: t,
                categoryId: t.categoryId ?? 0,
                categoryName: t.categoryName ?? "Không có danh mục",
                categoryIcon: customIcon.icon,
              ),
            ),
          );
          // nếu TaskDetailPage trả về true thì có thể refresh ở caller
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: status indicator circle (fixed size)
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _statusColor(t.status).withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  t.status == 2
                      ? Icons.play_arrow
                      : (t.status == 1 ? Icons.check : Icons.radio_button_unchecked),
                  color: _statusColor(t.status),
                ),
              ),
              const SizedBox(width: 12),

              // Middle: Expanded để chiếm không gian còn lại, tránh overflow
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title + priority badge (title có maxLines và ellipsis)
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            t.title,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _priorityColor(t.priority).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.flag, size: 14, color: _priorityColor(t.priority)),
                              const SizedBox(width: 6),
                              Text(
                                t.priority == 3 ? "Cao" : (t.priority == 2 ? "TB" : "Thấp"),
                                style: TextStyle(
                                    color: _priorityColor(t.priority),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Deadline row (có Expanded để tránh tràn)
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 14, color: Colors.blue),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _formatDateTimeString(t.deadline),
                            style: const TextStyle(color: Colors.black54, fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    // Progress bar (subtasks)
                    FutureBuilder<Map<String, int>>(
                      future: SubTaskService.getProgress(t.id!),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData || snapshot.data!["total"] == 0) {
                          return const SizedBox();
                        }
                        final done = snapshot.data!["done"]!;
                        final total = snapshot.data!["total"]!;
                        final percent = total == 0 ? 0.0 : done / total;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: percent,
                                minHeight: 6,
                                backgroundColor: Colors.grey.shade300,
                                color: _statusColor(t.status),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Text("$done/$total công việc con",
                                    style: const TextStyle(fontSize: 12, color: Colors.black54)),
                                const SizedBox(width: 8),
                                Text("${(percent * 100).toInt()}%",
                                    style: const TextStyle(fontSize: 12, color: Colors.black54)),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Right: giới hạn chiều rộng để không làm tràn Row
              SizedBox(
                width: 110, // điều chỉnh theo layout của bạn
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        t.categoryName ?? "Không có danh mục",
                        style: const TextStyle(fontSize: 12, color: Colors.black54),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: _statusColor(t.status).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _statusText(t.status),
                        style: TextStyle(
                            color: _statusColor(t.status), fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
