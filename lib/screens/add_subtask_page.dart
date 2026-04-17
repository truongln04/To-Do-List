import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/subtask_model.dart';
import '../../models/task_model.dart';

class AddSubTaskPage extends StatefulWidget {
  final Task parentTask;

  const AddSubTaskPage({super.key, required this.parentTask});

  @override
  State<AddSubTaskPage> createState() => _AddSubTaskPageState();
}

class _AddSubTaskPageState extends State<AddSubTaskPage> {
  final titleController = TextEditingController();
  final descController = TextEditingController();

  DateTime? dueDate;
  bool reminder = false;
  String reminderTime = "Trước 1 giờ";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      appBar: AppBar(
        title: const Text("Tạo Task Con", style: TextStyle(fontWeight: FontWeight.bold)),
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
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _saveSubTask,
            child: const Text("Lưu", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label("Tiêu đề *"),
              _input(titleController, "Nhập tiêu đề công việc", Icons.title),
              const SizedBox(height: 16),

              _label("Mô tả"),
              _input(descController, "Thêm mô tả", Icons.description, maxLines: 3),
              const SizedBox(height: 16),

              _label("Thuộc task cha"),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xffECEBFF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.folder, color: Colors.deepPurple),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(widget.parentTask.title,
                          style: const TextStyle(color: Colors.black54)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              _label("Ngày hết hạn"),
              _datePicker(),
              if (widget.parentTask.deadline != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    "Deadline cha: ${widget.parentTask.deadline}",
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              const SizedBox(height: 20),

              SwitchListTile(
                value: reminder,
                title: const Text("Nhắc việc"),
                activeColor: const Color(0xff4A6CF7),
                onChanged: (v) => setState(() => reminder = v),
              ),
              if (reminder)
                DropdownButtonFormField<String>(
                  value: reminderTime,
                  decoration: _boxDecoration(label: "Thời gian nhắc"),
                  items: ["Trước 30 phút", "Trước 1 giờ", "Trước 1 ngày"]
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setState(() => reminderTime = v!),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveSubTask() {
    if (titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập tiêu đề")),
      );
      return;
    }
    if (dueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng chọn deadline")),
      );
      return;
    }

    if (widget.parentTask.deadline != null) {
      final parentDeadline = DateTime.tryParse(widget.parentTask.deadline!);
      if (parentDeadline != null && dueDate!.isAfter(parentDeadline)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Deadline task con phải nhỏ hơn task cha")),
        );
        return;
      }
    }

    DateTime? notifyTime;
    if (reminder) {
      if (reminderTime == "Trước 30 phút") {
        notifyTime = dueDate!.subtract(const Duration(minutes: 30));
      } else if (reminderTime == "Trước 1 giờ") {
        notifyTime = dueDate!.subtract(const Duration(hours: 1));
      } else {
        notifyTime = dueDate!.subtract(const Duration(days: 1));
      }
    }

    final sub = SubTask(
      taskId: widget.parentTask.id!,
      title: titleController.text.trim(),
      description: descController.text.trim(),
      deadline: dueDate!.toIso8601String(),
      isDone: 0,
      isReminder: reminder ? 1 : 0,
      reminderTime: notifyTime?.toIso8601String(),
    );

    Navigator.pop(context, sub);
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
            Text(_formatDate(dueDate)),
            const Spacer(),
            const Icon(Icons.calendar_today_outlined, color: Colors.deepPurple),
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
