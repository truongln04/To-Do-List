import 'package:flutter/material.dart';
import 'EditCategoryPage.dart';
import 'add_category_page.dart';           // Trang thêm danh mục
import 'category_detail_page.dart';       // Trang chi tiết danh mục (giả lập)

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  // Danh sách danh mục (đúng thứ tự và màu như AddCategoryPage)
  final List<Map<String, dynamic>> categories = [
    {
      "title": "Công việc",
      "count": 5,
      "icon": Icons.work,
      "color": Colors.blue, // xanh dương
    },
    {
      "title": "Học tập",
      "count": 4,
      "icon": Icons.school,
      "color": Colors.deepPurple, // tím
    },
    {
      "title": "Mua sắm",
      "count": 2,
      "icon": Icons.shopping_cart,
      "color": Colors.orange, // cam
    },
    {
      "title": "Cá nhân",
      "count": 3,
      "icon": Icons.person,
      "color": Colors.green, // xanh lá
    },
    {
      "title": "Sức khỏe",
      "count": 1,
      "icon": Icons.favorite,
      "color": Colors.pink, // hồng
    },
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Danh mục", style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, size: 28),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddCategoryPage()),
              );
              if (result != null) {
                // TODO: Thêm danh mục mới vào list (sau này dùng state management)
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Đã thêm danh mục mới")),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              "Danh mục của bạn",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                return _buildCategoryCard(cat);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> cat) {
    return GestureDetector(
      onTap: () {
        // Giả lập điều hướng sang trang chi tiết danh mục
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryDetailPage(categoryName: cat["title"]),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon với nền tròn
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (cat["color"] as Color).withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(cat["icon"] as IconData, color: cat["color"] as Color, size: 28),
            ),
            const SizedBox(width: 16),

            // Tiêu đề + số lượng
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cat["title"],
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${cat["count"]} công việc",
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            IconButton(
              icon: const Icon(Icons.more_horiz, color: Colors.grey),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.edit),
                        title: const Text("Chỉnh sửa"),
                        onTap: () {
                          Navigator.pop(context); // đóng bottom sheet
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditCategoryPage(
                                initialName: cat["title"],          // tên danh mục hiện tại
                                initialIconIndex: categories.indexOf(cat), // index icon hiện tại
                              ),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.delete),
                        title: const Text("Xóa danh mục"),
                        onTap: () {
                          Navigator.pop(context);
                          setState(() {
                            categories.remove(cat); // xóa danh mục khỏi list
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Đã xóa danh mục '${cat["title"]}'")),
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