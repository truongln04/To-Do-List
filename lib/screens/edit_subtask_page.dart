import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/subtask_model.dart';
import '../../models/task_model.dart';

class EditSubTaskPage extends StatefulWidget {
  final Task parentTask;
  final SubTask subTask;

  const EditSubTaskPage({
    super.key,
    required this.parentTask,
    required this.subTask,
  });

  @override
  State<EditSubTaskPage> createState() => _EditSubTaskPageState();
}

class _EditSubTaskPageState extends State<EditSubTaskPage> {
  late TextEditingController titleController;
  late TextEditingController descController;

  DateTime? dueDate;
  bool reminder = false;
  String reminderOption = "Trước 1 giờ";

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.subTask.title);
    descController = TextEditingController(text: widget.subTask.description ?? "");
    if (widget.subTask.deadline != null) {
      dueDate = DateTime.tryParse(widget.subTask.deadline!);
    }
    reminder = widget.subTask.isReminder == 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      appBar: AppBar(
        title: const Text("Chỉnh sửa Task Con", style: TextStyle(fontWeight: FontWeight.bold)),
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
            child: const Text("Cập nhật", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label("Tiêu đề *"),
            _input(titleController, "Nhập tiêu đề", Icons.title),
            const SizedBox(height: 16),

            _label("Mô tả"),
            _input(descController, "Thêm mô tả", Icons.description, maxLines: 3),
            const SizedBox(height: 16),

            _label("Thuộc task cha"),
            _box(widget.parentTask.title),
            const SizedBox(height: 16),

            _label("Ngày hết hạn"),
            _datePicker(),
            if (widget.parentTask.deadline != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text("Deadline cha: ${widget.parentTask.deadline}",
                    style: const TextStyle(color: Colors.red, fontSize: 12)),
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
                value: reminderOption,
                decoration: _inputDecoration("Thời gian nhắc"),
                items: ["Trước 30 phút", "Trước 1 giờ", "Trước 1 ngày"]
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => reminderOption = v!),
              ),
          ],
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
      final parent = DateTime.parse(widget.parentTask.deadline!);
      if (dueDate!.isAfter(parent)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Deadline task con phải nhỏ hơn task cha")),
        );
        return;
      }
    }

    String? reminderTime;
    if (reminder) {
      DateTime notify = dueDate!;
      if (reminderOption == "Trước 30 phút") {
        notify = dueDate!.subtract(const Duration(minutes: 30));
      } else if (reminderOption == "Trước 1 giờ") {
        notify = dueDate!.subtract(const Duration(hours: 1));
      } else {
        notify = dueDate!.subtract(const Duration(days: 1));
      }
      reminderTime = notify.toIso8601String();
    }

    final updated = SubTask(
      id: widget.subTask.id,
      taskId: widget.parentTask.id!,
      title: titleController.text.trim(),
      description: descController.text.trim(),
      deadline: dueDate!.toIso8601String(),
      isDone: widget.subTask.isDone,
      isReminder: reminder ? 1 : 0,
      reminderTime: reminderTime,
    );

    Navigator.pop(context, updated);
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

  Widget _box(String text) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xffECEBFF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.folder, color: Colors.deepPurple),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(color: Colors.black54))),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xffF1F2F6),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _datePicker() {
    return GestureDetector(
      onTap: () async {
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
            const Icon(Icons.calendar_today, color: Colors.deepPurple),
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