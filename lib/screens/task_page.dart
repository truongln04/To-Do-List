import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task_model.dart';
import '../services/task_service.dart';
import '../services/subtask_service.dart';
import 'task_detail_page.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  List<Task> tasks = [];
  List<String> categories = ["Tất cả"];
  String searchQuery = "";
  String selectedCategory = "Tất cả";
  String selectedPriority = "Tất cả";
  String selectedDateFilter = "Tất cả"; // legacy quick filters (Hôm nay, Tuần này, ...)
  String selectedStatus = "Tất cả"; // "Tất cả", "Chưa xong", "Đang làm", "Đã xong"
  DateTime? selectedDate; // specific date picker

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _searchTasks();
  }

  Future<void> _loadCategories() async {
    final cats = await TaskService.getAllCategories();
    categories = ["Tất cả"] + cats;
    setState(() {});
  }

  Future<void> _searchTasks() async {
    // Get base results from service (service may already support some filters)
    final results = await TaskService.searchTasks(
      query: searchQuery,
      category: selectedCategory,
      priority: selectedPriority,
      dateFilter: selectedDateFilter,
    );

    // Apply additional local filters: selectedDate and selectedStatus
    tasks = results.where((t) {
      // filter by selectedDate if set
      if (selectedDate != null) {
        final dl = _parseDate(t.deadline);
        if (dl == null) return false;
        if (!_isSameDate(dl, selectedDate!)) return false;
      }

      // filter by selectedStatus
      if (selectedStatus != "Tất cả") {
        final statusText = _statusText(t.status);
        if (statusText != selectedStatus) return false;
      }

      return true;
    }).toList();

    setState(() {});
  }

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

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
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

  Color _categoryColor(String? name) {
    switch (name) {
      case "Công việc":
        return const Color(0xFF2F80ED); // blue
      case "Học tập":
        return const Color(0xFF6A11CB); // purple
      case "Cá nhân":
        return const Color(0xFF27AE60); // green
      case "Sức khỏe":
        return const Color(0xFFEB5757); // red
      case "Mua sắm":
        return const Color(0xFFF2994A); // orange
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String? name) {
    switch (name) {
      case "Công việc":
        return Icons.work;
      case "Học tập":
        return Icons.school;
      case "Cá nhân":
        return Icons.person;
      case "Sức khỏe":
        return Icons.favorite;
      case "Mua sắm":
        return Icons.shopping_cart;
      default:
        return Icons.category;
    }
  }

  String _priorityText(int? p) {
    switch (p) {
      case 1:
        return "Thấp";
      case 2:
        return "Trung bình";
      case 3:
        return "Cao";
      default:
        return "Không rõ";
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

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      selectedDate = picked;
      // clear quick date filter when specific date chosen
      selectedDateFilter = "Tất cả";
      await _searchTasks();
    }
  }

  void _clearDate() {
    selectedDate = null;
    _searchTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: const [
            Icon(Icons.task_alt, color: Colors.white),
            SizedBox(width: 8),
            Text("Danh sách công việc", style: TextStyle(fontWeight: FontWeight.bold)),
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
      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search, color: Colors.deepPurple),
                hintText: "Tìm kiếm công việc...",
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                searchQuery = value;
                _searchTasks();
              },
            ),
          ),

          // Filters row (category, priority, status)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedCategory,
                        decoration: InputDecoration(
                          labelText: "Danh mục",
                          labelStyle: const TextStyle(fontSize: 13),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.grey[100],
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                        items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                        onChanged: (value) {
                          selectedCategory = value ?? "Tất cả";
                          _searchTasks();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedPriority,
                        decoration: InputDecoration(
                          labelText: "Ưu tiên",
                          labelStyle: const TextStyle(fontSize: 13),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.grey[100],
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                        items: ["Tất cả", "Thấp", "Trung bình", "Cao"]
                            .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                            .toList(),
                        onChanged: (value) {
                          selectedPriority = value ?? "Tất cả";
                          _searchTasks();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedStatus,
                        decoration: InputDecoration(
                          labelText: "Trạng thái",
                          labelStyle: const TextStyle(fontSize: 13),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.grey[100],
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                        items: ["Tất cả", "Chưa xong", "Đang làm", "Đã xong"]
                            .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                            .toList(),
                        onChanged: (value) {
                          selectedStatus = value ?? "Tất cả";
                          _searchTasks();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedDateFilter,
                        decoration: InputDecoration(
                          labelText: "Thời gian (nhanh)",
                          labelStyle: const TextStyle(fontSize: 13),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.grey[100],
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                        items: ["Tất cả", "Hôm nay", "Tuần này", "Quá hạn"]
                            .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                            .toList(),
                        onChanged: (value) {
                          selectedDateFilter = value ?? "Tất cả";
                          // clear specific date when quick filter used
                          selectedDate = null;
                          _searchTasks();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // Specific date picker
                    Expanded(
                      child: GestureDetector(
                        onTap: _pickDate,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.transparent),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_month, color: Colors.deepPurple),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  selectedDate == null
                                      ? "Chọn ngày cụ thể"
                                      : DateFormat('dd/MM/yyyy').format(selectedDate!),
                                  style: TextStyle(
                                    color: selectedDate == null ? Colors.black54 : Colors.black87,
                                  ),
                                ),
                              ),
                              if (selectedDate != null)
                                GestureDetector(
                                  onTap: () {
                                    _clearDate();
                                  },
                                  child: const Icon(Icons.close, size: 18, color: Colors.black54),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Reset filters
                    GestureDetector(
                      onTap: () {
                        selectedCategory = "Tất cả";
                        selectedPriority = "Tất cả";
                        selectedDateFilter = "Tất cả";
                        selectedStatus = "Tất cả";
                        selectedDate = null;
                        searchQuery = "";
                        _searchTasks();
                        setState(() {});
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.refresh, size: 18, color: Colors.black54),
                            SizedBox(width: 6),
                            Text("Đặt lại", style: TextStyle(color: Colors.black54)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Task list
          Expanded(
            child: tasks.isEmpty
                ? const Center(child: Text("Không có công việc nào"))
                : ListView.builder(
              itemCount: tasks.length,
              padding: const EdgeInsets.only(bottom: 12),
              itemBuilder: (context, index) {
                final t = tasks[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 3,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    leading: CircleAvatar(
                      backgroundColor: _categoryColor(t.categoryName).withOpacity(0.12),
                      child: Icon(_getCategoryIcon(t.categoryName), color: _categoryColor(t.categoryName)),
                    ),
                    title: Text(t.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        // Deadline (tách riêng)
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 14, color: Colors.blue),
                            const SizedBox(width: 6),
                            Text(
                              _formatDateTimeString(t.deadline),
                              style: const TextStyle(color: Colors.black54, fontSize: 13),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // Trạng thái + ưu tiên (tách riêng, inline)
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black12,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.info_outline, size: 14, color: Colors.black54),
                                  const SizedBox(width: 6),
                                  Text(_statusText(t.status), style: const TextStyle(fontSize: 13, color: Colors.black54)),
                                ],
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
                                  Text(_priorityText(t.priority), style: TextStyle(fontSize: 13, color: _priorityColor(t.priority))),
                                ],
                              ),
                            ),
                          ],
                        ),

                        // Progress bar for subtasks
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
                                    color: _categoryColor(t.categoryName),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Text("$done/$total công việc con", style: const TextStyle(fontSize: 12, color: Colors.black54)),
                                    const SizedBox(width: 8),
                                    Text("${(percent * 100).toInt()}%", style: const TextStyle(fontSize: 12, color: Colors.black54)),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TaskDetailPage(
                            task: t,
                            categoryId: t.categoryId ?? 0,
                            categoryName: t.categoryName ?? "Không có danh mục",
                            categoryIcon: _getCategoryIcon(t.categoryName),
                          ),
                        ),
                      ).then((value) => _searchTasks());
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
