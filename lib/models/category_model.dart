class Category {
  int? id;
  String name;
  String icon;
  int taskCount;
  Category({
    this.id,
    required this.name,
    required this.icon,
    this.taskCount = 0,

  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'icon': icon,
  };

  factory Category.fromMap(Map<String, dynamic> m) => Category(
    id: m['id'],
    name: m['name'],
    icon: m['icon'],
  );
}