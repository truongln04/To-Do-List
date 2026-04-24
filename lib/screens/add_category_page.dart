import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../services/category_service.dart';
import '../models/custom_icons.dart';
class AddCategoryPage extends StatefulWidget {
  const AddCategoryPage({super.key});

  @override
  State<AddCategoryPage> createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage> {

  final TextEditingController _nameController = TextEditingController();
  int? selectedIconIndex;

  final List<CustomIcon> icons = customIcons; // gọi từ model

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Thêm Danh mục",
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

                String iconName = selectedIconIndex != null
                    ? icons[selectedIconIndex!].name   // dùng model thay vì map
                    : "work";

                await CategoryService.insert(
                  Category(
                    name: _nameController.text,
                    icon: iconName,
                  ),
                );

                Navigator.pop(context, true); // trả về true để trang trước load lại
              },
              child: const Text(
                "Thêm",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Tên danh mục",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            GridView.builder(
              shrinkWrap: true,
              itemCount: icons.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
              ),
              itemBuilder: (_, i) {
                final icon = icons[i];
                final isSelected = selectedIconIndex == i;

                return GestureDetector(
                  onTap: () => setState(() => selectedIconIndex = i),
                  child: Container(
                    margin: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? icons[i].color.withOpacity(0.2)   // dùng model
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icons[i].icon,   // dùng model
                      color: icons[i].color,
                    ),
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