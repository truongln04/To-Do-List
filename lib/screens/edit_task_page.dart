import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task_model.dart';
import '../models/category_model.dart';
import '../services/task_service.dart';
import '../services/category_service.dart';

class EditTaskPage extends StatefulWidget {
  final Task task;

  const EditTaskPage({super.key, required this.task});

  @override
  State<EditTaskPage> createState() => _EditTaskPageState();
}

class _EditTaskPageState extends State<EditTaskPage> {
  late TextEditingController titleController;
  late TextEditingController descController;

  List<Category> categories = [];
  Category? category;

  DateTime? dueDate;
  String priority = "Cao";
  bool reminder = false;
  String reminderTime = "Trước 1 giờ";

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.task.title);
    descController = TextEditingController(text: widget.task.description);

    loadCategories();

    // convert priority int → string
    if (widget.task.priority == 3) priority = "Cao";
    if (widget.task.priority == 2) priority = "Trung bình";
    if (widget.task.priority == 1) priority = "Thấp";

    // convert deadline string → DateTime
    if (widget.task.deadline != null) {
      dueDate = DateTime.tryParse(widget.task.deadline!);
    }

    reminder = widget.task.isReminder == 1;
  }

  void loadCategories() async {
    categories = await CategoryService.getAll();

    // set category hiện tại
    category = categories.firstWhere(
          (c) => c.id == widget.task.categoryId,
      orElse: () => categories.isNotEmpty ? categories.first : Category(name: "", icon: ""),
    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      appBar: AppBar(
        title: const Text("Sửa công việc", style: TextStyle(fontWeight: FontWeight.bold)),
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
        actions: [
          TextButton(
            onPressed: _updateTask,
            child: const Text("Lưu", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _label("Tiêu đề *"),
            _input(titleController, "Nhập tiêu đề", Icons.title),
            const SizedBox(height: 16),

            _label("Mô tả"),
            _input(descController, "Thêm mô tả", Icons.description, maxLines: 3),
            const SizedBox(height: 16),

            _label("Danh mục"),
            DropdownButtonFormField<Category>(
              value: category,
              hint: const Text("Chọn danh mục"),
              items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c.name))).toList(),
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

            SwitchListTile(
              value: reminder,
              title: const Text("Nhắc việc"),
              activeColor: const Color(0xff4A6CF7),
              onChanged: (v) => setState(() => reminder = v),
            ),
            if (reminder)
              DropdownButtonFormField<String>(
                value: reminderTime,
                items: ["Trước 30 phút", "Trước 1 giờ", "Trước 1 ngày"]
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => reminderTime = v!),
                decoration: _boxDecoration(),
              ),
          ],
        ),
      ),
    );
  }

  void _updateTask() async {
    if (titleController.text.isEmpty) return;

    int prio = 2;
    if (priority == "Cao") prio = 3;
    if (priority == "Thấp") prio = 1;

    String? deadline = dueDate?.toIso8601String();

    String? remindTime;
    if (reminder && dueDate != null) {
      if (reminderTime == "Trước 30 phút") {
        remindTime = dueDate!.subtract(const Duration(minutes: 30)).toIso8601String();
      } else if (reminderTime == "Trước 1 giờ") {
        remindTime = dueDate!.subtract(const Duration(hours: 1)).toIso8601String();
      } else {
        remindTime = dueDate!.subtract(const Duration(days: 1)).toIso8601String();
      }
    }

    await TaskService.update(
      Task(
        id: widget.task.id,
        title: titleController.text.trim(),
        description: descController.text.trim(),
        deadline: deadline,
        priority: prio,
        categoryId: category?.id,
        isReminder: reminder ? 1 : 0,
        reminderTime: remindTime,
      ),
    );

    Navigator.pop(context, true); // trả về true để trang trước reload
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
      onTap: pickDate,
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

  void pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (d != null) {
      final t = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (t != null) {
        setState(() {
          dueDate = DateTime(d.year, d.month, d.day, t.hour, t.minute);
        });
      }
    }
  }

  String _formatDate(DateTime? d) {
    if (d == null) return "Chọn ngày & giờ";
    return DateFormat("dd/MM/yyyy HH:mm").format(d);
  }
}
