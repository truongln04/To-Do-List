import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../services/category_service.dart';
import 'add_category_page.dart';
import 'edit_category_page.dart';
import 'category_detail_page.dart';



class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  List<Category> categories = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    categories = await CategoryService.getAll();

    for (var cat in categories) {
      cat.taskCount = await CategoryService.getTaskCount(cat.id!);
    }

    setState(() {});
  }



  IconData getIcon(String? icon) {
    switch (icon) {
      case "work": return Icons.work;
      case "study": return Icons.school;
      case "shop": return Icons.shopping_cart;
      case "person": return Icons.person;
      case "health": return Icons.favorite;
      default: return Icons.category;
    }
  }

  // màu gradient đẹp hơn
  List<Color> getGradient(int index) {
    List<List<Color>> gradients = [
      [Colors.blue, Colors.indigo],
      [Colors.deepPurple, Colors.purpleAccent],
      [Colors.orange, Colors.deepOrange],
      [Colors.green, Colors.teal],
      [Colors.pink, Colors.redAccent],
    ];
    return gradients[index % gradients.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: const [
            Icon(Icons.category, color: Colors.white),
            SizedBox(width: 8),
            Text("Danh mục", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
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
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddCategoryPage()),
              );
              loadData();
            },
          ),
        ],
      ),

      body: categories.isEmpty
          ? const Center(child: Text("Chưa có danh mục"))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: categories.length,
        itemBuilder: (_, i) => _buildItem(categories[i], i),
      ),
    );
  }

  Widget _buildItem(Category cat, int index) {
    final gradientColors = getGradient(index);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CategoryDetailPage(
              categoryId: cat.id!,
              categoryName: cat.name,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradientColors),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradientColors.last.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Row(
          children: [
            // ICON
            CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.2),
              child: Icon(getIcon(cat.icon), color: Colors.white, size: 26),
            ),
            const SizedBox(width: 16),

            // NAME
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cat.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${cat.taskCount} công việc",
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),


            // MENU
            IconButton(
              icon: const Icon(Icons.more_horiz, color: Colors.white),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  builder: (_) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.edit, color: Colors.blue),
                        title: const Text("Sửa"),
                        onTap: () async {
                          Navigator.pop(context);
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditCategoryPage(category: cat),
                            ),
                          );
                          loadData();
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.delete, color: Colors.red),
                        title: const Text("Xóa"),
                        onTap: () async {
                          Navigator.pop(context);
                          await CategoryService.delete(cat.id!);
                          loadData();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Đã xóa '${cat.name}'")),
                          );
                        },
                      ),
                    ],
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
