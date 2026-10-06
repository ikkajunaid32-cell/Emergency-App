import 'package:flutter/material.dart';

class CategoryModel {
  final String id;
  final String name;
  final IconData icon;
  final Color color;

  CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });

  static List<CategoryModel> get defaultCategories => [
    CategoryModel(
      id: 'all',
      name: 'All Tasks',
      icon: Icons.explore_rounded,
      color: const Color(0xFFFF521B),
    ),
    CategoryModel(
      id: 'community',
      name: 'Community',
      icon: Icons.volunteer_activism_rounded,
      color: const Color(0xFF10B981),
    ),
    CategoryModel(
      id: 'fitness',
      name: 'Fitness & Health',
      icon: Icons.fitness_center_rounded,
      color: const Color(0xFF3B82F6),
    ),
    CategoryModel(
      id: 'creative',
      name: 'Creative',
      icon: Icons.palette_rounded,
      color: const Color(0xFF8B5CF6),
    ),
    CategoryModel(
      id: 'learning',
      name: 'Learning',
      icon: Icons.school_rounded,
      color: const Color(0xFFEC4899),
    ),
    CategoryModel(
      id: 'environment',
      name: 'Eco & Green',
      icon: Icons.eco_rounded,
      color: const Color(0xFF059669),
    ),
    CategoryModel(
      id: 'daily',
      name: 'Daily Habit',
      icon: Icons.checklist_rounded,
      color: const Color(0xFFF59E0B),
    ),
  ];
}
