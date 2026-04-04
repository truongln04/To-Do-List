import 'package:flutter/material.dart';
import '../models/task_model.dart';

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
  String priority = "Cao";
  bool reminder = true;
  String reminderTime = "Trước 1 giờ";

  @override
  void initState() {
    super.initState();

    /// 👉 kế thừa từ task cha
    dueDate = widget.parentTask.dueDate;
    priority = widget.parentTask.priority;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),

      /// APPBAR
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Tạo Task Con",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _saveSubTask,
            child: const Text(
              "Lưu",
              style: TextStyle(
                color: Color(0xff4A6CF7),
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        ],
      ),

      /// BODY
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label("Tiêu đề *"),
              _input(titleController, "Nhập tiêu đề công việc"),

              const SizedBox(height: 16),

              _label("Mô tả"),
              _input(descController, "Thêm mô tả", maxLines: 3),

              const SizedBox(height: 16),

              /// KHÔNG CHO CHỌN DANH MỤC
              _label("Danh mục"),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xffF1F2F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "Thuộc: ${widget.parentTask.title}",
                  style: const TextStyle(color: Colors.grey),
                ),
              ),

              const SizedBox(height: 16),

              /// DEADLINE
              _label("Ngày hết hạn"),
              _datePicker(),

              /// HIỂN THỊ DEADLINE CHA
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  "Deadline cha: ${_formatDate(widget.parentTask.dueDate)}",
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),

              const SizedBox(height: 20),

              /// PRIORITY
              const Text("Ưu tiên",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),

              const SizedBox(height: 10),

              _priorityItem("Cao", Colors.red),
              _priorityItem("Trung bình", Colors.orange),
              _priorityItem("Thấp", Colors.green),

              const SizedBox(height: 20),

              /// REMINDER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Nhắc việc"),
                  Switch(
                    value: reminder,
                    onChanged: (v) => setState(() => reminder = v),
                  )
                ],
              ),

              if (reminder) ...[
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: reminderTime,
                  decoration: _boxDecoration(label: "Thời gian nhắc"),
                  items: ["Trước 30 phút", "Trước 1 giờ", "Trước 1 ngày"]
                      .map((e) =>
                      DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setState(() => reminderTime = v!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// ===== SAVE =====
  void _saveSubTask() {
    if (titleController.text.isEmpty || dueDate == null) return;

    /// ❗ VALIDATE
    if (widget.parentTask.dueDate != null &&
        dueDate!.isAfter(widget.parentTask.dueDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Deadline task con phải nhỏ hơn task cha"),
        ),
      );
      return;
    }

    final sub = SubTask(
      title: titleController.text,
      dueDate: dueDate,
    );

    Navigator.pop(context, sub);
  }

  /// ===== UI giống AddTask =====

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text,
          style: const TextStyle(fontSize: 14, color: Colors.black54)),
    );
  }

  Widget _input(TextEditingController c, String hint,
      {int maxLines = 1}) {
    return TextField(
      controller: c,
      maxLines: maxLines,
      decoration: InputDecoration(
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

  InputDecoration _boxDecoration({String? label}) {
    return InputDecoration(
      labelText: label,
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
        final date = await showDatePicker(
          context: context,
          initialDate: dueDate ?? DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: widget.parentTask.dueDate ?? DateTime(2030),
        );

        if (date != null) {
          final time = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
          );

          if (time != null) {
            setState(() {
              dueDate = DateTime(
                  date.year, date.month, date.day, time.hour, time.minute);
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
            const Icon(Icons.calendar_today_outlined),
          ],
        ),
      ),
    );
  }

  Widget _priorityItem(String text, Color color) {
    final isSelected = priority == text;

    return GestureDetector(
      onTap: () => setState(() => priority = text),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.flag, color: color),
            const SizedBox(width: 10),
            Text(text),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? d) {
    if (d == null) return "Chọn ngày & giờ";
    return "${d.day}/${d.month}/${d.year} "
        "${d.hour}:${d.minute.toString().padLeft(2, '0')}";
  }
}