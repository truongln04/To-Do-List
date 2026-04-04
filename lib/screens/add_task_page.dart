import 'package:flutter/material.dart';

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({super.key});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final titleController = TextEditingController();
  final descController = TextEditingController();

  String? category;
  DateTime? dueDate;
  String priority = "Cao";
  bool reminder = true;
  String reminderTime = "Trước 1 giờ";

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
          "Tạo Công Việc",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {},
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
              /// TIÊU ĐỀ
              _label("Tiêu đề *"),
              _input(titleController, "Nhập tiêu đề công việc"),

              const SizedBox(height: 16),

              /// MÔ TẢ
              _label("Mô tả"),
              _input(descController, "Thêm mô tả (tùy chọn)", maxLines: 3),

              const SizedBox(height: 16),

              /// DANH MỤC
              _label("Danh mục"),
              DropdownButtonFormField<String>(
                value: category,
                hint: const Text("Chọn danh mục"),
                decoration: _boxDecoration(),
                items: ["Học tập", "Công việc", "Cá nhân"]
                    .map((e) =>
                    DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => category = v),
              ),

              const SizedBox(height: 16),

              /// NGÀY GIỜ
              _label("Ngày hết hạn"),
              _datePicker(),

              const SizedBox(height: 20),

              /// PRIORITY
              const Text("Ưu tiên",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),

              _priorityItem("Cao", Colors.red),
              const SizedBox(height: 8),
              _priorityItem("Trung bình", Colors.orange),
              const SizedBox(height: 8),
              _priorityItem("Thấp", Colors.green),

              const SizedBox(height: 20),

              /// NHẮC VIỆC
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Nhắc việc",
                      style:
                      TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                  Switch(
                    value: reminder,
                    onChanged: (v) => setState(() => reminder = v),
                    activeColor: const Color(0xff4A6CF7),
                  )
                ],
              ),

              /// CHỈ HIỆN KHI BẬT
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

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  /// LABEL
  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text,
          style: const TextStyle(fontSize: 14, color: Colors.black54)),
    );
  }

  /// INPUT
  Widget _input(TextEditingController c, String hint,
      {int maxLines = 1}) {
    return TextField(
      controller: c,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xffF1F2F6),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  /// BOX
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

  /// DATE PICKER
  Widget _datePicker() {
    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
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
              dueDate = DateTime(
                  date.year, date.month, date.day, time.hour, time.minute);
            });
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xffF1F2F6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Text(
              dueDate == null
                  ? "Chọn ngày & giờ"
                  : "${dueDate!.day}/${dueDate!.month}/${dueDate!.year} "
                  "${dueDate!.hour}:${dueDate!.minute.toString().padLeft(2, '0')}",
            ),
            const Spacer(),
            const Icon(Icons.calendar_today_outlined),
          ],
        ),
      ),
    );
  }

  /// PRIORITY
  Widget _priorityItem(String text, Color color) {
    final isSelected = priority == text;

    Color bgColor;
    Color borderColor;

    if (text == "Cao") {
      bgColor = isSelected ? const Color(0xffFFF1F1) : Colors.white;
      borderColor = Colors.red;
    } else if (text == "Trung bình") {
      bgColor = isSelected ? const Color(0xffFFF8E6) : Colors.white;
      borderColor = Colors.orange;
    } else {
      bgColor = isSelected ? const Color(0xffE9FFF1) : Colors.white;
      borderColor = Colors.green;
    }

    return GestureDetector(
      onTap: () => setState(() => priority = text),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: borderColor) : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.flag, color: color),
            ),
            const SizedBox(width: 12),
            Text(text),
            const Spacer(),
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              color: isSelected ? const Color(0xff4A6CF7) : Colors.grey,
            ),
            if (!isSelected)
              const Icon(Icons.chevron_right, color: Colors.grey)
          ],
        ),
      ),
    );
  }
}