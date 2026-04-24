import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../models/custom_icons.dart';
import '../services/category_service.dart';

class EditCategoryPage extends StatefulWidget {
  final Category category;

  const EditCategoryPage({super.key, required this.category});

  @override
  State<EditCategoryPage> createState() => _EditCategoryPageState();
}

class _EditCategoryPageState extends State<EditCategoryPage> {
  late TextEditingController _nameController;
  int? selectedIconIndex;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category.name);

    // 👉 tìm index icon từ DB
    selectedIconIndex = customIcons.indexWhere(
          (e) => e.name == widget.category.icon,
    );

    if (selectedIconIndex == -1) selectedIconIndex = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Sửa Danh mục",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
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
            onPressed: () async {
              if (_nameController.text.isEmpty) return;

              String iconName = customIcons[selectedIconIndex!].name;

              await CategoryService.update(
                Category(
                  id: widget.category.id,
                  name: _nameController.text,
                  icon: iconName,
                ),
              );

              Navigator.pop(context, true); // trả về true để trang trước load lại
            },
            child: const Text(
              "Lưu",
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // input name
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Tên danh mục",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            const Text("Chọn biểu tượng",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            // icon grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: customIcons.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                final iconData = customIcons[index].icon;
                final color = customIcons[index].color;
                final isSelected = selectedIconIndex == index;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedIconIndex = index;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? color.withOpacity(0.2)
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected
                          ? Border.all(color: color, width: 2)
                          : null,
                    ),
                    child: Icon(iconData, color: color, size: 30),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
