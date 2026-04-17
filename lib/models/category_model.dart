class Category {
  int? id;
  String name;
  String icon;

  Category({
    this.id,
    required this.name,
    required this.icon,
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