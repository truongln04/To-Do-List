import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task_model.dart';
import '../models/category_model.dart';
import '../services/task_service.dart';
import '../services/category_service.dart';
import '../services/notification_service.dart';

class AddTaskPage extends StatefulWidget {
  final int? defaultCategoryId;
  final String? defaultCategoryName;

  const AddTaskPage({
    super.key,
    this.defaultCategoryId,
    this.defaultCategoryName,
  });

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final titleController = TextEditingController();
  final descController = TextEditingController();

  List<Category> categories = [];
  Category? category;

  DateTime? dueDate;
  String priority = "Cao";
  bool reminder = true;
  String reminderTime = "Trước 1 giờ";

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  void loadCategories() async {
    categories = await CategoryService.getAll();
    if (widget.defaultCategoryId != null) {
      category = categories.firstWhere(
            (c) => c.id == widget.defaultCategoryId,
        orElse: () => categories.isNotEmpty ? categories.first : null as Category,
      );
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      appBar: AppBar(
        title: const Text("Tạo Công Việc", style: TextStyle(fontWeight: FontWeight.bold)),
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
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _saveTask,
            child: const Text("Lưu", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _label("Tiêu đề *"),
            _input(titleController, "Nhập tiêu đề công việc", Icons.title),
            const SizedBox(height: 16),

            _label("Mô tả"),
            _input(descController, "Thêm mô tả", Icons.description, maxLines: 3),
            const SizedBox(height: 16),

            _label("Danh mục"),
            DropdownButtonFormField<Category>(
              value: category,
              hint: const Text("Chọn danh mục"),
              items: categories.map((c) {
                return DropdownMenuItem(value: c, child: Text(c.name));
              }).toList(),
              onChanged: (v) => setState(() => category = v),
              decoration: _boxDecoration(),
            ),
            const SizedBox(height: 16),

            _label("Ngày hết hạn"),
            _datePicker(),
            const SizedBox(height: 16),

            _label("Ưu tiên"),
            DropdownButtonFormField<String>(
              value: priority,
              items: ["Cao", "Trung bình", "Thấp"]
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => priority = v!),
              decoration: _boxDecoration(),
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Nhắc việc"),
                Switch(
                  value: reminder,
                  onChanged: (v) => setState(() => reminder = v),
                  activeColor: const Color(0xff4A6CF7),
                )
              ],
            ),
            if (reminder) ...[
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: reminderTime,
                decoration: _boxDecoration(label: "Thời gian nhắc"),
                items: ["Trước 3 phút", "Trước 1 giờ", "Trước 1 ngày"]
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => reminderTime = v!),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _saveTask() async {
    if (titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tiêu đề không được để trống")),
      );
      return;
    }

    // kiểm tra trùng tên
    final allTasks = await TaskService.getAll();
    final exists = allTasks.any((t) =>
    t.title.trim().toLowerCase() == titleController.text.trim().toLowerCase());
    if (exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tiêu đề công việc đã tồn tại")),
      );
      return;
    }

    // mức ưu tiên
    int prio = 2;
    if (priority == "Cao") prio = 3;
    if (priority == "Thấp") prio = 1;

    // deadline
    String? deadline;
    if (dueDate != null) {
      deadline = dueDate!.toIso8601String();
    }

    // thời gian nhắc
    DateTime? notifyTime;
    if (reminder && dueDate != null) {
      if (reminderTime == "Trước 3 phút") {
        notifyTime = dueDate!.subtract(const Duration(minutes: 3));
      } else if (reminderTime == "Trước 1 giờ") {
        notifyTime = dueDate!.subtract(const Duration(hours: 1));
      } else {
        notifyTime = dueDate!.subtract(const Duration(days: 1));
      }
    }
    debugPrint("NotifyTime: $notifyTime, Now: ${DateTime.now()}");

    // tạo task mới
    final task = Task(
      title: titleController.text.trim(),
      description: descController.text.trim(),
      deadline: deadline,
      priority: prio,
      categoryId: category?.id ?? widget.defaultCategoryId,
      isReminder: reminder ? 1 : 0,
      reminderTime: notifyTime?.toIso8601String(),
    );

    int? taskId;
    try {
      taskId = await TaskService.insert(task);
    } catch (e) {
      // Lưu task thất bại
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lưu công việc thất bại: $e")),
      );
      return;
    }

    // xử lý notification trong try/catch để không làm gián đoạn điều hướng
    if (reminder && notifyTime != null) {
      if (notifyTime.isAfter(DateTime.now())) {
        try {
          await NotificationService.schedule(
            taskId, // dùng taskId làm id
            "Nhắc việc",
            task.title,
            notifyTime,
            taskId: taskId,
            type: 1,
          );
        } on Exception catch (e) {
          // Bắt lỗi plugin/permission, hiển thị thông báo nhưng không ngăn điều hướng
          debugPrint("Notification schedule failed: $e");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Không thể tạo thông báo. Kiểm tra quyền ứng dụng.")),
          );
          // Nếu muốn: gọi NotificationService.cancel(taskId) để đảm bảo không có rác
          try {
            await NotificationService.cancel(taskId);
          } catch (_) {}
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Thời gian nhắc đã qua, không thể tạo thông báo")),
        );
      }
    } else {
      // Nếu reminder = false thì hủy notification (nếu có)
      try {
        await NotificationService.cancel(taskId);
      } catch (_) {}
    }

    // Điều hướng về trang trước, trả true để refresh danh sách
    if (mounted) Navigator.pop(context, true);
  }


  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text, style: const TextStyle(fontSize: 14, color: Colors.black54)),
  );

  Widget _input(TextEditingController c, String hint, IconData icon, {int maxLines = 1}) {
    return TextField(
      controller: c,
      maxLines: maxLines,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.deepPurple),
        hintText: hint,
        filled: true,
        fillColor: const Color(0xffF1F2F6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  InputDecoration _boxDecoration({String? label}) => InputDecoration(
    labelText: label,
    filled: true,
    fillColor: const Color(0xffF1F2F6),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
  );

  Widget _datePicker() {
    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: dueDate ?? DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime(2030),
        );
        if (date != null) {
          final time = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
          );
          if (time != null) {
            setState(() {
              dueDate = DateTime(date.year, date.month, date.day, time.hour, time.minute);
            });
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xffF1F2F6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: Colors.deepPurple),
            const SizedBox(width: 8),
            Text(_formatDate(dueDate), style: const TextStyle(fontWeight: FontWeight.w600)),
            const Spacer(),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? d) {
    if (d == null) return "Chọn ngày & giờ";
    return DateFormat("dd/MM/yyyy HH:mm").format(d);
  }
}