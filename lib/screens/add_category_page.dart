import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../services/category_service.dart';

class AddCategoryPage extends StatefulWidget {
  const AddCategoryPage({super.key});

  @override
  State<AddCategoryPage> createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage> {

  final TextEditingController _nameController = TextEditingController();
  int? selectedIconIndex;

  final List<Map<String, dynamic>> icons = [
    {"icon": Icons.work, "name": "work", "color": Colors.blue},
    {"icon": Icons.school, "name": "study", "color": Colors.purple},
    {"icon": Icons.shopping_cart, "name": "shop", "color": Colors.orange},
    {"icon": Icons.person, "name": "person", "color": Colors.green},
    {"icon": Icons.favorite, "name": "health", "color": Colors.red},
    {"icon": Icons.flight, "name": "travel", "color": Colors.teal},
    {"icon": Icons.attach_money, "name": "finance", "color": Colors.indigo},
    {"icon": Icons.restaurant, "name": "food", "color": Colors.brown},
    {"icon": Icons.music_note, "name": "music", "color": Colors.pink},
    {"icon": Icons.computer, "name": "tech", "color": Colors.cyan},
    {"icon": Icons.home, "name": "home", "color": Colors.deepOrange},
    {"icon": Icons.sports_soccer, "name": "sport", "color": Colors.greenAccent},
    {"icon": Icons.book, "name": "reading", "color": Colors.deepPurple},
    {"icon": Icons.movie, "name": "movie", "color": Colors.blueGrey},
    {"icon": Icons.nature, "name": "nature", "color": Colors.lightGreen},
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Thêm Danh mục"),
        actions: [
          TextButton(
            onPressed: () async {
              if (_nameController.text.isEmpty) return;

              String iconName = selectedIconIndex != null
                  ? icons[selectedIconIndex!]["name"]
                  : "work";

              await CategoryService.insert(
                Category(
                  name: _nameController.text,
                  icon: iconName,
                ),
              );

              Navigator.pop(context);
            },
            child: const Text("Thêm", style: TextStyle(fontSize: 18)),
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
                          ? icon["color"].withOpacity(0.2)
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon["icon"], color: icon["color"]),
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