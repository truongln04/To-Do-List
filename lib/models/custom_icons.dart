import 'package:flutter/material.dart';

class CustomIcon {
  final IconData icon;
  final String name;
  final Color color;

  const CustomIcon({required this.icon, required this.name, required this.color});
}

final List<CustomIcon> customIcons = [
  CustomIcon(icon: Icons.work, name: "work", color: Colors.blue),
  CustomIcon(icon: Icons.school, name: "study", color: Colors.purple),
  CustomIcon(icon: Icons.shopping_cart, name: "shop", color: Colors.orange),
  CustomIcon(icon: Icons.person, name: "person", color: Colors.green),
  CustomIcon(icon: Icons.favorite, name: "health", color: Colors.red),
  CustomIcon(icon: Icons.flight, name: "travel", color: Colors.teal),
  CustomIcon(icon: Icons.attach_money, name: "finance", color: Colors.indigo),
  CustomIcon(icon: Icons.restaurant, name: "food", color: Colors.brown),
  CustomIcon(icon: Icons.music_note, name: "music", color: Colors.pink),
  CustomIcon(icon: Icons.computer, name: "tech", color: Colors.cyan),
  CustomIcon(icon: Icons.home, name: "home", color: Colors.deepOrange),
  CustomIcon(icon: Icons.sports_soccer, name: "sport", color: Colors.greenAccent),
  CustomIcon(icon: Icons.book, name: "reading", color: Colors.deepPurple),
  CustomIcon(icon: Icons.movie, name: "movie", color: Colors.blueGrey),
  CustomIcon(icon: Icons.nature, name: "nature", color: Colors.lightGreen),
];

CustomIcon getCustomIcon(String? name) {
  return customIcons.firstWhere(
        (item) => item.name == name,
    orElse: () => const CustomIcon(
      icon: Icons.category,
      name: "default",
      color: Colors.grey,
    ),
  );
}
