import 'package:flutter/material.dart';

class EditCategoryPage extends StatefulWidget {
  final String initialName;
  final int initialIconIndex;

  const EditCategoryPage({
    super.key,
    required this.initialName,
    required this.initialIconIndex,
  });

  @override
  State<EditCategoryPage> createState() => _EditCategoryPageState();
}

class _EditCategoryPageState extends State<EditCategoryPage> {
  late TextEditingController _nameController;
  int? selectedIconIndex;

  final List<Map<String, dynamic>> icons = [
    {"icon": Icons.work, "color": Colors.blue},
    {"icon": Icons.school, "color": Colors.deepPurple},
    {"icon": Icons.shopping_cart, "color": Colors.orange},
    {"icon": Icons.person, "color": Colors.green},
    {"icon": Icons.favorite, "color": Colors.red},
    {"icon": Icons.check_circle, "color": Colors.teal},
    {"icon": Icons.palette, "color": Colors.pink},
    {"icon": Icons.public, "color": Colors.indigo},
    {"icon": Icons.language, "color": Colors.brown},
    {"icon": Icons.add, "color": Colors.grey}, // thêm mới
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    selectedIconIndex = widget.initialIconIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sửa Danh mục"),
        actions: [
          TextButton(
            onPressed: () {
              if (_nameController.text.isNotEmpty) {
                Navigator.pop(context, {
                  "name": _nameController.text,
                  "icon": selectedIconIndex != null ? icons[selectedIconIndex!] : null,
                });
              }
            },
            child: const Text("Lưu", style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
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
            const SizedBox(height: 20),
            const Text("Hoặc thêm biểu tượng mới",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
              height: 80,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(Icons.image, size: 40, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
