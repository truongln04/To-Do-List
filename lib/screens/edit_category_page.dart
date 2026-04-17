import 'package:flutter/material.dart';
import '../models/category_model.dart';
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

  final List<Map<String, dynamic>> icons = [
    {"icon": Icons.work, "name": "work", "color": Colors.blue},
    {"icon": Icons.school, "name": "study", "color": Colors.deepPurple},
    {"icon": Icons.shopping_cart, "name": "shop", "color": Colors.orange},
    {"icon": Icons.person, "name": "person", "color": Colors.green},
    {"icon": Icons.favorite, "name": "health", "color": Colors.red},
  ];

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.category.name);

    // 👉 tìm index icon từ DB
    selectedIconIndex = icons.indexWhere(
          (e) => e["name"] == widget.category.icon,
    );

    if (selectedIconIndex == -1) selectedIconIndex = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sửa Danh mục"),
        actions: [
          TextButton(
            onPressed: () async {
              if (_nameController.text.isEmpty) return;

              String iconName = icons[selectedIconIndex!]["name"];

              // 👉 UPDATE DB
              await CategoryService.update(
                Category(
                  id: widget.category.id,
                  name: _nameController.text,
                  icon: iconName,
                ),
              );

              Navigator.pop(context);
            },
            child: const Text("Lưu", style: TextStyle(fontSize: 18)),
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
              itemCount: icons.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                final iconData = icons[index]["icon"] as IconData;
                final color = icons[index]["color"] as Color;
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